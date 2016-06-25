//
//  DConnectDevicePlugin.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDevicePlugin.h"
#import "DConnectManager+Private.h"
#import "DConnectAuthorizationProfile+Private.h"
#import "DConnectServiceDiscoveryProfile.h"
#import "DConnectSystemProfile.h"
#import "DConnectConst.h"
#import "LocalOAuth2Main.h"

@interface DConnectDevicePlugin ()
/**
 * プロファイルを格納するマップ.
 */
@property (nonatomic) NSMutableDictionary *mProfileMap;
- (BOOL) executeRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;
@end

@implementation DConnectDevicePlugin

- (id) init {
    self = [super init];
    if (self) {
        self.useLocalOAuth = YES;
        
        self.mProfileMap = [NSMutableDictionary dictionary];
        self.pluginName = NSStringFromClass([self class]);
        self.pluginVersionName = @"1.0.0";

        // Local OAuthプロファイル追加
        [self addProfile:[[DConnectAuthorizationProfile alloc] initWithObject:self]];
        
        // イベント登録
        NSNotificationCenter *notificationCenter
                                = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(applicationDidEnterBackground)
                                   name:DConnectApplicationDidEnterBackground
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(applicationWillEnterForeground)
                                   name:DConnectApplicationWillEnterForeground
                                 object:nil];
    }
    return self;
}

- (BOOL) executeRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response
{
    // 指定されたプロファイルを取得する
    DConnectProfile *profile = [self profileWithName:[request profile]];
    
    // 各プロファイルでリクエストを処理する
    BOOL processed = YES;
    if (profile) {
        processed = [profile didReceiveRequest:request response:response];
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return processed;
}

- (BOOL) didReceiveRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response
{
#ifdef DEBUG
    // レスポンスがどこのレイヤーで返されているかのログを見るための処理
    [response setString:@"DevicePlugin" forKey:@"debug"];
#endif

    // Service Discovery APIのパスを変換
    NSString *profileName = [[request profile] lowercaseString];
    if ([self isEqualToProfile: profileName cmp:DConnectProfileNameNetworkServiceDiscovery]) {
        NSString *attribute = [[request attribute] lowercaseString];
        if ([self isEqualToAttribute: attribute cmp:DConnectAttributeNameGetNetworkServices]) {
            profileName = DConnectServiceDiscoveryProfileName;
            [request setProfile:DConnectServiceDiscoveryProfileName];
            [request setAttribute:nil];
        }
    } else if ([self isEqualToProfile: profileName cmp:DConnectAuthorizationProfileName]) {
        NSString *attribute = [request attribute];
        if ([self isEqualToAttribute: attribute cmp:DConnectAttributeNameCreateClient]) {
            [request setAttribute:DConnectAuthorizationProfileAttrGrant];
        } else if ([self isEqualToAttribute: attribute cmp:DConnectAttributeNameRequestAccessToken]) {
            [request setAttribute:DConnectAuthorizationProfileAttrAccessToken];
        }
    }
    
    // プロファイルの有無をチェックする
    DConnectProfile *profile = [self profileWithName:[request profile]];
    if (profile == nil) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    if (self.useLocalOAuth) {
        // Local OAuthの認証を行う
        NSString *accessToken = [request accessToken];
        NSArray *scopes = DConnectPluginIgnoreProfiles();
        LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[self class]];
        LocalOAuthCheckAccessTokenResult *result = [oauth checkAccessTokenWithScope:[profileName lowercaseString]
                                                                      specialScopes:scopes
                                                                        accessToken:accessToken];
        if ([result checkResult]) {
            return [self executeRequest:request response:response];
        }
        // Local OAuth認証失敗
        if (accessToken == nil) {
            [response setErrorToEmptyAccessToken];
        } else if (![result isExistAccessToken]) {
            [response setErrorToNotFoundClientId];
        } else if (![result isExistClientId]) {
            [response setErrorToNotFoundClientId];
        } else if (![result isExistScope]) {
            [response setErrorToScope];
        } else if (![result isExistNotExpired]) {
            [response setErrorToExpiredAccessToken];
        } else {
            [response setErrorToAuthorization];
        }
        // DConnectManagerDeliveryProfileで認証エラー結果を同期で待つので
        // エラーを返却する場合には、返り値をYESで行うこと。
        // 認証エラーでアクセストークンの期限切れの場合にはリトライを行う。
        return YES;
    }
    return [self executeRequest:request response:response];
}

- (BOOL) sendEvent:(DConnectMessage *)event {
    return [[DConnectManager sharedManager] sendEvent:event];
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
}

#pragma mark - DConnectProfileProvider Methods -

- (void) addProfile:(DConnectProfile *) profile {
    NSString *name = [[profile profileName] lowercaseString];
    if (name) {
        [self.mProfileMap setObject:profile forKey:name];
        profile.provider = self;
    }
}

- (void) removeProfile:(DConnectProfile *) profile {
    NSString *name = [[profile profileName] lowercaseString];
    if (name) {
        [self.mProfileMap removeObjectForKey:name];
    }
}

- (DConnectProfile *) profileWithName:(NSString *)name {
    if (name) {
        return [self.mProfileMap objectForKey:[name lowercaseString]];
    }
    return nil;
}

- (NSArray *) profiles {
    NSMutableArray *list = [NSMutableArray array];
    for (id key in [self.mProfileMap allKeys]) {
        [list addObject:[self.mProfileMap objectForKey:key]];
    }
    return list;
}

- (BOOL)isEqualToProfile: profile cmp: (NSString *)cmpProfile {
    
    if ([[profile lowercaseString] isEqualToString: [cmpProfile lowercaseString]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqualToAttribute: attribute cmp: (NSString *)cmpAttribute {
    
    if ([[attribute lowercaseString] isEqualToString: [cmpAttribute lowercaseString]]) {
        return YES;
    }
    return NO;
}

- (BOOL)isEqualToInterface: interface cmp: (NSString *)cmpInterface {
    
    if ([[interface lowercaseString] isEqualToString: [cmpInterface lowercaseString]]) {
        return YES;
    }
    return NO;
}

@end
