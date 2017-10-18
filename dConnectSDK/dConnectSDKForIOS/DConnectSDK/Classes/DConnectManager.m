//
//  DConnectManager.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManager+Private.h"
#import "DConnectDevicePlugin+Private.h"
#import "DConnectManagerAuthorizationProfile.h"
#import "DConnectManagerDeliveryProfile.h"
#import "DConnectManagerServiceDiscoveryProfile.h"
#import "DConnectManagerSystemProfile.h"
#import "DConnectFilesProfile.h"
#import "DConnectManagerAuthorizationProfile.h"
#import "DConnectAvailabilityProfile.h"
#import "DConnectMessage+Private.h"
#import "DConnectSettings.h"
#import "DConnectEventManager.h"
#import "DConnectDBCacheController.h"
#import "DConnectConst.h"
#import "DConnectWhitelist.h"
#import "DConnectOriginParser.h"
#import "LocalOAuth2Main.h"
#import "DConnectServerManager.h"
#import "DConnectEventBroker.h"
#import "DConnectEventSessionTable.h"
#import "DConnectLocalOAuthDB.h"
#import "DConnectPluginSpec.h"

static NSString *const MATCH_YES = @"YES";
static NSString *const MATCH_NO = @"NO";
static NSString *const MATCH_OLD_NAME = @"matchOldName";
static NSString *const MATCH_NEW_NAME = @"matchNewName";
static NSString *const OLD_NAME = @"oldName";
static NSString *const NEW_NAME = @"newName";

NSString *const DConnectApplicationDConnectDomain = @".deviceconnect.org";
NSString *const DConnectApplicationLocalhostDConnect = @"localhost.deviceconnect.org";

static NSString *const KEY_MANAGER_UUID = @"_dconnectManagerUUID";
static NSString *const KEY_MANAGER_NAME = @"_dconnectManagerName";


NSString *const DConnectApplicationDidEnterBackground = @"DConnectApplicationDidEnterBackground";
NSString *const DConnectApplicationWillEnterForeground = @"DConnectApplicationWillEnterForeground";
NSString *const DConnectStoryboardName = @"DConnectSDK";

NSString *const DConnectProfileNameNetworkServiceDiscovery = @"networkServiceDiscovery";
NSString *const DConnectAttributeNameGetNetworkServices = @"getNetworkServices";
NSString *const DConnectAttributeNameCreateClient = @"createClient";
NSString *const DConnectAttributeNameRequestAccessToken = @"requestAccessToken";

/*!
 @brief レスポンス用のコールバックを管理するデータクラス.
 */
@interface DConnectResponseCallbackInfo : NSObject

@property (nonatomic, strong) DConnectResponseBlocks callback;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;

- (id) initWithCallback:(DConnectResponseBlocks) callback semaphore:(dispatch_semaphore_t) semaphore;
@end

@implementation DConnectResponseCallbackInfo

- (id) initWithCallback:(DConnectResponseBlocks)callback semaphore:(dispatch_semaphore_t)semaphore {
    
    self = [super init];
    if (self) {
        _callback = callback;
        _semaphore = semaphore;
    }
    
    return self;
}

@end



@interface DConnectManager ()
{
    dispatch_queue_t _requestQueue;
}

/*! @brief Websocketを管理するクラス.
 */
@property (nonatomic) DConnectWebSocket *mWebsocket;

/**
 * プロファイルを格納するマップ.
 */
@property (nonatomic) NSMutableDictionary *mProfileMap;

/**
 * リクエスト配送用のプロファイル.
 */
@property (nonatomic) DConnectManagerDeliveryProfile *mDeliveryProfile;

/**
 * Local OAuthのデータを管理するクラス.
 */
@property(nonatomic) DConnectLocalOAuthDB *mLocalOAuth;

/** イベントセッション管理テーブル. */
@property(nonatomic) DConnectEventSessionTable *mEventSessionTable;

/**
 * イベントブローカー.
 */
@property (nonatomic) DConnectEventBroker *mEventBroker;


/*!
 @brief DConnectManager起動フラグ。
 */
@property (nonatomic) BOOL mStartFlag;
/**
 * レスポンスとブロックを管理するマップ.
 */
@property (nonatomic, strong) NSMutableDictionary *mResponseBlockMap;



/**
 * 受け取ったリクエストの処理を行う.
 * @param[in] request リクエスト
 * @param[in,out] response レスポンス
 */
