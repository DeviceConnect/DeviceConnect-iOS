//
//  DConnectUtil.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectUtil.h"
#import "DConnectRequestMessage.h"
#import "DConnectResponseMessage.h"
#import "DConnectAuthorizationProfile+Private.h"
#import "DConnectManager+Private.h"
#import "DConnectWhitelistUtil.h"
#import "CipherAuthSignature.h"
#import "LocalOAuth2Main.h"

@interface DConnectUtil()
+ (DConnectResponseMessage *) executeRequest:(DConnectRequestMessage *)request;
@end

@implementation DConnectUtil

#pragma mark - Authorization

+ (void) authorizeWithOrigin:(NSString *)origin
                     appName:(NSString *)appName
                      scopes:(NSArray *)scopes
                     success:(DConnectAuthorizationSuccessBlock)success
                       error:(DConnectAuthorizationFailBlock)error
{
    
    if (!appName) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"App name is nil."
                                     userInfo:nil];
    } else if (!scopes || scopes.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"No scopes."
                                     userInfo:nil];
    } else if (!success || !error) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Callback is nil."
                                     userInfo:nil];
    }
    
    DConnectRequestMessage *req = [DConnectRequestMessage message];
    req.action = DConnectMessageActionTypeGet;
    req.profile = DConnectAuthorizationProfileName;
    req.attribute = DConnectAuthorizationProfileAttrGrant;
    [req setString:origin forKey:DConnectMessageOrigin];
    
    DConnectResponseMessage *res = [self executeRequest:req];
    
    if (res.result == DConnectMessageResultTypeError) {
        error([res integerForKey:DConnectMessageErrorCode]);
        return;
    }
    
    NSString *clientId = [res stringForKey:DConnectAuthorizationProfileParamClientId];
    
    if (!clientId) {
        error(DConnectMessageErrorCodeUnknown);
    } else {
        [self refreshAccessTokenWithClientId:clientId
                                      origin:origin
                                     appName:appName scopes:scopes
                                     success:success error:error];
    }
    
    
}

+ (void) asyncAuthorizeWithOrigin:(NSString *)origin
                          appName:(NSString *)appName
                           scopes:(NSArray *)scopes
                          success:(DConnectAuthorizationSuccessBlock)success
                            error:(DConnectAuthorizationFailBlock)error
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [DConnectUtil authorizeWithOrigin:origin
                                  appName:appName
                                   scopes:scopes
                                  success:success
                                    error:error];
    });
}


+ (void) refreshAccessTokenWithClientId:(NSString *)clientId
                                 origin:(NSString *)origin
                                appName:(NSString *)appName
                                 scopes:(NSArray *)scopes
                                success:(DConnectAuthorizationSuccessBlock)success
                                  error:(DConnectAuthorizationFailBlock)error
{
    
    if (!clientId) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Client ID is nil."
                                     userInfo:nil];
    } else if (!appName) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"App name is nil."
                                     userInfo:nil];
    } else if (!scopes || scopes.count == 0) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"No scopes."
                                     userInfo:nil];
    } else if (!success || !error) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Callback is nil."
                                     userInfo:nil];
    }
    
    DConnectRequestMessage *req = [DConnectRequestMessage message];
    req.action = DConnectMessageActionTypeGet;
    req.profile = DConnectAuthorizationProfileName;
    req.attribute = DConnectAuthorizationProfileAttrAccessToken;
    [DConnectAuthorizationProfile setClientId:clientId target:req];
    [DConnectAuthorizationProfile setScope:[self combineScopes:scopes] target:req];
    [req setString:appName forKey:DConnectAuthorizationProfileParamApplicationName];
    [req setString:origin forKey:DConnectMessageOrigin];
    
    DConnectResponseMessage *res = [self executeRequest:req];
    
    if (res.result == DConnectMessageResultTypeError) {
        error([res integerForKey:DConnectMessageErrorCode]);
    } else {
        NSString *accessToken = [res stringForKey:DConnectAuthorizationProfileParamAccessToken];
        success(clientId, accessToken);
    }
}

+ (NSString *) combineScopes:(NSArray *)scopes {
    
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < scopes.count; i++) {
        NSString *scope = [scopes objectAtIndex:i];
        if (i > 0) {
            [str appendString:@","];
        }
        [str appendString:[scope stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    }
    
    return str;
}

+ (DConnectResponseMessage *) executeRequest:(DConnectRequestMessage *)request {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block DConnectResponseMessage *res = nil;
    [[DConnectManager sharedManager] sendRequest:request callback:^(DConnectResponseMessage *response) {
        res = response;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return res;
}

+ (void) showAccessTokenList {
    [[LocalOAuth2Main sharedOAuthForClass:[DConnectManager class]] startAccessTokenListActivity];
}

+ (void) showOriginWhitelist {
    [DConnectWhitelistUtil showOriginWhitelist];
}

@end
