//
//  LocalOAuth2Main.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuth2Main.h"
#import "LocalOAuth2Settings.h"
#import "CipherAuthSignature.h"
#import "LocalOAuthDbCacheController.h"
#import "LocalOAuthUtils.h"
#import "LocalOAuthScope.h"
#import "LocalOAuthSQLiteToken.h"
#import "LocalOAuthConfirmAuthParams.h"
#import "LocalOAuthConfirmAuthViewController.h"
#import "LocalOAuthAccessTokenListViewController.h"
#import "LocalOAuthConfirmAuthRequest.h"
#import "LocalOAuthScopeUtil.h"

#import "DConnectProfile.h"
#import "DConnectDevicePlugin.h"


/** authorization_code. */
NSString *const LOCALOAUTH_AUTHORIZATION_CODE =@"authorization_code";

/** 例外メッセージ(初期化されていない) */
NSString *const EXCEPTON_NOT_BEEN_INITIALIZED = @"Not been initialized.";

/** 
 LocalOAuth2Mainインスタンスを格納する(key:クラス名(NSString*),
 value:インスタンス(LocalOAuth2Main*))
 */
static NSMutableDictionary *_instanceArray = nil;

/** 
 承認確認画面リクエストキュー
 (LocalOAuthConfirmAuthRequest*型の配列、
 アクセスする際はsynchronizedが必要).
 */
static NSMutableArray *_requestQueue = nil;

/** 承認確認画面リクエストキュー用Lockオブジェクト. */
static NSObject *_lockForRequstQueue = nil;


@interface LocalOAuth2Main() {
    
    /** キー(クラス名) */
    NSString *_key;
    
    /** 暗号化キー */
    NSString *_keyPair;
    
    /** 自動テストモードフラグ */
    BOOL _autoTestMode;
    
    /** UserManager. */
    LocalOAuthSampleUserManager *_userManager;
}



/*!
 クライアントデータ削除.
 
 @param[in] clientId クライアントID
 */
- (void) removeClientByClientId: (NSString *)clientId;

/*!
 アクセストークン発行処理.
 
 @param[in] params 承認確認画面のパラメータ
 @return アクセストークンデータ(アクセストークン,
        　有効期間(アクセストークン発行時間から使用可能な時間。
        　単位:ミリ秒) を返す。<br>
 */
- (LocalOAuthAccessTokenData *)publishAccessTokenWithParams:(LocalOAuthConfirmAuthParams *)params;

/*!
 トークン生成
 [Android版] SQLiteTokenManager.generateToken()
 @param[in] client
 @param[in] username
 @param[in] scopes Scope[]
 @param[in] applicationName
 @return トークン
 */
- (LocalOAuthToken *)generateToken:(LocalOAuthDbCacheController *)dbCache
                            client:(LocalOAuthClient *)client
                          username:(NSString *)username
                            scopes:(NSArray *) scopes
                   applicationName:(NSString *)applicationName;

/*!
 Scope[]からAccessTokenScope[]に変換して返す.
 [android版] LocalOAuthMain.scopesToAccessTokenScopes()
 @param scopes[in] Scope[]の値
 @return AccessTokenScope[]の値
 */
- (NSArray *) accessTokenScopesWithScopes: (NSArray *)scopes;

/*!
 クライアントデータ取得(なければAuthorizatonExceptionをスロー).
 
 @param[in] confirmAuthParams パラメータ
 @return クライアントデータ
 */
- (LocalOAuthClient *) findClientByParams:(LocalOAuthDbCacheController *)dbCache
                        confirmAuthParams:(LocalOAuthConfirmAuthParams *)confirmAuthParams;

/*!
 承認確認画面リクエスト数を取得.
 @return リクエスト数
 */
- (int) countRequest;

/*!
 承認確認画面リクエストをキューに追加.
 @param request[in] リクエスト
 */
- (void) enqueueRequest: (LocalOAuthConfirmAuthRequest *)request;

/*!
 キュー先頭の承認確認画面リクエストをキューから取得する.
 @return not null: 取得したリクエスト / null: キューにデータなし
 */
- (LocalOAuthConfirmAuthRequest *) pickupRequest;

/*!
 threadIdが一致する承認確認画面リクエストをキューから取得する。
 (キューから削除することも可能).
 @param isDeleteRequest[in] 
    true: スレッドIDが一致したリクエストを返す
          と同時にキューから削除する。
   false: 削除しない。
 @return 
    not null: 取り出されたリクエスト
        null: 該当するデータなし
            (存在しないthreadIdが渡された、
                    またはキューにデータ無し)
 */