- (void) didReceiveRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response
                  callback:(DConnectResponseBlocks) callback;

/*!
 @brief 受け取ったリクエストを処理する。
 
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] callback コールバック
 */
- (void) executeRequest:(DConnectRequestMessage *)request
               response:(DConnectResponseMessage *)response
               callback:(DConnectResponseBlocks)callback;

/**
 * タイムアウトのレスポンスを返す.
 *
 * @param[in] key レスポンスのコード
 */
- (void) sendTimeoutResponseForKey:(NSString *)key;

- (BOOL) allowsOriginOfRequest:(DConnectRequestMessage *)requestMessage;

/*!
 @brief Profile,Interface,Attribute名を小文字に変換(キャメルケース等で大文字が含まれていた場合は小文字に変換する)。
 @param[in][out] request 変換対象のリクエスト。実行終了後にProfile,Interface,Attribute名を更新する。
 */
- (void)convertLowerProfileInterfaceAttributeWithRequest: (DConnectRequestMessage *)request;

/*!
 @brief APIパス名をデバイスプラグインのバージョンに合わせて新旧変換する。
 @param[in][out] request 変換対象のリクエスト。実行終了後にProfile,Interface,Attribute名を更新する。
 */
- (void) matchingProfileInterfaceAttributeWithRequest: (DConnectRequestMessage *)request;

/*!
 @brief 新旧名称変換テーブルを検索し該当するデータがあれば新旧どちらにマッチしたかを返す。
 @param[in] name 検索キーの名称
 @param [in] 新旧名称変換テーブル(key:旧名称 object:新名称)
 @retval nil nameに該当するデータなし
 @retval not nil nameが該当するデータあり。
 */
- (NSDictionary *) searchNameConvertTableWithName : (NSString *)name
                                     convertTable : (NSDictionary *)convertTable;


@end


@implementation DConnectManager

+ (DConnectManager *) sharedManager {
    static DConnectManager *sharedDConnectManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDConnectManager = [DConnectManager new];
    });
    return sharedDConnectManager;
}

- (NSString  *) managerUUID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *managerUUID = [defaults stringForKey:KEY_MANAGER_UUID];
    if (!managerUUID) {
        managerUUID = [[NSUUID UUID] UUIDString];
        [defaults setObject:managerUUID forKey:KEY_MANAGER_UUID];
        [defaults synchronize];
    }
    return managerUUID;
}

- (NSString  *) managerName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *managerName = [defaults stringForKey:KEY_MANAGER_NAME];
    if (!managerName) {
        int num = abs((int)arc4random() % 1000);
        managerName = [NSString stringWithFormat:@"Manager-%04d", num];
        [defaults setObject:managerName forKey:KEY_MANAGER_NAME];
        [defaults synchronize];
    }
    return managerName;
}

- (void)updateManagerName:(NSString*)name {
    if (name) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:name forKey:KEY_MANAGER_NAME];
        [defaults synchronize];
    }
}


- (BOOL) start {
    // 開始フラグをチェック
    if (self.mStartFlag) {
        return YES;
    }
    self.mStartFlag = YES;

    _requestQueue = dispatch_queue_create("org.deviceconnect.manager.queue.request", DISPATCH_QUEUE_SERIAL);
    
    _webServer = [DConnectServerManager new];
    _webServer.settings = self.settings;
    
    BOOL success = [_webServer startServer];
    if (!success) {
        self.mStartFlag = NO;
    }
    return success;
}

- (void) stop {
    if (!self.mStartFlag) {
        return;
    }
    self.mStartFlag = NO;
    [_webServer stopServer];
}

- (BOOL) isStarted {
    return self.mStartFlag;
}

- (void) sendRequest:(DConnectRequestMessage *)request
              isHttp:(BOOL)isHttp
            callback:(DConnectResponseBlocks)callback
{
    if (request) {
        __weak DConnectManager *_self = self;
        // iOS Message APIリクエストの実行をUIスレッドで行うと、
        // タイムアウト用のスレッド制御処理の影響でデバイスプラグインで
        // UIスレッドが使用できなくなるため、常に非同期で行う。
        dispatch_async(
                dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // DConnectManagerではsessionKeyにプラグインIDを
            // 付与するなどリクエストデータを書き換える処理が
            // 発生するため、呼び出し元でデータの齟齬が
            // 無いようにリクエストデータをコピーする。
            // Webからのリクエストの場合は呼び出しもとで
            // 当メソッドの呼び出し後にリクエストデータを参照することが
            // ないためネイティブからの呼び出し時のみコピーを行う。
            DConnectRequestMessage *tmpReq = isHttp ? request : [request copy];
            DConnectResponseMessage *response = [DConnectResponseMessage message];
            
            [_self didReceiveRequest:tmpReq response:response callback:callback];
        });
    } else {
        @throw @"request must not be nil.";
    }

}

