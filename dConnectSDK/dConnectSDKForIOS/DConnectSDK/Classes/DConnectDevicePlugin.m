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
#import "DConnectServiceManager.h"
#import "DConnectServiceInformationProfile.h"
#import <DConnectSDK/DConnectPluginSpec.h>
#import "CipherSignatureProc.h"
#import "CipherSignatureFactory.h"

@interface DConnectDevicePlugin ()

/*!
 @brief plugin。
 */
@property(nonatomic, weak) id plugin_;

/*!
 @brief プロファイルを格納するマップ.
 */
@property (nonatomic) NSMutableDictionary *mProfileMap;

- (BOOL) executeRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response;

@end

@implementation DConnectDevicePlugin

- (id) initWithObject: (id) object {
    self = [super init];
    if (self) {
        
        // デバイスプラグインデータ設定
        CipherSignatureProc *md5Proc = [CipherSignatureFactory getInstance: CIPHER_SIGNATURE_KIND_MD5];
        self.useLocalOAuth = YES;
        self.mProfileMap = [NSMutableDictionary dictionary];
        self.pluginName = NSStringFromClass([self class]);
        self.pluginVersionName = @"1.0.0";
        self.pluginId = [md5Proc generateSignature: self.pluginName];

        // DeviceConnectサービス管理クラスの初期化
        DConnectServiceManager *serviceManager = [DConnectServiceManager sharedForClass: [object class]];
        [serviceManager setPlugin: self];
        [self setServiceProvider: serviceManager];
        
        // イベント管理クラスの初期化
        id<DConnectEventCacheController> ctrl = [self eventCacheController];
        [[DConnectEventManager sharedManagerForClass:[self class]] setController:ctrl];

        // プロファイル追加
        [self addProfile:[[DConnectAuthorizationProfile alloc] initWithObject:self]];
        [self addProfile:[[DConnectServiceDiscoveryProfile alloc] initWithServiceProvider: self.serviceProvider]];
        [self addProfile:[DConnectSystemProfile new]];
        
        
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
        return [service didReceiveRequest: request response: response];
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
    NSString *profileName = [[request profile] lowercaseString];
    if (profileName && [profileName localizedCaseInsensitiveCompare:DConnectProfileNameNetworkServiceDiscovery] == NSOrderedSame) {
        NSString *attribute = [[request attribute] lowercaseString];
        if (attribute && [attribute localizedCaseInsensitiveCompare:DConnectAttributeNameGetNetworkServices] == NSOrderedSame) {
            profileName = DConnectServiceDiscoveryProfileName;
            [request setProfile:DConnectServiceDiscoveryProfileName];
            [request setAttribute:nil];
        }
    } else if (profileName && [profileName localizedCaseInsensitiveCompare:DConnectAuthorizationProfileName] == NSOrderedSame) {
        NSString *attribute = [request attribute];
        if (attribute) {
            if ([attribute localizedCaseInsensitiveCompare: DConnectAttributeNameCreateClient] == NSOrderedSame) {
                [request setAttribute:DConnectAuthorizationProfileAttrGrant];
            } else if ([attribute localizedCaseInsensitiveCompare: DConnectAttributeNameRequestAccessToken] == NSOrderedSame) {
                [request setAttribute:DConnectAuthorizationProfileAttrAccessToken];
            }
        }
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
    return [[DConnectManager sharedManager] sendEvent:event authorized:self.useLocalOAuth];
}

- (void)applicationDidEnterBackground {
}

- (void)applicationWillEnterForeground {
}

#pragma mark - DConnectProfileProvider Methods -

// DConnectMessageService#addProfile()
- (void) addProfile:(DConnectProfile *) profile {
    if (!profile) {
        return;
    }
    NSString *profileName = [[profile profileName] lowercaseString];

    // プロファイルのJSONファイルを読み込み、内部生成したprofileSpecを新規登録する
    NSError *error = nil;
    [[DConnectPluginSpec shared] addProfileSpec: profileName bundle: nil error: &error];
    if (error) {
        DCLogE(@"addProfileSpec error ! %@", [error description]);
    }
    
    // プロファイルに仕様データを設定する
    DConnectProfileSpec *profileSpec = [[DConnectPluginSpec shared] findProfileSpec: profileName];
    if (profileSpec) {
        [profile setProfileSpec: profileSpec];
    }
    
    // プロファイルにプロファイルプロバイダとデバイスプラグインのインスタンスを設定する
    [profile setProvider: self];
    [profile setPlugin: self];
    
    // ProfileMapにprofileデータを追加
    [self.mProfileMap setObject: profile forKey: profileName];
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

- (NSArray *) serviceProfilesWithServiceId: (NSString *) serviceId {

    DConnectService *service = [self.serviceProvider service: serviceId];
    if (service) {
        // サービスIDに該当するサービスを検出して、そのサービスに登録されているプロファイル一覧(DConnectProfile * の配列)を取得
        NSArray *serviceProfiles = [service profiles];
        return serviceProfiles;
    }
    return nil;
}

- (id<DConnectEventCacheController>) eventCacheController
{
    return [[DConnectMemoryCacheController alloc] init];
}


- (NSString*)iconFilePath:(BOOL)isOnline
{
    return nil; //should be overrided
}

@end