- (LocalOAuthConfirmAuthRequest *) dequeueRequest:(long long)threadId
                                  isDeleteRequest: (BOOL)isDeleteRequest;

/*!
 アクセストークン発行確認画面を表示.
 @param request[in] アクセストークン発行確認画面表示リクエストデータ
 */
- (void) startConfirmAuthViewController: (LocalOAuthConfirmAuthRequest *)request;

/*!
 スレッドID取得.
 @return スレッドID
 */
- (LocalOAuthThreadId) getThreadId;


@end



@implementation LocalOAuth2Main


+ (LocalOAuth2Main *)sharedOAuthForClass: (Class)clazz {
    
    NSString *key = [clazz description];
    
    LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForKey: key];
    return oauth;
}

+ (LocalOAuth2Main *)sharedOAuthForKey: (NSString *)key {
    
    /* mInstanceArray初期化 */
    if (_instanceArray == nil) {
        _instanceArray = [NSMutableDictionary dictionary];
    }
    
    /* キューが初期化されていなければ初期化する */
    if (_requestQueue == nil) {
        _requestQueue = [NSMutableArray array];
        _lockForRequstQueue = [[NSObject alloc]init];
    }
    

    
    LocalOAuth2Main *instance = _instanceArray[key];
    if (instance != nil) {
        /* classに対応するインスタンスが存在すればそれを返す */
        return instance;
        
    }
    /* classに対応するインスタンスが無ければインスタンス作成して追加する */
    instance = [[LocalOAuth2Main alloc] initWithKey: key];
    _instanceArray[key] = instance;
    return instance;
}




/*!
 初期化処理.
 @param[in] key インスタンス識別キー
 @return LocalOAuthインスタンス
 */
- (LocalOAuth2Main *)initWithKey: (NSString *)key {
    
    self = [super init];
    
    _key = key;
    
    /* デフォルト値を設定 */
    [self generateCipherKey];
    [self setAutoTestModeWithFlag: NO];
    
    _userManager = [LocalOAuthSampleUserManager init];
    
    /* ユーザー追加 */
    [self addUserWithUserId: LOCALOAUTH_USER
                       pass: LOCALOAUTH_PASS];
    
    return self;
}

-(void) setAutoTestModeWithFlag: (BOOL)autoTestMode {
    _autoTestMode = autoTestMode;
}

-(BOOL) autoTestMode {
    return _autoTestMode;
}




- (void)addUserWithUserId: (NSString *)user pass:(NSString *)pass {
    
    LocalOAuthSampleUser *sampleUser = [_userManager addUser:user];
    [sampleUser setPassword: pass];
}

- (LocalOAuthClientData *)createClientWithPackageInfo: (LocalOAuthPackageInfo *)packageInfo {
    
    /* 引数チェック */
    if (packageInfo == nil) {
        @throw @"packageInfo is null.";
    } else if (packageInfo.packageName == nil) {
        @throw @"packageName is null.";
    } else if ([packageInfo.packageName length] <= 0) {
        @throw @"packageInfo is empty.";
    }
    
    /* クライアント追加 */
    LocalOAuthClientData *clientData = nil;
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        clientData = [dbCache createClient: packageInfo];
    }
    return clientData;
}

- (void)destroyClientWithClientId: (NSString *)clientId {
    
    /* 引数チェック */
    if (clientId  == nil) {
        @throw @"clientId is null.";
    }
    
    [self removeClientByClientId: clientId];
}