- (void) sendRequest:(DConnectRequestMessage *) request callback:(DConnectResponseBlocks)callback {
    [self sendRequest:request isHttp:NO callback:callback];
}

- (void)makeEventMessage:(DConnectMessage *)event
                  plugin:(DConnectDevicePlugin *)plugin
{
    NSString *profile = [event stringForKey:DConnectMessageProfile];
    NSString *attribute = [event stringForKey:DConnectMessageAttribute];
    if (profile && [profile localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileName] == NSOrderedSame &&
        attribute && [attribute localizedCaseInsensitiveCompare:DConnectServiceDiscoveryProfileAttrOnServiceChange] == NSOrderedSame) {
        
        // サービスIDを付加する
        DConnectMessage *service = [event messageForKey:DConnectServiceDiscoveryProfileParamNetworkService];
        NSString *serviceId = [service stringForKey:DConnectServiceDiscoveryProfileParamId];
        NSString *did = [_mDeviceManager serviceIdByAppedingPluginIdWithDevicePlugin:plugin
                                                                           serviceId:serviceId];
        [service setString:did forKey:DConnectServiceDiscoveryProfileParamId];
        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DConnectManager class]];
        NSArray *evts = [mgr eventListForProfile:profile attribute:attribute];
        
        for (DConnectEvent *evt in evts) {
            [event setString:evt.origin forKey:DConnectMessageOrigin];

            if (self.mEventBroker) {
                [self.mEventBroker onEvent:event plugin:plugin];
            }
        }
    } else {
        
        // serviceIdにプラグインIDを付加
        NSString *serviceId = [event stringForKey:DConnectMessageServiceId];
        if (serviceId) {
            NSString *did = [_mDeviceManager serviceIdByAppedingPluginIdWithDevicePlugin:plugin
                                                                               serviceId:serviceId];
            [event setString:did forKey:DConnectMessageServiceId];
        }

        if (self.mEventBroker) {
            [self.mEventBroker onEvent:event plugin:plugin];
        }
    }
}

- (BOOL) sendEvent:(DConnectMessage *)event {
    return [self sendEvent:event authorized:YES];
}

- (BOOL) sendEvent:(DConnectMessage *)event authorized:(BOOL)authorized {
    NSString *accessToken = [event stringForKey:DConnectMessageAccessToken];
    NSString *pluginId;
    if (authorized) {
        pluginId = [self findRequestPluginId: accessToken];
    } else {
        pluginId = accessToken;
    }
    
    if (accessToken && pluginId) {
        NSArray *names = [pluginId componentsSeparatedByString:@"."];
        if (names.count > 0) {
            NSString *pluginId_ = names[0];
            DConnectDevicePlugin *plugin = [_mDeviceManager devicePluginForPluginId:pluginId_];
            if (!plugin) {
                DCLogW(@"Not found a plugin. pluginId=%@", pluginId);
                return NO;
            }
            
            if (![self.delegate respondsToSelector:@selector(manager:didReceiveDConnectMessage:)]) {
                [DConnectServerManager convertUriOfMessage:event];
            }
            [self makeEventMessage:event plugin:plugin];
        }
    } else {
        NSString *sessionKey = [event stringForKey:DConnectMessageSessionKey];
        if (sessionKey) {
            NSArray *names = [sessionKey componentsSeparatedByString:@"."];
            NSString *pluginId = names[names.count - 1];
            NSRange range = [sessionKey rangeOfString:pluginId];
            NSString *key;
            if (range.location != NSNotFound) {
                if (range.location == 0) {
                    key = sessionKey;
                } else {
                    key = [sessionKey substringToIndex:range.location - 1];
                }
            } else {
                key = sessionKey;
            }
            [event setString:key forKey:DConnectMessageSessionKey];
            
            DConnectDevicePlugin *plugin = [_mDeviceManager devicePluginForPluginId:pluginId];
            if (plugin) {
                DCLogW(@"Not found a plugin. pluginId=%@", pluginId);
                return NO;
            }

            if (![self.delegate respondsToSelector:@selector(manager:didReceiveDConnectMessage:)]) {
                [DConnectServerManager convertUriOfMessage:event];
            }
            [self makeEventMessage:event plugin:plugin];
        }
    }
    return NO;
}

