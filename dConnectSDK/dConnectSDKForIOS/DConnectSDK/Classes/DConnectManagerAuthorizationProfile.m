//
//  DConnectManagerAuthorizationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManagerAuthorizationProfile.h"
#import "DConnectDevicePlugin.h"
#import "LocalOAuth2Main.h"

@implementation DConnectManagerAuthorizationProfile

- (id) initWithObject:(id)object {
    self = [super initWithObject: object];
    if (self) {
        
        NSString *getCreateClientApiPath = [self apiPath: nil
                                           attributeName: DConnectAuthorizationProfileAttrGrant];
        [self addGetPath: getCreateClientApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *origin = nil;
                         
                         if ([request hasKey:DConnectMessageOrigin]) {
                             origin = [request stringForKey:DConnectMessageOrigin];
                         }
                         if (origin == nil || origin.length <= 0) {
                             [response setErrorToInvalidRequestParameter];
                         } else {
                             LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[object class]];
                             LocalOAuthPackageInfo *packageInfo
                             = [[LocalOAuthPackageInfo alloc] initWithPackageNameServiceId:origin
                                                                                 serviceId:serviceId];
                             LocalOAuthClientData *clientData = [oauth createClientWithPackageInfo:packageInfo];
                             if (clientData) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [DConnectAuthorizationProfile setClientId:clientData.clientId target:response];
                             } else {
                                 [response setErrorToUnknown];
                             }
                         }
                         return YES;
                     }];
        
        NSString *getRequestAccessTokenApiPath = [self apiPath: nil
                                                 attributeName: DConnectAuthorizationProfileAttrAccessToken];
        [self addGetPath: getRequestAccessTokenApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         NSString *clientId = [DConnectAuthorizationProfile clientIdFromRequest:request];
                         NSString *scope = [DConnectAuthorizationProfile scopeFromeFromRequest:request];
                         NSArray *scopes = [DConnectAuthorizationProfile parsePattern:scope];
                         NSString *applicationName = [DConnectAuthorizationProfile applicationNameFromRequest:request];
                         
                         if (clientId == nil) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"clientId is nil."];
                             return YES;
                         } else if (clientId.length <= 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"clientId is empty."];
                             return YES;
                         } else if (scopes == nil) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"scope is nil."];
                             return YES;
                         } else if (scopes.count <= 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"scope is empty."];
                             return YES;
                         } else if (scope.length <= 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"scope is empty."];
                             return YES;
                         } else if (applicationName == nil) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"applicationName is nil."];
                             return YES;
                         } else if (applicationName.length <= 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"applicationName is empty."];
                             return YES;
                         }
                         
                         LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[object class]];
                         dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                         dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 60);
                         BOOL isDevicePlugin = [object isKindOfClass:[DConnectDevicePlugin class]];
                         
                         NSMutableArray *lowercaseScopes = [NSMutableArray array];
                         for (NSString *scope in scopes) {
                             [lowercaseScopes addObject: [scope lowercaseString]];
                         }
                         
                         LocalOAuthConfirmAuthParams *params = [LocalOAuthConfirmAuthParams new];
                         params.applicationName = applicationName;
                         params.clientId = clientId;
                         params.serviceId = serviceId;
                         params.scope = lowercaseScopes;
                         params.isForDevicePlugin = isDevicePlugin;
                         params.object = object;
                         
                         [oauth confirmPublishAccessTokenWithParams:params
                                         receiveAccessTokenCallback:^(LocalOAuthAccessTokenData *accessTokenData) {
                                             if (accessTokenData) {
                                                 
                                                 [response setResult:DConnectMessageResultTypeOk];
                                                 [DConnectAuthorizationProfile setAccessToken:accessTokenData._accessToken
                                                                                       target:response];
                                                 
                                                 DConnectArray *arr = [DConnectArray array];
                                                 NSArray *scopes = accessTokenData._scopes;
                                                 for (LocalOAuthAccessTokenScope *s in scopes) {
                                                     DConnectMessage *msg = [DConnectMessage message];
                                                     [DConnectAuthorizationProfile setScope:s._scope target:msg];
                                                     [DConnectAuthorizationProfile setExpirePriod:s._expirePeriod target:msg];
                                                     [arr addMessage:msg];
                                                 }
                                                 [DConnectAuthorizationProfile setScopes:arr target:response];
                                             } else {
                                                 [response setErrorToAuthorizationWithMessage:@"Cannot create a access token."];
                                             }
                                             dispatch_semaphore_signal(semaphore);
                                         }
                                           receiveExceptionCallback:^(NSString *exceptionMessage) {
                                               [response setErrorToAuthorizationWithMessage:@"Cannot create a access token."];
                                               dispatch_semaphore_signal(semaphore);
                                           }];
                         
                         long result = dispatch_semaphore_wait(semaphore, timeout);
                         if (result != 0) {
                             [response setErrorToAuthorizationWithMessage:@"timeout"];
                         }
                         return YES;
                     }];
    }
    return self;
}

- (void) didReceiveInvalidOriginRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
{
    NSString *attribute = [request attribute];
    if (attribute && [attribute localizedCaseInsensitiveCompare:DConnectAuthorizationProfileAttrGrant] == NSOrderedSame) {
        [response setString:@"" forKey:DConnectAuthorizationProfileParamClientId];
    } else if (attribute && [attribute localizedCaseInsensitiveCompare:DConnectAuthorizationProfileAttrAccessToken] == NSOrderedSame) {
        [response setString:@"" forKey:DConnectAuthorizationProfileParamAccessToken];
    }
}

@end