- (void) confirmPublishAccessTokenWithParams: (LocalOAuthConfirmAuthParams *)confirmAuthParams
                  receiveAccessTokenCallback: (ReceiveAccessTokenCallback)receiveAccessTokenCallback
                    receiveExceptionCallback: (ReceiveExceptionCallback)receiveExceptionCallback {
    
    /* 引数チェック */
    if (confirmAuthParams == nil) {
        @throw @"confirmAuthParams is nil.";
    } else if (receiveAccessTokenCallback == nil) {
        @throw @"receiveAccessTokenCallback is nil.";
    } else if (receiveExceptionCallback == nil) {
        @throw @"receiveExceptionCallback is nil.";
    } else if ([confirmAuthParams applicationName] == nil || [[confirmAuthParams applicationName] length] <= 0) {
        @throw @"ApplicationName is nil.";
    } else if ([confirmAuthParams clientId] == nil || [[confirmAuthParams clientId] length] <= 0) {
        @throw @"ClientId is nil.";
    } else if ([confirmAuthParams scope] == nil) {
        @throw @"Scope is nil.";
    } else if ([confirmAuthParams object] == nil) {
        @throw @"Object is nil.";
    }
    
    /* トークンの状態取得 */
    /* YES: 有効期限切れ / NO: 有効期限内 */
    BOOL isExpiredAccessToken = NO;
    /* YES: 要求スコープが全て含まれている / NO: 一部または全部含まれていない */
    BOOL isIncludeScope = NO;
    
    LocalOAuthToken *token = nil;
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        
        /* クライアントをDBから読み込み */
        LocalOAuthClient *client = [self findClientByParams: dbCache
                                 confirmAuthParams: confirmAuthParams];
        
        /* トークンをDBから読み込み */
        token = [dbCache findTokenByClientUsername: client
                                                      username: LOCALOAUTH_USERNAME];
    }
    
    if (token != nil) {
        /*
         アクセストークンが存在するか確認
         (全スコープの有効期限が切れていたら有効期限切れとみなす)
         */
        LocalOAuthSQLiteToken *sqliteToken = token.delegate;
        if ([sqliteToken isExpired]) {
            isExpiredAccessToken = YES;
        }
    }
    
    /* (a), (b)なら承認確認画面を表示する */
    if (token == nil /* (a) */
        || isExpiredAccessToken /* (a) */
        || !isIncludeScope) { /* (b) */
        
        /* デバイスプラグインオブジェクトを取得(デバイスプラグインでなければnil) */
        DConnectDevicePlugin *devicePlugin = nil;
        if ([confirmAuthParams isForDevicePlugin]) {
            devicePlugin = (DConnectDevicePlugin *) [confirmAuthParams object];
        }
        
        /* 表示文字列を取得する */
        NSArray * scopes = [confirmAuthParams scope];
        NSMutableArray *displayScopes = [NSMutableArray array];
        for (NSString *scope in scopes) {
            
            /*
             表示用スコープ名取得
             (標準名称またはデバイスプラグインが提供する名称、
             取れなければそのまま返す)
             */
            NSString *displayScope = [LocalOAuthScopeUtil displayScope: scope
                                                          devicePlugin: devicePlugin];
            
            [displayScopes addObject:displayScope];
        }
        
        /* リクエストデータを生成する */
        NSDate *currentTime = [NSDate date];
        LocalOAuthThreadId threadId = [self getThreadId];
        LocalOAuthConfirmAuthRequest *request =
                [[LocalOAuthConfirmAuthRequest alloc] initWithParameter: threadId
                                                                 params: confirmAuthParams
                                             receiveAccessTokenCallback: receiveAccessTokenCallback
                                               receiveExceptionCallback: receiveExceptionCallback
                                                            currentTime: currentTime
                                                          displayScopes: displayScopes];
        
        /* 
         キューが空なら、リクエストをキューに追加した後
         すぐにViewControllerを起動する
         */
        if ([self countRequest] <= 0) {
            [self enqueueRequest: request];
            [self startConfirmAuthViewController: request];
        /*
         空で無ければ、リクエストをキューに追加して
         先の処理が完了した後に処理する
         */
        } else {
            [self enqueueRequest: request];
        }
    }
}

- (LocalOAuthAccessTokenData *) findAccessTokenByPackageInfo: (LocalOAuthPackageInfo *)packageInfo {
    
    /* 引数チェック */
    if (packageInfo == nil) {
        @throw @"packageInfo is null.";
    } else if (packageInfo.packageName == nil) {
        @throw @"packageName is null.";
    }

    /* クライアント追加 */
    LocalOAuthAccessTokenData *acccessTokenData = nil;
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                                = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        acccessTokenData = [dbCache findAccessToken: packageInfo];
    }
    
    return acccessTokenData;
}