- (void) sendResponse:(DConnectResponseMessage *)response {
    [response setString:self.productName forKey:DConnectMessageProduct];
    [response setString:self.versionName forKey:DConnectMessageVersion];
    
    DConnectResponseCallbackInfo *info = nil;
    @synchronized (_mResponseBlockMap) {
        info = [_mResponseBlockMap objectForKey:response.code];
        if (info) {
            [_mResponseBlockMap removeObjectForKey:response.code];
        }
    }
    
    if (info) {
        
        if (info.callback) {
            info.callback(response);
        }
        
        if (info.semaphore) {
            dispatch_semaphore_signal(info.semaphore);
        }
    }
}

- (BOOL) requiresOrigin {
    return self.settings.useOriginEnable;
}


#pragma mark - Private Methods -

- (id) init {
    self = [super init];
    if (self) {
        self.mStartFlag = NO;
        
        // DConnect設定を初期化
        _settings = [DConnectSettings new];
        self.productName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleDisplayName"];
        self.versionName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
        
        // イベント管理クラス
        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
                                setController:
                                    [DConnectDBCacheController
                                            controllerWithClass:key]];

        self.mDeviceManager = [DConnectDevicePluginManager new];
        self.mDeviceManager.dConnectDomain = DConnectApplicationLocalhostDConnect;
        self.mProfileMap = [NSMutableDictionary dictionary];
        self.mResponseBlockMap = [NSMutableDictionary dictionary];
        
        // Local OAuthのデータを管理するクラス
        self.mLocalOAuth = [DConnectLocalOAuthDB sharedLocalOAuthDB];
        
        // イベントブローカーの初期化
        self.mEventSessionTable = [DConnectEventSessionTable new];
        self.mEventBroker = [[DConnectEventBroker alloc] initWithContext:self table:self.mEventSessionTable localOAuth:self.mLocalOAuth pluginManager:self.mDeviceManager delegate:self.delegate];
        
        // デバイスプラグインの検索
        [self.mDeviceManager searchDevicePlugin];

        // プロファイルの追加
        [self addProfile:[DConnectManagerServiceDiscoveryProfile new]];
        [self addProfile:[DConnectManagerSystemProfile new]];
        [self addProfile:[DConnectFilesProfile new]];
        [self addProfile:[[DConnectManagerAuthorizationProfile alloc] initWithObject:self]];
        [self addProfile:[DConnectAvailabilityProfile new]];
        
        // デバイスプラグイン配送用プロファイル
        self.mDeliveryProfile = [DConnectManagerDeliveryProfile new];
        self.mDeliveryProfile.provider = self;
        self.mDeliveryProfile.eventBroker = self.mEventBroker;
        self.mDeliveryProfile.webSocket = self.mWebsocket;
    }
    return self;
}

- (void) executeRequest:(DConnectRequestMessage *)request
               response:(DConnectResponseMessage *)response
               callback:(DConnectResponseBlocks)callback {
    [request setString:self.productName forKey:DConnectMessageProduct];
    [request setString:self.versionName forKey:DConnectMessageVersion];
    
    DConnectProfile *profile = [self profileWithName:[request profile]];
    
    // 各プロファイルでリクエストを処理する。
    // dConnectManagerに指定のプロファイルがあれば、dConnectManagerに送る。
    BOOL processed = NO;
    if (profile) {
        processed = [profile didReceiveRequest:request response:response];
    }
    
    // 未だresponseが処理済みでなければ、
    // 送られてきたリクエストをデバイスプラグインに送る。
    if (!processed) {
        processed = [self.mDeliveryProfile didReceiveRequest:request response:response];
    }
    
    
    // TODO: ここの処理を修正する
    // 本当はtrueで行うのではないと思う。
    if (processed) {
        [self sendResponse:response];
    }
}

