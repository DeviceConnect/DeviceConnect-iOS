//
//  DConnectAuthorizationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAuthorizationProfile+Private.h"
#import "LocalOAuth2Main.h"
#import "DConnectManager+Private.h"
#import "DConnectDevicePlugin+Private.h"

NSString *const DConnectAuthorizationProfileName = @"authorization";
NSString *const DConnectAuthorizationProfileAttrGrant = @"grant";
NSString *const DConnectAuthorizationProfileAttrAccessToken = @"accesstoken";

NSString *const DConnectAuthorizationProfileParamPackage = @"package";
NSString *const DConnectAuthorizationProfileParamClientId = @"clientId";
NSString *const DConnectAuthorizationProfileParamScope = @"scope";
NSString *const DConnectAuthorizationProfileParamScopes = @"scopes";
NSString *const DConnectAuthorizationProfileParamApplicationName = @"applicationName";
NSString *const DConnectAuthorizationProfileParamExpirePeriod = @"expirePeriod";
NSString *const DConnectAuthorizationProfileParamExpire = @"expire";
NSString *const DConnectAuthorizationProfileParamAccessToken = @"accessToken";

NSString *const DConnectAuthorizationProfileGrantTypeAuthorizationCode = @"authorization_code";


@implementation DConnectAuthorizationProfile

- (id) initWithObject:(id)object {
    self = [super init];
    if (self) {
        __weak id weakObject = object;
        
        NSString *getCreateClientApiPath = [self apiPath: nil
                                           attributeName: DConnectAuthorizationProfileAttrGrant];
        [self addGetPath: getCreateClientApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
            NSString *serviceId = [request serviceId];
            NSString *package = [DConnectAuthorizationProfile packageFromRequest:request];
            
            if (package == nil || package.length <= 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass: [weakObject class]];
                LocalOAuthPackageInfo *packageInfo
                = [[LocalOAuthPackageInfo alloc] initWithPackageNameServiceId:package
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
        [self addGetPath:getRequestAccessTokenApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
            NSString *serviceId = [request serviceId];
            NSString *package = [DConnectAuthorizationProfile packageFromRequest:request];
            NSString *clientId = [DConnectAuthorizationProfile clientIdFromRequest:request];
            NSString *scope = [DConnectAuthorizationProfile scopeFromeFromRequest:request];
            NSArray *scopes = [DConnectAuthorizationProfile parsePattern:scope];
            NSString *applicationName = @"Device Connect Manager";
            
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
            } else if (package == nil) {
                [response setErrorToInvalidRequestParameterWithMessage:@"package is nil."];
                return YES;
            } else if (package.length <= 0) {
                [response setErrorToInvalidRequestParameterWithMessage:@"package is empty."];
                return YES;
            }
            
            LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass: [weakObject class]];
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
                                    LocalOAuthAccessTokenScope *minScope = nil;
                                    for (LocalOAuthAccessTokenScope *s in scopes) {
                                        DConnectMessage *msg = [DConnectMessage message];
                                        [DConnectAuthorizationProfile setScope:s._scope target:msg];
                                        [DConnectAuthorizationProfile setExpirePriod:s._expirePeriod target:msg];
                                        [arr addMessage:msg];
                                        
                                        // 最短の有効期限を取得する
                                        if (minScope == nil
                                            || s._expirePeriod < minScope._expirePeriod) {
                                            minScope = s;
                                        }
                                    }
                                    if (minScope) {
                                        long expirePeriod = minScope._expirePeriod;
                                        long long expire = accessTokenData._timestamp + (expirePeriod * 1000LL);
                                        [DConnectAuthorizationProfile setExpire:expire target:response];
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

- (NSString *) profileName {
    return DConnectAuthorizationProfileName;
}

#pragma mark - Setter

+ (void) setClientId:(NSString *)clientId target:(DConnectMessage *)message {
    [message setString:clientId forKey:DConnectAuthorizationProfileParamClientId];
}

+ (void) setAccessToken:(NSString *)accessToken target:(DConnectMessage *)message {
    [message setString:accessToken forKey:DConnectAuthorizationProfileParamAccessToken];
}

+ (void) setScopes:(DConnectArray *)scopes target:(DConnectMessage *)message {
    [message setArray:scopes forKey:DConnectAuthorizationProfileParamScopes];
}

+ (void) setScope:(NSString *)scope target:(DConnectMessage *)message {
    [message setString:scope forKey:DConnectAuthorizationProfileParamScope];
}

+ (void) setExpirePriod:(long long)priod target:(DConnectMessage *)message {
    [message setLongLong:priod forKey:DConnectAuthorizationProfileParamExpirePeriod];
}

+ (void) setExpire:(long long)expire target:(DConnectMessage *)message {
    [message setLongLong:expire forKey:DConnectAuthorizationProfileParamExpire];
}

#pragma mark - Getter

+ (NSString *) packageFromRequest:(DConnectRequestMessage *)request {
    return [request stringForKey:DConnectAuthorizationProfileParamPackage];
}

+ (NSString *) clientIdFromRequest:(DConnectRequestMessage *)request {
    return [request stringForKey:DConnectAuthorizationProfileParamClientId];
}

+ (NSString *) scopeFromeFromRequest:(DConnectRequestMessage *)request {
    return [request stringForKey:DConnectAuthorizationProfileParamScope];
}

+ (NSArray *) parsePattern:(NSString *)scope {
    return [scope componentsSeparatedByString:@","];
}

+ (NSString *) applicationNameFromRequest:(DConnectRequestMessage *)request {
    return [request stringForKey:DConnectAuthorizationProfileParamApplicationName];
}

@end