- (LocalOAuthCheckAccessTokenResult *)checkAccessTokenWithScope: (NSString *)scope
                                                  specialScopes: (NSArray *)specialScopes
                                                    accessToken: (NSString *)accessToken
{
    /* 引数チェック */
    if (scope == nil) {
        @throw @"scope is null.";
    }
    
    // 指定されたスコープの場合には無視する
    if ([specialScopes containsObject:scope]) {
        
        LocalOAuthCheckAccessTokenResult *result =
        [LocalOAuthCheckAccessTokenResult checkAccessTokenResultWithFlags: YES
                                     isExistAccessToken: YES
                                           isExistScope: YES
                                           isNotExpired: YES];
        return result;
    }
    
    BOOL existClientId = NO; /*
                                * YES: アクセストークンを発行したクライアントIDあり /
                                * NO: アクセストークンを発行したクライアントIDなし.
                                */
    BOOL existAccessToken = NO; /*
                                   * YES: アクセストークンあり / NO:
                                   * アクセストークンなし
                                   */
    BOOL existScope = NO; /* YES: スコープあり / NO: スコープなし */
    BOOL notExpired = NO; /* YES: 有効期限内 / NO: 有効期限切れ */
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                    = [[LocalOAuthDbCacheController alloc]
                                        initWithKey: _key];
        
        /* アクセストークンを元にトークンを検索する */
        LocalOAuthToken *oauthToken = [dbCache findTokenByAccessToken: accessToken];
        LocalOAuthSQLiteToken *token = (LocalOAuthSQLiteToken *)oauthToken.delegate;
        if (token != nil) {
            existAccessToken = YES; /* アクセストークンあり */

            NSArray *scopes = [token scope]; /* Scope[] */
            NSUInteger scopeCount = [scopes count];
            for (NSUInteger i = 0; i < scopeCount; i++) {
                LocalOAuthScope *oauthScope = scopes[i];
                
                // リリースビルド時には無効になる
#ifdef DEBUG
                /* token.scopeに"*"が含まれていたら、どんなスコープにもアクセスできる */
                if ([[oauthScope scope] isEqualToString: @"*"]) {
                    existScope = YES; /* スコープあり */
                    notExpired = YES; /* 有効期限 */
                    break;
                }
#endif
                if ([[oauthScope scope] isEqualToString: scope]) {
                    existScope = YES; /* スコープあり */
                    if ([oauthScope expirePeriod] == 0) {
                        /* 
                         有効期限0の場合は、トークン発行から1分以内の
                         初回アクセスなら有効期限内とする
                         */
                        long long expiredTime
                                = [LocalOAuthUtils getCurrentTimeInMillis]
                                            - [token registrationDate];
                        if (0 <= expiredTime && expiredTime
                                    <= (LocalOAuth2Settings_ACCESS_TOKEN_GRACE_TIME * MSEC)
                            && [token isFirstAccess]) {
                            notExpired = YES;
                        }
                    } else if ([oauthScope expirePeriod] > 0) {
                        /* 
                         有効期限1以上の場合は、
                         トークン発行からの経過時間が有効期限内かを判定して返す
                         */
                        notExpired = ![oauthScope isExpired];
                    } else {
                        /* 有効期限にマイナス値が設定されていたら、有効期限切れとみなす */
                        notExpired = NO;
                    }
                    break;
                }
            }

            /* specialScopesに登録されていればスコープチェックOKとする */
            if (!existScope && specialScopes != nil) {
                NSUInteger specialScopeCount = [specialScopes count];
                for (NSUInteger i = 0; i < specialScopeCount; i++) {
                    NSString *specialScope = specialScopes[i];
                    
                    if ([scope isEqualToString:specialScope]) {
                        existScope = YES; /* スコープあり */
                        notExpired = YES; /* 有効期限 */
                        break;
                    }
                }
            }

            /* このトークンを発行したクライアントIDが存在するかチェック */
            if ([dbCache findClientByClientId: [token clientId]] != nil) {
                existClientId = YES;
            }
            
            /* トークンのアクセス時間更新 */
            [dbCache updateTokenAccessTime: token];
        }
    }
    
    LocalOAuthCheckAccessTokenResult *result =
    [LocalOAuthCheckAccessTokenResult checkAccessTokenResultWithFlags: existClientId
                                 isExistAccessToken: existAccessToken
                                       isExistScope: existScope
                                       isNotExpired: notExpired];
    if (![result checkResult]) {
        DCLogD(@"checkAccessToken() - error.");
        DCLogD(@" - isExistClientId: %d", isExistClientId);
        DCLogD(@" - isExistAccessToken: %d", isExistAccessToken);
        DCLogD(@" - isExistScope: %d", isExistScope);
        DCLogD(@" - isNotExpired: %d", isNotExpired);
        DCLogD(@" - accessToken: %@", accessToken);
        DCLogD(@" - scope: %@", scope);
    }
    
    return result;
}