- (void) didReceiveRequest:(DConnectRequestMessage *) request
                  response:(DConnectResponseMessage *) response
                  callback:(DConnectResponseBlocks) callback
{
    __weak DConnectManager *_self = self;
    
    // プロファイル名を小文字に変換
    [self convertLowerProfileInterfaceAttributeWithRequest: request];
    
    // 常に待つので0を指定しておく
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * HTTP_REQUEST_TIMEOUT);
    
    // 非同期で呼び出せるよう、レスポンスに対するコールバックを保持しておく。
    [self addCallback:callback semaphore:semaphore forKey:response.code];
    
    dispatch_async(_requestQueue, ^{
        // 指定されたプロファイルを取得する
        NSString *profileName = [request profile];
        if (![_self allowsOriginOfRequest:request] && ![@"files" isEqualToString:profileName]) {
            [response setErrorToInvalidOrigin];
            DConnectProfile *profile = [_self profileWithName:profileName];
            if (profile && [profile isKindOfClass:[DConnectManagerAuthorizationProfile class]]) {
                DConnectManagerAuthorizationProfile *authProfile =
                (DConnectManagerAuthorizationProfile *) profile;
                [authProfile didReceiveInvalidOriginRequest:request response:response];
            }
            [_self sendResponse:response];
            return;
        }
        
        if (!profileName) {
            [response setErrorToNotSupportProfile];
            [_self sendResponse:response];
            return;
        }
        
        if (self.settings.useLocalOAuth) {
            @try {
                // Local OAuthチェック
                NSArray *scopes = DConnectIgnoreProfiles();
                NSString *accessToken = [request accessToken];
                LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:[DConnectManager class]];
                LocalOAuthCheckAccessTokenResult *result = [oauth checkAccessTokenWithScope:[profileName lowercaseString]
                                                                              specialScopes:scopes
                                                                                accessToken:accessToken];
                if ([result checkResult]) {
                    
                    // デバイスプラグインのバージョンに合わせて新旧変換する
                    [self matchingProfileInterfaceAttributeWithRequest: request];
                    
                    [_self executeRequest:request response:response callback:callback];
                } else {
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
                    [_self sendResponse:response];
                }
            } @catch (NSString *exception) {
                [response setErrorToInvalidRequestParameterWithMessage:exception];
                [_self sendResponse:response];
            }
        } else {
            // デバイスプラグインのバージョンに合わせて新旧変換する
            [self matchingProfileInterfaceAttributeWithRequest: request];
            
            [_self executeRequest:request
                         response:response
                         callback:callback];
        }
    });
    
    // 非同期で各プロファイルの処理を出来るようにするため、
    // sendResponseされるまで待つ。
    // タイムアウトの場合はタイムアウトエラーをレスポンスとして返す。
    long result = dispatch_semaphore_wait(semaphore, timeout);
    if (result != 0) {
        [self sendTimeoutResponseForKey:response.code];
    }
}

- (void) addCallback:(DConnectResponseBlocks)callback forKey:(NSString *)key {
    [self addCallback:callback semaphore:nil forKey:key];
}

- (void) addCallback:(DConnectResponseBlocks)callback semaphore:(dispatch_semaphore_t)semaphore
              forKey:(NSString *)key
{
    @synchronized (_mResponseBlockMap) {
        DConnectResponseCallbackInfo *info = [[DConnectResponseCallbackInfo alloc] initWithCallback:callback
                                                                                          semaphore:semaphore];
        _mResponseBlockMap[key] = info;
    }
}

- (void) removeCallbackForKey:(NSString *)key {
    @synchronized (_mResponseBlockMap) {
        [_mResponseBlockMap removeObjectForKey:key];
    }
}

- (NSString *) findRequestPluginId: (NSString *) accessToken {
    
    @synchronized(self.mDeviceManager) {
        for (DConnectDevicePlugin *plugin in [self.mDeviceManager devicePluginList]) {
            LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass:plugin.class];
            if (oauth) {
                LocalOAuthClientPackageInfo *info = [oauth findClientPackageInfoByAccessToken:accessToken];
                if (info) {
                    return plugin.pluginId;
                }
            }
        }
    }
    return nil;
}

#pragma mark - DConnectProfileProvider Methods -

- (void) addProfile:(DConnectProfile *) profile {
    NSString *profileName = [[profile profileName] lowercaseString];
    if (profileName) {
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
        
        [self.mProfileMap setObject:profile forKey:profileName];
        profile.provider = self;
        profile.plugin = nil;
    }
}

