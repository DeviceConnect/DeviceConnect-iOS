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
#import "DConnectApiSpecList.h"
#import "DConnectServiceManager.h"
#import "DConnectServiceInformationProfile.h"

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
    // プラグインにプロファイルが存在するか？
    DConnectProfile *profile = [self profileWithName:[request profile]];
    if (profile) {
        return [profile didReceiveRequest:request response:response];
    }
    
    // DConnectServiceにプロファイルが登録されているか？
    DConnectServiceManager *serviceManager = [DConnectServiceManager sharedForClass: self.class];
    DConnectService *service = [serviceManager service: [request serviceId]];
    if (service) {
        // TODO: onRequest → didReceiveRequest に名称変更。
        return [service onRequest: request response: response];
    }
    
    // プロファイルが存在しないのでエラー
    [response setErrorToNotSupportProfile];
    return YES;
}

- (BOOL) didReceiveRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response
{
#ifdef DEBUG
    // レスポンスがどこのレイヤーで返されているかのログを見るための処理
    [response setString:@"DevicePlugin" forKey:@"debug"];
#endif

    // Service Discovery APIのパスを変換
    NSString *profileName = [request profile];
    if ([profileName isEqualToString:DConnectProfileNameNetworkServiceDiscovery]) {
        NSString *attribute = [request attribute];
        if ([attribute isEqualToString:DConnectAttributeNameGetNetworkServices]) {
            profileName = DConnectServiceDiscoveryProfileName;
            [request setProfile:DConnectServiceDiscoveryProfileName];
            [request setAttribute:nil];
        }
    } else if ([profileName isEqualToString:DConnectAuthorizationProfileName]) {
        NSString *attribute = [request attribute];
        if ([attribute isEqualToString:DConnectAttributeNameCreateClient]) {
            [request setAttribute:DConnectAuthorizationProfileAttrGrant];
        } else if ([attribute isEqualToString:DConnectAttributeNameRequestAccessToken]) {
            [request setAttribute:DConnectAuthorizationProfileAttrAccessToken];
        }
    }
    
    if (self.useLocalOAuth) {
        // Local OAuthの認証を行う
        NSString *accessToken = [request accessToken];
        NSArray *scopes = DConnectPluginIgnoreProfiles();
        LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[self class]];
        LocalOAuthCheckAccessTokenResult *result = [oauth checkAccessTokenWithScope:profileName
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
    NSString *name = [profile profileName];
    if (name) {
        [self.mProfileMap setObject:profile forKey:name];
        profile.provider = self;
        [self loadApiSpec: name];
    }
}

- (void) removeProfile:(DConnectProfile *) profile {
    NSString *name = [profile profileName];
    if (name) {
        [self.mProfileMap removeObjectForKey:name];
    }
}

- (DConnectProfile *) profileWithName:(NSString *)name {
    if (name) {
        return [self.mProfileMap objectForKey:name];
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

// デバイスプラグインがaddProfile()した後にSDK側で処理を実行するタイミングがないので[loadApiSpecList]をそのまま使えない。
// [addProfile]する毎に[loadApiSpec]を実行してApiSpecを設定する。
- (void) loadApiSpec: (NSString *)profileName {
    
    if (!profileName ||
        [DConnectAuthorizationProfileName localizedCaseInsensitiveCompare: profileName] == NSOrderedSame ||
        [DConnectServiceDiscoveryProfileName localizedCaseInsensitiveCompare: profileName] == NSOrderedSame ||
        [DConnectServiceInformationProfileName localizedCaseInsensitiveCompare: profileName] == NSOrderedSame ||
        [DConnectSystemProfileName localizedCaseInsensitiveCompare: profileName] == NSOrderedSame) {
        return;
    }
    
    @try {
        DConnectApiSpecList *specList = [DConnectApiSpecList shared];
        [specList addApiSpecList: profileName];
    } @catch (NSString *e) {
        DCLogW(@"Device Connect API Specs is invalid. %@", e);
        return;
    }
}

@end