- (void)destroyAccessTokenByPackageInfo: (LocalOAuthPackageInfo *)packageInfo {
    
    /* 引数チェック */
    if (packageInfo == nil) {
        @throw @"packageInfo is null.";
    } else if (packageInfo.packageName == nil) {
        @throw @"packageName is null.";
    }
    
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                                = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        [dbCache destroyAccessToken: (LocalOAuthPackageInfo *)packageInfo];
    }
}

- (LocalOAuthClientPackageInfo *) findClientPackageInfoByAccessToken: (NSString *)accessToken
{
    
    /* 引数チェック */
    if (accessToken == nil) {
        @throw @"accessToken is null.";
    }
    
    LocalOAuthClientPackageInfo *clientPackageInfo = nil;

    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                    = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        LocalOAuthToken *token = [dbCache findTokenByAccessToken: accessToken];
        LocalOAuthSQLiteToken *sqliteToken = (LocalOAuthSQLiteToken *)token.delegate ;
        if (token != nil) {
            NSString *clientId = [sqliteToken clientId];
            if (clientId != nil) {
                LocalOAuthClient *client = [dbCache findClientByClientId: clientId];
                if (client != nil) {
                    clientPackageInfo = [[LocalOAuthClientPackageInfo alloc]
                                                initWithPackageInfo:[client packageInfo]
                                                           clientId: clientId];
                }
            }
        }
    }
    
    return clientPackageInfo;
}

- (void) generateCipherKey {
    
    _keyPair = nil;    /* 未実装 */
}


- (NSString *) cipherPublicKey {
    
    return nil;         /* 未実装 */
}

- (void) startAccessTokenListActivity {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSBundle *bundle = DCBundle();
        UIStoryboard *storyBoard;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPhone",
                                                           DConnectStoryboardName]
                                           bundle:bundle];
        } else{
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPad",
                                                           DConnectStoryboardName]
                                           bundle:bundle];
        }
        
        UINavigationController *top = [storyBoard instantiateViewControllerWithIdentifier:@"TokenList"];
        LocalOAuthAccessTokenListViewController *accessTokenListViewController
        = (LocalOAuthAccessTokenListViewController *) top.viewControllers[0];
        
        [accessTokenListViewController setKey: _key];
        
        UIViewController *rootView;
        DCPutPresentedViewController(rootView);
        [rootView presentViewController:top animated:YES completion:nil];
    });
}

- (NSArray *) allAccessTokens {
    
    NSArray *tokens = nil;  /* LocalOAuthSQLiteToken[] */
    
    /* LocalOAuthが保持しているクライアントシークレットを取得 */
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                        = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        tokens = [dbCache findTokensByUsername: LOCALOAUTH_USERNAME];
    }
    
    return tokens;
}

- (void) destroyAccessTokenByTokenId: (long long)tokenId {
    
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        [dbCache revokeToken: tokenId];
    }
}

- (void) destroyAllAccessTokens {
    
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache
                    = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        [dbCache revokeAllTokens: LOCALOAUTH_USERNAME];
    }
}

- (LocalOAuthClient *)findClientByClientId: (NSString *)clientId {
    
    LocalOAuthClient *client = nil;
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        client = [dbCache findClientByClientId: clientId];
    }
    return client;
}

-(void) removeClientByClientId: (NSString *)clientId {
    
    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        [dbCache removeClientData: clientId];
    }
}