- (void) removeProfile:(DConnectProfile *)profile {
    NSString *name = [[profile profileName] lowercaseString];
    if (name) {
        [self.mProfileMap removeObjectForKey:name];
    }
}

- (DConnectProfile *) profileWithName:(NSString *)name {
    if (name) {
        NSString *lowerName = [name lowercaseString];
        return [_mProfileMap objectForKey:lowerName];
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

- (void) sendTimeoutResponseForKey:(NSString *)key { 
    DConnectResponseCallbackInfo *info = nil;
    @synchronized (_mResponseBlockMap) {
        info = [_mResponseBlockMap objectForKey:key];
        if (info) {
            [_mResponseBlockMap removeObjectForKey:key];
        }
    }
    if (info) {
        DConnectResponseMessage *timeoutResponse = [DConnectResponseMessage message];
        [timeoutResponse setErrorToTimeout];
        if (info.callback) {
            info.callback(timeoutResponse);   
        }
    }
}

- (BOOL) allowsOriginOfRequest:(DConnectRequestMessage *)requestMessage{
    BOOL isEnable = [self.settings useOriginEnable];
    if (!isEnable) {
        return YES;
    }
    NSString *originExp = [requestMessage origin];
    if (!originExp) {
        return NO;
    }
    if (![self.settings useOriginBlocking]) {
        return YES;
    }
    NSArray *ignores = DConnectIgnoreOrigins();
    if ([ignores containsObject:originExp]) {
        return YES;
    }
    id<DConnectOrigin> origin = [DConnectOriginParser parse:originExp];
    return [[DConnectWhitelist sharedWhitelist] allows:origin];
}

- (void)convertLowerProfileInterfaceAttributeWithRequest: (DConnectRequestMessage *)request {
    
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    NSString *interface = [request interface];
    
    if (profile != nil) {
        [request setProfile: [profile lowercaseString]];
    }
    if (attribute != nil) {
        [request setAttribute: [attribute lowercaseString]];
    }
    if (interface != nil) {
        [request setInterface:[interface lowercaseString]];
    }
}

- (void) matchingProfileInterfaceAttributeWithRequest: (DConnectRequestMessage *)request {
    
    // Profile新旧対応テーブル(key:新 / val:旧)
    NSDictionary *profileConvertTable = @{
                                         @"drivecontroller":@"drive_controller",
                                         @"filedescriptor":@"file_descriptor",
                                         @"mediaplayer":@"media_player",
                                         @"mediastreamrecording":@"mediastream_recording",
                                         @"omnidirectionalimage":@"omnidirectional_image",
                                         @"remotecontroller":@"remote_controller"
                                         };
    // attribute新旧対応テーブル(key:新 / val:旧)
    NSDictionary *attributeConvertTable = @{
                                           @"medialist":@"media_list",
                                           @"playstatus":@"play_status"
                                           };
    
    // リクエストのProfile,Attributeが新旧対応テーブルに存在しなければ変換しない
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    
    // ServiceIdが存在しない場合はなにもしないで終了
    if (serviceId == nil) {
        return;
    }
    
    // デバイスプラグインのプロファイル一覧が取得できなかったらなにもしないで終了
    DConnectDevicePlugin *dp = [self.mDeviceManager devicePluginForServiceId:serviceId];
    if (dp == nil) {
        return;
    }
    NSArray *dpProfiles = [dp profiles];
    if (dpProfiles == nil) {
        return;
    }
    
    // リクエストされたプロファイルが変換テーブル上に存在する？
    BOOL dpIsNew = NO;
    BOOL dpIsOld = NO;
    if (profile != nil) {
        NSDictionary *resultWithRequestProfile =
        [self searchNameConvertTableWithName : profile
                                convertTable : profileConvertTable];
        if (resultWithRequestProfile != nil) {
            
            // テーブルに存在する(新旧どちらにマッチしたかも分かる)
            BOOL requestProfileIsNew = [resultWithRequestProfile[MATCH_NEW_NAME]
                                        isEqualToString: MATCH_YES];
            BOOL requestProfileIsOld = [resultWithRequestProfile [MATCH_OLD_NAME]
                                        isEqualToString: MATCH_YES];
            NSString *newProfile = resultWithRequestProfile[NEW_NAME];
            NSString *oldProfile = resultWithRequestProfile[OLD_NAME];
            
            // デバイスプラグインが持っているプロファイルが新旧どちらなのか判定する
            
            if ([dp profileWithName: newProfile]) {
                dpIsNew = YES;
            }
            else if ([dp profileWithName: oldProfile]) {
                dpIsOld = YES;
            } else {
                // serviceIdが"test_service_id.DeviceTestPlugin.dconnect"のようになっているので"test_service_id"に変換する
                NSArray *domains = [serviceId componentsSeparatedByString:@"."];
                if (domains && [domains count] > 0) {
                    NSString *serviceId_ = domains[0];
                    NSArray *serviceProfiles = [dp serviceProfilesWithServiceId: serviceId_];
                    for (DConnectProfile *serviceProfile in serviceProfiles) {
                        NSString *serviceProfileName = [[serviceProfile profileName] lowercaseString];
                        if ([newProfile isEqualToString: serviceProfileName]) {
                            dpIsNew = YES;
                            break;
                        } else if ([oldProfile isEqualToString: serviceProfileName]) {
                            dpIsOld = YES;
                            break;
                        }
                    }
                }
            }
            
            // リクエストされたプロファイルとデバイスプラグインのプロファイルのレベルが合わない場合はデバイスプラグインに合わせて変換する
            if (requestProfileIsOld && dpIsNew) {
                [request setProfile: newProfile];
            }
            else if (requestProfileIsNew && dpIsOld) {
                [request setProfile: oldProfile];
            }
        }
    }
    
    // リクエストされたattributeが変換テーブル上に存在する？
    if (attribute != nil) {
        NSDictionary *resultWithRequestAttribute =
        [self searchNameConvertTableWithName : attribute
                                convertTable : attributeConvertTable];
        if (resultWithRequestAttribute != nil) {
            
            // テーブルに存在する(新旧どちらにマッチしたかも分かる)
            BOOL requestAttributeIsNew = [resultWithRequestAttribute[MATCH_NEW_NAME]
                                          isEqualToString: MATCH_YES];
            BOOL requestAttributeIsOld = [resultWithRequestAttribute[MATCH_OLD_NAME]
                                          isEqualToString: MATCH_YES];
            NSString *newAttribute = resultWithRequestAttribute[NEW_NAME];
            NSString *oldAttribute = resultWithRequestAttribute[OLD_NAME];
            
            // リクエストされたattributeとデバイスプラグインのattributeのレベルが合わない場合はデバイスプラグインに合わせて変換する
            if (requestAttributeIsOld && dpIsNew) {
                [request setAttribute: newAttribute];
            }
            else if (requestAttributeIsNew && dpIsOld) {
                [request setAttribute: oldAttribute];
            }
        }
    }
}

- (NSDictionary *) searchNameConvertTableWithName : (NSString *)name
                                     convertTable : (NSDictionary *)convertTable {
    
    // 新名称でマッチした
    NSString *oldName = convertTable[name];
    if (oldName != nil) {
        NSDictionary *result = @{
                                 MATCH_OLD_NAME:MATCH_NO,
                                 MATCH_NEW_NAME:MATCH_YES,
                                 OLD_NAME:oldName,
                                 NEW_NAME:name,
                                 };
        return result;
    }
    // 旧名称でマッチした
    NSArray *newNames = [convertTable allKeysForObject: name];
    if (newNames != nil && [newNames count] > 0) {
        NSString *newName = [newNames objectAtIndex: 0];
        
        NSDictionary *result = @{
                                 MATCH_OLD_NAME:MATCH_YES,
                                 MATCH_NEW_NAME:MATCH_NO,
                                 OLD_NAME:name,
                                 NEW_NAME:newName,
                                 };
        return result;
    }
    
    // 新名称も旧名称もマッチしなかった
    return nil;
}

- (NSArray*)devicePluginsList
{
    return [self.mDeviceManager devicePluginList];
}

- (NSString *)devicePluginIdForServiceId:(NSString *)serviceId
{
    DConnectDevicePlugin *plugin = [self.mDeviceManager devicePluginForServiceId:serviceId];
    return [plugin pluginId];
}

- (NSString *)iconFilePathForServiceId:(NSString *)serviceId isOnline:(BOOL)isOnline
{
    DConnectDevicePlugin *plugin = [self.mDeviceManager devicePluginForServiceId:serviceId];
    return [plugin iconFilePath:isOnline];

}
@end