- (LocalOAuthAccessTokenData *)publishAccessTokenWithParams:  (LocalOAuthConfirmAuthParams *)params {

    @synchronized(self) {
        LocalOAuthDbCacheController *dbCache = [[LocalOAuthDbCacheController alloc]initWithKey: _key];
        NSString *clientId = [params clientId];
        LocalOAuthClient *client = [dbCache findClientByClientId: clientId];
        if (client != nil) {
            NSArray *scopes = [params scope];    /* (NSString *)[] */

            /* デバイスプラグインならスコープ有効期限を取得する */
            NSMutableDictionary *supportProfiles = [NSMutableDictionary dictionary];
            if (params.isForDevicePlugin) {
                DConnectDevicePlugin *devicePlugin = (DConnectDevicePlugin *)params.object;
                
                for (NSString *scope in scopes) {
                    DConnectProfile *profile = [devicePlugin profileWithName: scope];
                    if (profile) {
                        /* 
                         デバイスプラグインから分単位の有効期限を受け取り、
                         秒単位に変換して保持する
                         */
                        long long expirePeriod = profile.expirePeriod * MINUTE;
                        NSNumber *expired = [NSNumber numberWithLongLong: expirePeriod];
                        supportProfiles[scope] = expired;
                    }
                }
            }
            
            /* スコープを登録(Scope型に変換して有効期限を追加する) */
            NSMutableArray *settingScopes = [NSMutableArray array]; /* (LocalOAuthScope*)[] */
            for (NSString *scope in scopes) {
                
                /* 
                 デバイスプラグインならxmlファイルに有効期限が
                 存在すれば取得して使用する(無ければデフォルト値)
                 */
                long long expirePeriod = LocalOAuth2Settings_DEFAULT_TOKEN_EXPIRE_PERIOD;
                if (supportProfiles != nil) {
                    NSNumber *expired = [supportProfiles objectForKey:scope];
                    if (expired != nil) {
                        expirePeriod = [expired longLongValue];
                    }
                }
                
                LocalOAuthScope *oauthScope =
                        [[LocalOAuthScope alloc]initWithScope:scope
                                                    timestamp:[LocalOAuthUtils getCurrentTimeInMillis]
                                                 expirePeriod:expirePeriod];
                [settingScopes addObject: oauthScope];
            }
            
            NSString *username = LOCALOAUTH_USERNAME;
            NSString *applicationName = [params applicationName];
            
            LocalOAuthToken *token =
                    [self generateToken: dbCache
                                 client: (LocalOAuthClient *)client
                               username: (NSString *)username
                                 scopes: (NSArray *) settingScopes
                        applicationName: (NSString *)applicationName
                     ];
            
            
            /* アクセストークンデータを返す */
            NSString *accessToken = [token accessToken];
            NSArray *accessTokenScopes =    /* AccessTokenScope[] */
                    [self accessTokenScopesWithScopes: [token scope]];
            long long timestamp = [token registrationDate];
            LocalOAuthAccessTokenData *acccessTokenData =
            [LocalOAuthAccessTokenData accessTokenDataWithAccessToken:accessToken
                                                               scopes:accessTokenScopes
                                                            timestamp:timestamp];
            return acccessTokenData;
        }
    }
    return nil;
}

- (LocalOAuthToken *)generateToken: (LocalOAuthDbCacheController *)dbCache
                            client: (LocalOAuthClient *)client
                          username: (NSString *)username
                            scopes: (NSArray *) scopes
                   applicationName: (NSString *)applicationName {
    
    LocalOAuthToken *token = [dbCache generateToken: client
                                      username: username
                                        scopes: scopes
                               applicationName: applicationName];
    return token;
}


- (NSArray *) accessTokenScopesWithScopes: (NSArray *)scopes {
    
    if (scopes != nil && [scopes count] > 0) {
        NSMutableArray *accessTokenScopes = [NSMutableArray array]; /* AccessTokenScope[] */
        
        NSUInteger scopeCount = [scopes count];
        for (NSUInteger i = 0; i < scopeCount; i++) {
            LocalOAuthScope *scope = scopes[i];
            LocalOAuthAccessTokenScope *accessTokenScope =
            [LocalOAuthAccessTokenScope accessTokenScopeWithScope: [scope scope]
                                         expirePeriod: [scope expirePeriod]
             ];
            [accessTokenScopes addObject: accessTokenScope];
        }
        return accessTokenScopes;
    }
    return nil;
}

- (LocalOAuthClient *) findClientByParams: (LocalOAuthDbCacheController *)dbCache
                        confirmAuthParams: (LocalOAuthConfirmAuthParams *)confirmAuthParams {
    LocalOAuthClient *client = [dbCache findClientByClientId: [confirmAuthParams clientId]];
    if (client == nil) {
        @throw @"AuthorizatonException.CLIENT_NOT_FOUND";
    }
    return client;
}


- (int) countRequest {
    int count = 0;
    @synchronized (_lockForRequstQueue) {
        if (_requestQueue != nil) {
            count = [_requestQueue count];
        }
    }
    
    return count;
}

- (void) enqueueRequest: (LocalOAuthConfirmAuthRequest *)request {
    @synchronized (_lockForRequstQueue) {
        [_requestQueue addObject:request];
        
    }
}

- (LocalOAuthConfirmAuthRequest *) pickupRequest {
    
    LocalOAuthConfirmAuthRequest *request = nil;
    
    @synchronized (_lockForRequstQueue) {
        
        int requestCount = [_requestQueue count];
        
        /* 先頭キューを返す */
        if (requestCount > 0) {
            request = [_requestQueue objectAtIndex: 0];
        }
    }
    
    return request;
}

- (LocalOAuthConfirmAuthRequest *) dequeueRequest: (long long)threadId
                                  isDeleteRequest: (BOOL)isDeleteRequest {
    
    LocalOAuthConfirmAuthRequest *request = nil;
    
    @synchronized (_lockForRequstQueue) {
        
        /* スレッドIDが一致するリクエストデータを検索する */
        int dequeueIndex = -1;
        int requestCount = [_requestQueue count];
        for (int i = 0; i < requestCount; i++) {
            LocalOAuthConfirmAuthRequest *req = [_requestQueue objectAtIndex: i];
            if ([req threadId] == threadId) {
                dequeueIndex = i;
                break;
            }
        }
        
        if (dequeueIndex >= 0) {
            if (isDeleteRequest) {
                /* スレッドIDに対応するリクエストデータを取得し、キューから削除する */
                request = [_requestQueue objectAtIndex: dequeueIndex];
                [_requestQueue removeObjectAtIndex: dequeueIndex];
            } else {
                /* スレッドIDに対応するリクエストデータを取得 */
                request = [_requestQueue objectAtIndex: dequeueIndex];
            }
        }
    }
    
    return request;
}

- (void) startConfirmAuthViewController: (LocalOAuthConfirmAuthRequest *)request {
    
    void (^blk)() = ^() {
        /* StoryboardからUIViewControllerを取り出してパラメータを設定し表示する */
        UIViewController *topViewController;
        DCPutPresentedViewController(topViewController);
        NSBundle *bundle = DCBundle();
        UIStoryboard *storyBoard;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPhone",
                                                           DConnectStoryboardName]
                                           bundle:bundle];
        } else{
            storyBoard = [UIStoryboard storyboardWithName:[NSString stringWithFormat:@"%@-iPad",
                                                           DConnectStoryboardName]
                                           bundle:bundle];
        }
        
        UIViewController *viewController = [storyBoard instantiateViewControllerWithIdentifier:@"Confirm"];
        LocalOAuthConfirmAuthViewController *confirmAuthViewController
        = (LocalOAuthConfirmAuthViewController *)[((UINavigationController *)viewController) viewControllers][0];
        
        [confirmAuthViewController setParameter: [request params]
                                 displayScopes : [request displayScopes]
                                setAutoTestMode: _autoTestMode
                               approvalCallback:
         ^(BOOL isApproval) {
             [topViewController dismissViewControllerAnimated:YES completion:^() {
                 /* 終了アニメーションが終わったら処理を実行する */
                 
                 /* 応答が届いたのでリクエストをキューから削除する */
                 [self dequeueRequest:[request threadId] isDeleteRequest: true];
                 
                 if (isApproval) {
                     /* 承認された */
                     @try {
                         /* アクセストークン発行処理 */
                         LocalOAuthAccessTokenData *accessTokenData =
                         [self publishAccessTokenWithParams: [request params]];
                         
                         /* 承認された */
                         [request receiveAccessTokenCallback](accessTokenData);
                         
                         /* キューにリクエストが残っていれば、
                          次のキューを取得してActivityを起動する
                          */
                         LocalOAuthConfirmAuthRequest *nextRequest
                                    = [self pickupRequest];
                         if (nextRequest != nil) {
                             [self startConfirmAuthViewController: nextRequest];
                         }
                         
                     } @catch (NSString *error) {
                         /* 例外 */
                         [request receiveExceptionCallback](error);
                     }
                 } else {
                     /* 拒否された */
                     [request receiveExceptionCallback](nil);
                 }
             }];
         }
         ];
        [topViewController presentViewController:viewController animated:YES completion:nil];
    };
    
    /* mainThreadならブロックをそのまま実行、mainThreadでなければmainThreadから実行 */
    if ([[NSThread currentThread] isMainThread]) {
        blk();
    } else {
        dispatch_async(dispatch_get_main_queue(), blk);
    }
}

- (LocalOAuthThreadId) getThreadId {
    return pthread_mach_thread_np(pthread_self());
}

@end
