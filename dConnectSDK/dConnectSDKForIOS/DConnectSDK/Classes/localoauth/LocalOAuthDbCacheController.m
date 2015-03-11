//
//  LocalOAuthDbCacheController.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "LocalOAuthDbCacheController.h"

#import "DConnectSQLite.h"
#import "LocalOAuthProfileDao.h"
#import "LocalOAuthClientDao.h"
#import "LocalOAuthScopeDao.h"
#import "LocalOAuthTokenDao.h"

#import "LocalOAuth2Settings.h"
#import "LocalOAuthUtils.h"
#import "LocalOAuthDummy.h"
#import "LocalOAuthSampleUser.h"
#import "LocalOAuthScope.h"
#import "LocalOAuthSQLiteScopeInfo.h"

static int const DCONNECT_LOCALOAUTH_DB_VERSION = 1;

static NSString *const LocalOAuthDbCacheControllerDBName = @"__dconnect_localoauth.db";

@interface LocalOAuthDbCacheController()<DConnectSQLiteOpenHelperDelegate> {
    NSString *_key;
    DConnectSQLiteOpenHelper *_helper;
}

/* private method */
- (int) cleanupClient;
- (void)removeClientData: (NSString *)clientId
                database: (DConnectSQLiteDatabase *)database;
- (LocalOAuthClient *) addClientData: (LocalOAuthPackageInfo *)packageInfo
                  database: (DConnectSQLiteDatabase *)database;
- (NSArray *)scopesToAccessTokenScopes: (NSArray *)scopes;

/*!
    プロファイル配列に指定されたプロファイル名の
    データが存在すればそのデータを返す.
 
    @param[in] profiles プロファイルデータ配列
    @param[in] profileName プロファイル名
    @return
        not null: プロファイル名が一致するプロファイルデータが
                    存在すればそのポインタを返す。
        null: 存在しない。
 */
- (LocalOAuthSQLiteProfile *) findProfileByProfileName: (NSArray *)profiles
                                           profileName: (NSString *)profileName;

/*!
    SQLiteScopeInfo配列からプロファイル名が一致するデータを返す.
    @param[in] scopeInfos SQLiteScopeInfo配列
    @param[in] profileName プロファイル名
    @return not null: プロファイル名が一致したSQLiteScopeInfoデータ / null: 該当なし
 */
- (LocalOAuthSQLiteScopeInfo *) findScopeInfoByProfileName: (NSArray *)scopeInfos
                                               profileName: (NSString *)profileName;


/*!
    長時間利用されていないクライアントをクリーンアップする.<br>
    (1)clientsテーブルにあるがtokensテーブルにトークンが
        無い場合、clientsの登録日時がしきい値を
        越えていたら削除する。<br>
    (2)clientsテーブルにあるがtokensテーブルにトークンが
        有る場合、tokensの登録日時がしきい値を
        越えていたら削除する。<br>
    ※(2)の場合、トークンの有効期限内なら削除しない。
    @param[in] clientCleanupTime     クライアントをクリーンアップする未アクセス時間[sec].
 */
- (void) clientManager_cleanupClient:(int)clientCleanupTime
                            database:(DConnectSQLiteDatabase *)database;

- (int) clientManager_countClients: (DConnectSQLiteDatabase *)database ;
- (LocalOAuthClient *) clientManagerFindByPackageInfo:(LocalOAuthPackageInfo *)packageInfo
                                             database:(DConnectSQLiteDatabase *)database;

/*!
    クライアント作成.
    @param[in] packageInfo パッケージ情報
    @param[in] clientId クライアントID
    @param[in] clientType クライアントタイプ
    @param[in] redirectURIs リダイレクトURIs
    @param[in] properties プロパティ
    @return クライアントデータ
 */
- (LocalOAuthClient *) clientManager_createClient: (LocalOAuthPackageInfo *) packageInfo
                               clientId: (NSString *)clientId
                             clientType: (LocalOAuthClientType)clientType
                           redirectURIs: (NSArray *)redirectURIs
                             properties: (NSDictionary *)properties
                               database: (DConnectSQLiteDatabase *)database;

- (LocalOAuthClient *) clientManager_createClient: (LocalOAuthPackageInfo *)packageInfo
                             clientType: (LocalOAuthClientType)clientType
                           redirectURIs: (NSArray *)redirectURIs
                             properties: (NSDictionary *)properties
                               database: (DConnectSQLiteDatabase *)database;
- (NSArray *) GET_DEFAULT_SUPPORT_FLOW: (LocalOAuthClientType)clientType;
- (LocalOAuthToken *)tokenManager_findTokenByAccessToken: (NSString *)accessToken
                                                database: (DConnectSQLiteDatabase *)database;
- (LocalOAuthToken *)tokenManager_findTokenByClientUsername: client
                                                   username: username
                                                   database: database;
- (void) tokenManager_revokeAllTokens: (LocalOAuthClient *)client
                             database: (DConnectSQLiteDatabase *)database;
- (void) tokenManager_revokeAllTokensByUsername: (NSString *)username
                                       database: (DConnectSQLiteDatabase *)database;
- (void) tokenManager_revokeToken: (long long)tokenId
                         database: (DConnectSQLiteDatabase *)database;



- (BOOL)isIssueClientSecretToPublicClients;
- (NSString *) base64RandomValue: (int) byteCount;
- (NSString *) hexRandomValue: (int) byteCount;
- (NSString *) generateRawToken;


@end

@implementation LocalOAuthDbCacheController

#pragma mark - initialize
- (id) init {
    // 引数無しで初期化されたくないのでnilを返す。
    return nil;
}

- (id) initWithClass:(Class)clazz {
    return [self initWithKey:NSStringFromClass(clazz)];
}

- (id) initWithKey:(NSString *)key {
    self = [super init];
    
    if (self) {
        _key = key;
        NSString *name = [NSString stringWithFormat:@"%@%@", key, LocalOAuthDbCacheControllerDBName];
        _helper = [DConnectSQLiteOpenHelper helperWithDBName:name version:DCONNECT_LOCALOAUTH_DB_VERSION];
        _helper.delegate = self;
        // databaseを呼び出すとDBを作成するのでここで作成しておく。
        DConnectSQLiteDatabase *dbCache = [_helper database];
        [dbCache close];
    }
    
    return self;
}

#pragma mark - LocalOAuthDbCacheController


/* public */
/* LocalOAuth2Main.createClient() */
- (LocalOAuthClientData *) createClient:(LocalOAuthPackageInfo *)packageInfo {

    __block LocalOAuthClientData *clientData = nil;
    
    /*
     長時間使用されていなかったclientIdをクリーンアップする
     (DBアクセスしたついでに有効クライアント数も取得する) 
     */
    int clientCount = [self cleanupClient];
    
    /* クライアント数が上限まで使用されていれば例外発生 */
    if (clientCount >= LocalOAuth2Settings_CLIENT_MAX) {
        @throw @"AuthorizatonException(AuthorizatonException.CLIENT_COUNTS_IS_FULL)";
    }
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            
            /* パッケージ情報に対応するクライアントIDがすでに登録済なら破棄する */
            LocalOAuthClient *client = [self clientManagerFindByPackageInfo: packageInfo database:database];
            if (client != nil) {
                NSString *clientId = [client clientId];
                
                /* クライアントデータ削除 */
                [self removeClientData: clientId database:database];
                
                client = nil;
            }
            
            /* クライアントデータを新規生成して返す */
            client = [self addClientData: packageInfo database:database];
            NSString *clientId = [client clientId];
            
            clientData = [LocalOAuthClientData clientDataWithClientId:clientId];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return clientData;
}



/* public */
- (DConnectEventError) addProfile:(NSString *)profile {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            long long pId = [LocalOAuthProfileDao insertWithName:profile toDatabase:database];
            if (pId <= 0) {
                break;
            }
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return result;
}

/* public */
- (void)removeClientData: (NSString *)clientId
{
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            [LocalOAuthClientDao removeClientData:clientId database:database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
//    return result;
}

/* public */
- (LocalOAuthClient *)findClientByClientId: (NSString *)clientId {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    __block LocalOAuthClient *client = nil;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            client = [LocalOAuthClientDao findClientById: clientId
                                                database: database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return client;
}


/* public */
/* パッケージ情報からクライアントデータを取得 */
- (LocalOAuthAccessTokenData *) findAccessToken:(LocalOAuthPackageInfo *)packageInfo {

    __block DConnectEventError result = DConnectEventErrorFailed;
    __block LocalOAuthAccessTokenData *acccessTokenData = nil;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            
            /* パッケージ情報からクライアントデータを取得 */
            LocalOAuthClient *client = [LocalOAuthClientDao findClientByPackageInfo:packageInfo database:database];
            if (client != nil) {
                
                /* クライアントからトークンを取得する */
                LocalOAuthToken *token = [LocalOAuthTokenDao findToken:client
                                                              username:LOCALOAUTH_USERNAME
                                                              database:database];
                if (token != nil) {
                    NSString *accessToken = [token accessToken];
                    NSArray *accessTokenScopes = [self scopesToAccessTokenScopes: [token scope]];
                    long long timestamp = [token registrationDate];
                    acccessTokenData = [LocalOAuthAccessTokenData
                                                accessTokenDataWithAccessToken:accessToken
                                                                        scopes:accessTokenScopes
                                                                     timestamp:timestamp];
                }
            }
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return acccessTokenData;
}

/* public */
- (LocalOAuthToken *)findTokenByAccessToken: (NSString *)accessToken {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    __block LocalOAuthToken *token = nil;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            token =
                [self tokenManager_findTokenByAccessToken: accessToken
                                                 database:database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
    }];
    
    return token;
}

/* public */
- (NSArray *) findTokensByUsername: (NSString *)username {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    __block NSArray *tokens = nil;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            tokens = [self tokenManager_findTokensByUsername:username database:database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return tokens;
}

/* public */
- (LocalOAuthToken *) findTokenByClientUsername: (LocalOAuthClient *)client
                                username: (NSString *)username {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    __block LocalOAuthToken *token = nil;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            token = [self tokenManager_findTokenByClientUsername: client
                                                         username: username
                                                         database: database];
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return token;
}



/* public */
/* トークンのアクセス時間更新 */
- (void)updateTokenAccessTime: (LocalOAuthSQLiteToken *)token {

    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            long long tokenId = [token id_];
            [LocalOAuthTokenDao updateAccessTime: tokenId
                                        database: database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
}

/* public */
- (void)destroyAccessToken: (LocalOAuthPackageInfo *)packageInfo {

    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            LocalOAuthClient *client =
                    [self clientManagerFindByPackageInfo: packageInfo
                                                 database: database];
            
            [self tokenManager_revokeAllTokens: client database: database];
            
            DCLogD(@"destroyAccessToken()");
            DCLogD(@" - clientId: %@", [client clientId]);
            DCLogD(@" - packageName: %@", [packageInfo packageName]);
            if ([packageInfo serviceId] != nil) {
                DCLogD(@" - serviceId: %@", [packageInfo serviceId]);
            }
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
}

/* public */

- (void) revokeToken: (long long)tokenId {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            [self tokenManager_revokeToken: tokenId
                                  database: database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
}


/* public */

- (void) revokeAllTokens: (NSString *)username {
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            [self tokenManager_revokeAllTokensByUsername:username
                                                database: database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
}

/* public */
- (NSArray *) loadAllProfiles {
    
    __block NSArray *profiles = nil;
    
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            profiles = [LocalOAuthProfileDao load: database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
    }];
    
    return profiles;
}

- (LocalOAuthToken *)generateToken: (LocalOAuthClient *)client
                          username: (NSString *)username
                            scopes: (NSArray *) scopes
                   applicationName: (NSString *)applicationName {

    __block LocalOAuthToken *token = nil;
    __block DConnectEventError result = DConnectEventErrorFailed;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        do {
            [database beginTransaction];
            /* scopesのtimestampを現在時刻に設定する */
            long long currentTime = [LocalOAuthUtils getCurrentTimeInMillis];
            int scopeCount = [scopes count];
            for (int i = 0; i < scopeCount; i++) {
                LocalOAuthScope *scope = scopes[i];
                scope.timestamp = currentTime;
            }
            
            /* すでに発行されているトークンが存在するか */
            token = [self tokenManager_findTokenByClientUsername: client
                                                        username: username
                                                        database: database];
            NSMutableArray *profiles = [[LocalOAuthProfileDao load: database] mutableCopy];
            if (profiles == nil) {
                profiles = [NSMutableArray array];
            }
            for (int i = 0; i < scopeCount; i ++) {
                LocalOAuthScope *scope = scopes[i];
                if ([self findProfileByProfileName:profiles profileName:[scope scope]] == nil) {
                    LocalOAuthSQLiteProfile *profile = [[LocalOAuthSQLiteProfile alloc]init];
                    profile.profileName = [scope scope];
                    profile.id_ = [LocalOAuthProfileDao insertWithName: profile.profileName toDatabase:database];
                    [profiles addObject: profile];
                }
            }
            if (token == nil) {
                LocalOAuthSQLiteToken *sqliteToken = [[LocalOAuthSQLiteToken alloc]init];
                [sqliteToken setClientId: [client clientId]];
                [sqliteToken setUsername: username];
                [sqliteToken setScope: scopes];
                [sqliteToken setTokenType: OAuthResourceDefs_TOKEN_TYPE_BEARER];
                [sqliteToken setAccessToken: [self generateRawToken]];
                [sqliteToken setRefreshToken: [self generateRawToken]];
                [sqliteToken setApplicationName: applicationName];
                [sqliteToken setRegistrationDate: currentTime];
                [sqliteToken setAccessDate: currentTime];
                [sqliteToken setId: [LocalOAuthTokenDao insertWithTokenData:sqliteToken toDatabase:database]];
                token = [[LocalOAuthToken alloc]init];
                token.delegate = sqliteToken;
                
                /* スコープデータを登録 */
                long long tokensTokenId = [sqliteToken id_];
                for (int i = 0; i < scopeCount; i++) {
                    LocalOAuthScope *scope = scopes[i];
                    LocalOAuthSQLiteProfile *profile
                                            = [self findProfileByProfileName:profiles
                                                                 profileName:[scope scope]];
                    
                    LocalOAuthSQLiteScopeDb *scopeDB = [[LocalOAuthSQLiteScopeDb alloc]init:tokensTokenId
                                                                     profilesProfileId: profile.id_
                                                                             timestamp: [scope timestamp]
                                                                          expirePeriod: scope.expirePeriod];
                    [LocalOAuthScopeDao insertWithScopeData: scopeDB
                                                 toDatabase: database];
                }
                
            } else { /* 既存のtokenにscopeを追加し、トークンの有効期限を更新する */
                LocalOAuthSQLiteToken *sqliteToken = (LocalOAuthSQLiteToken *)token.delegate;
                NSArray *grantScopeInfos
                            = [LocalOAuthScopeDao loadScopes:[sqliteToken id_]
                                                    database:database]; /* SQLiteScopeInfo[] */
                NSMutableArray *addScopes = [NSMutableArray array];     /* SQLiteScopeInfo[] */
                NSMutableArray *existScopes = [NSMutableArray array];   /* SQLiteScopeInfo[] */
                for (NSUInteger i = 0; i < scopeCount; i++) {
                    LocalOAuthScope *scope = scopes[i];
                    
                    /* grantScopesに登録されているか */
                    LocalOAuthSQLiteScopeInfo *scopeInfo = [self findScopeInfoByProfileName: grantScopeInfos
                                                                                profileName: [scope scope]
                                                            ];
                    LocalOAuthSQLiteProfile *profile = [self findProfileByProfileName: profiles
                                                                          profileName: [scope scope]];
                    if (profile != nil) {
                        LocalOAuthSQLiteScopeInfo *appendScopeInfo =
                                [[LocalOAuthSQLiteScopeInfo alloc]initWithParameter: [sqliteToken id_]
                                                                  profilesProfileId: [profile id_]
                                                                          timestamp: [scope timestamp]
                                                                       expirePeriod: [scope expirePeriod]
                                                                        profileName: [scope scope]
                                 ];
                        if (scopeInfo == nil) {
                            /* 登録されていなければ追加スコープ配列に登録する */
                            [addScopes addObject: appendScopeInfo];
                        } else {
                            /* 登録されていれば既存スコープ配列に登録する */
                            [existScopes addObject: appendScopeInfo];
                        }
                    }
                }
                
                /* 追加スコープがあれば、DBにレコード追加する */
                if ([addScopes count] > 0) {
                    
                    /* token.getScope()とaddScopesのスコープ名を連結したnewScopesを作成する */
                    NSMutableArray *newScopes = [NSMutableArray arrayWithArray:[token scope]];
                    [newScopes addObjectsFromArray: addScopes];
                    
                    /* 追加分のscopeをDBに登録する */
                    NSUInteger addScopeCount = [addScopes count];
                    for (NSUInteger i = 0; i < addScopeCount; i++) {
                        LocalOAuthSQLiteScopeInfo *addScope = [addScopes objectAtIndex: i];
                        [LocalOAuthScopeDao insertWithScopeData:addScope toDatabase:database];
                    }
                    
                    /* tokenのスコープを更新する */
                    sqliteToken.scope = newScopes;
                }
                
                /* 既存スコープがあれば、DBのtimestampを更新する */
                NSUInteger existScopeCount = [existScopes count];
                for (NSUInteger i = 0; i < existScopeCount; i++) {
                    LocalOAuthSQLiteScopeInfo *existScope = [existScopes objectAtIndex: i];
                    
                    [LocalOAuthScopeDao updateTimestamp: [existScope tokensTokenId]
                                              profileId: [existScope profilesProfileId]
                                               database: database];
                }
                [LocalOAuthTokenDao updateAccessTime: [sqliteToken id_] database:database];
            }
            result = DConnectEventErrorNone;
            
        } while (NO);
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return token;
}

#pragma mark - LocalOAuthDbCacheController(private)


/* 
 長時間使用されていなかったclientIdをクリーンアップする
 (DBアクセスしたついでに有効クライアント数も取得する)
 */
- (int) cleanupClient {

    __block DConnectEventError result = DConnectEventErrorFailed;
    __block int clientCount = 0;
    
    [_helper execQueryInQueue:^(DConnectSQLiteDatabase *database) {
        
        if (!database) {
            return;
        }
        
        do {
            [database beginTransaction];
            
            [LocalOAuthClientDao cleanupClient:LocalOAuth2Settings_CLIENT_CLEANUP_TIME database:database];
            
            /* 有効クライアント数を取得する */
            clientCount = [self clientManager_countClients:database];
            
            result = DConnectEventErrorNone;
            
        } while (NO);
        
        if (result == DConnectEventErrorNone) {
            [database commit];
        } else {
            [database rollback];
        }
    }];
    
    return clientCount;
}

/* private */
/* クライアントデータ削除 */
- (void)removeClientData: (NSString *)clientId
                database: (DConnectSQLiteDatabase *)database {
    
    [LocalOAuthClientDao removeClientData: clientId
                                 database:database];
}

/* private */
- (LocalOAuthClient *) addClientData: (LocalOAuthPackageInfo *)packageInfo
                  database: (DConnectSQLiteDatabase *)database {
    
    NSArray *redirectURIs = @[DUMMY_REDIRECTURI];
    NSDictionary *params = @{};
    
    LocalOAuthClient *client =
    [self clientManager_createClient: packageInfo
                          clientType: CLIENT_TYPE_CONFIDENTIAL
                        redirectURIs: redirectURIs
                          properties: params
                            database: database];
    return client;
}

/* private */
/**
 * Scope[]からAccessTokenScope[]に変換して返す.
 * @param scopes Scope[]の値
 * @return AccessTokenScope[]の値
 */
- (NSArray *)scopesToAccessTokenScopes: (NSArray *)scopes {

    if (scopes != nil && [scopes count] > 0) {
        NSMutableArray *accessTokenScopes = [NSMutableArray array]; /* AccessTokenScopeの配列 */
        int scopeCount = [scopes count];
        for (int i = 0; i < scopeCount; i++) {
            LocalOAuthScope *scope = scopes[i];
            
            LocalOAuthAccessTokenScope *accessTokenScope =
                [LocalOAuthAccessTokenScope accessTokenScopeWithScope:[scope scope]
                                   expirePeriod:[scope expirePeriod]];
            [accessTokenScopes addObject: accessTokenScope];
        }
        return accessTokenScopes;
    }
    return nil;
}

/* private */
/* AbstractTokenManager.generateRawToken() */
- (NSString *)generateRawToken {
    NSString *value = [self hexRandomValue: 40];
    return value;
}



/* private */
/**
 * パッケージ情報をキーにDB検索し該当するクライアントを返す。(追加).
 * @param	packageInfo	パッケージ情報
 * @return	not null: パッケージ情報が一致するクライアント
            / null: パッケージ情報が一致するクライアント無し
 */
- (LocalOAuthClient *) clientManagerFindByPackageInfo: (LocalOAuthPackageInfo *)packageInfo
                                    database:(DConnectSQLiteDatabase *)database {
    
    LocalOAuthClient *client = [LocalOAuthClientDao findClientByPackageInfo:packageInfo database:database];
    return client;
}



/* private */
- (void) clientManager_cleanupClient: (int)clientCleanupTime database:(DConnectSQLiteDatabase *)database {
    
    [LocalOAuthClientDao cleanupClient: LocalOAuth2Settings_CLIENT_CLEANUP_TIME
                database: database];
}

/* private */
/**
 * 有効なclientsレコード数をカウントして返す.
 * @return 有効なclientsレコード数
 */
- (int) clientManager_countClients: (DConnectSQLiteDatabase *)database {
    return [LocalOAuthClientDao countClients: database];
}



/* private */
- (LocalOAuthClient *) clientManager_createClient: (LocalOAuthPackageInfo *)packageInfo
                             clientType: (LocalOAuthClientType)clientType
                           redirectURIs: (NSArray *)redirectURIs
                             properties: (NSDictionary *)properties
                               database: (DConnectSQLiteDatabase *)database {
    
    NSMutableDictionary *mutableProperties = nil;
    if (properties != nil) {
        mutableProperties = [properties mutableCopy];
    } else {
        mutableProperties = [NSMutableDictionary dictionary];
    }

    NSArray *flows = [mutableProperties objectForKey: PROPERTY_SUPPORTED_FLOWS];
    if (flows == nil) {
        flows = [self GET_DEFAULT_SUPPORT_FLOW : clientType];
        [mutableProperties setValue:flows forKey:PROPERTY_SUPPORTED_FLOWS];
    }
    
    /*
     * The authorization server MUST require the following clients to
     * register their redirection endpoint: o Public clients. o Confidential
     * clients utilizing the implicit grant type. (3.1.2.2. Registration
     * Requirements)
     */
    if ((clientType == CLIENT_TYPE_PUBLIC
         || (clientType == CLIENT_TYPE_CONFIDENTIAL &&
             [flows containsObject: [LocalOAuthResponseTypeUtil toString: RESPONSE_TYPE_TOKEN]]))
         && (redirectURIs == nil || [redirectURIs count] == 0)) {
        @throw @"RedirectionURI(s) required.";
    }
    
    NSString *clientId = [[[NSUUID alloc] init]UUIDString];
    
    LocalOAuthClient *client =
        [self clientManager_createClient: packageInfo
                                clientId: clientId
                              clientType: clientType
                            redirectURIs: redirectURIs
                              properties: mutableProperties
                                database: database];
    
    return client;
}


/* AbstractClientManager.defaultSupportedFlowを返す */
- (NSArray *) GET_DEFAULT_SUPPORT_FLOW: (LocalOAuthClientType)clientType {

    NSArray * const DEFAULT_SUPPORTED_FLOWS_PUBLIC = @[
        [LocalOAuthResponseTypeUtil toString: RESPONSE_TYPE_TOKEN]
    ];
    NSArray * const DEFAULT_SUPPORTED_FLOWS_CONFIDENTIAL = @[
        [LocalOAuthResponseTypeUtil toString: RESPONSE_TYPE_CODE],
        [LocalOAuthGrantTypeUtil toString: GRANT_TYPE_AUTHORIZATION_CODE],
        [LocalOAuthGrantTypeUtil toString: GRANT_TYPE_CLIENT_CREDENTIALS],
        [LocalOAuthGrantTypeUtil toString: GRANT_TYPE_REFRESH_TOKEN]
    ];
    
    if (clientType == CLIENT_TYPE_PUBLIC) {
        return DEFAULT_SUPPORTED_FLOWS_PUBLIC;
    } else if (clientType == CLIENT_TYPE_CONFIDENTIAL) {
        return DEFAULT_SUPPORTED_FLOWS_CONFIDENTIAL;
    }
    @throw @"clientType is unknown.";
}


/* private */
- (LocalOAuthClient *) clientManager_createClient: (LocalOAuthPackageInfo *) packageInfo
                                         clientId: (NSString *)clientId
                                       clientType: (LocalOAuthClientType)clientType
                                     redirectURIs: (NSArray *)redirectURIs
                                       properties: (NSDictionary *)properties
                                         database: (DConnectSQLiteDatabase *)database
{
    /* clientデータ設定 */
    LocalOAuthSQLiteClient *sqliteClient =
        [[LocalOAuthSQLiteClient alloc]init: clientId
                      packageInfo: packageInfo
                       clientType: clientType
                     redirectURIs: redirectURIs
                       properties: properties];
    
    /* DBに1件追加(失敗したらSQLiteException発生) */
    [LocalOAuthClientDao insertWithClientData: sqliteClient toDatabase:database];
    
    /* clientのdelegateにsqliteClientを設定して返す */
    LocalOAuthClient *client = [[LocalOAuthClient alloc]init];
    client.delegate = sqliteClient;
    return client;
}

/* private */
- (LocalOAuthToken *)tokenManager_findTokenByAccessToken: (NSString *)accessToken
                                                      database: (DConnectSQLiteDatabase *)database {
 
    LocalOAuthToken *token = [LocalOAuthTokenDao findTokenByAccessToken: accessToken
                                                               database: database];
    return token;
}

/* private */
- (LocalOAuthToken *)tokenManager_findTokenByClientUsername: client
                                                   username: username
                                                   database: database {
    
    LocalOAuthToken *token = [LocalOAuthTokenDao findToken: client
                                                  username: username
                                                  database: database];
    
    return token;
}


/* private */
- (NSArray *) tokenManager_findTokensByUsername: (NSString *)username
                                       database: (DConnectSQLiteDatabase *)database {
    
    NSArray *tokens = [LocalOAuthTokenDao findTokensByUsername: username
                                                      database: database];
    return tokens;
}

/* private */
- (void) tokenManager_revokeAllTokens: (LocalOAuthClient *)client
                             database: (DConnectSQLiteDatabase *)database {
    
    [LocalOAuthTokenDao deleteTokens: USERS_USER_ID
                            database: database];
}

- (void) tokenManager_revokeAllTokensByUsername: (NSString *)username
                             database: (DConnectSQLiteDatabase *)database {
    
    [LocalOAuthTokenDao deleteTokensByUsername: username
                            database: database];
}

- (void) tokenManager_revokeToken: (long long)tokenId
                             database: (DConnectSQLiteDatabase *)database {
    
    [LocalOAuthTokenDao deleteToken: tokenId
                            database: database];
}




// AbstractClientManager.isIssueClientSecretToPublicClients()
- (BOOL)isIssueClientSecretToPublicClients {
    return NO;
}

/*!
    BASE64でランダムに生成した文字列を返す.
    @param byteCount 生成するバイト数(1バイトあたり2文字分生成する)
    @return BASE64でランダムに生成した文字列(文字数=byteCount*2)
 */
- (NSString *)base64RandomValue: (int)byteCount {
    
    NSMutableString *strBase64 = [NSMutableString string];
    int loopCount = byteCount * 2;
    for (int i = 0; i < loopCount; i++) {
        /*  0 -  9: '0' - '9' */
        /* 10 - 35: 'A' - 'Z' */
        /* 36 - 61: 'a' - 'z' */
        /*      62: '+' */
        /*      63: '/' */
        NSString *charBase64 = nil;
        int randomSeed = arc4random() % 64;
        if (0 <= randomSeed && randomSeed <= 9) {
            charBase64 = [NSString stringWithFormat: @"%d", randomSeed];
        } else if (10 <= randomSeed && randomSeed <= 35) {
            unichar seed = 'a' + (randomSeed - 10);
            charBase64 = [[NSString alloc]initWithCharacters:&seed length:1];
        } else if (36 <= randomSeed && randomSeed <= 61) {
            unichar seed = 'A' + (randomSeed - 36);
            charBase64 = [[NSString alloc]initWithCharacters:&seed length:1];
        } else if (randomSeed == 62) {
            charBase64 = @"+";
        } else if (randomSeed == 63) {
            charBase64 = @"/";
        }
        [strBase64 appendString: charBase64];
    }
    
    return strBase64;
}

/*!
    16進数でランダムに生成した文字列を返す.
    @param byteCount 生成するバイト数(1バイトあたり2文字分生成する)
    @return BASE64でランダムに生成した文字列(文字数=byteCount*2)
 */
- (NSString *) hexRandomValue: (int)byteCount {
    
    NSMutableString *strHex = [NSMutableString string];
    for (int i = 0; i < byteCount; i++) {
        /* 乱数を取得して2桁の文字列を出力 */
        int randomSeed = arc4random() % 256;
        NSString *charHex = [NSString stringWithFormat: @"%02x", randomSeed];
        [strHex appendString: charHex];
    }
    
    return strHex;
}

/* private */
/* SQLiteTokenManager.findProfileByProfileName() */
- (LocalOAuthSQLiteProfile *) findProfileByProfileName: (NSArray *)profiles
                                           profileName: (NSString *)profileName {
    NSInteger profileCount = [profiles count];
    for (NSInteger i = 0; i < profileCount; i++) {
        LocalOAuthSQLiteProfile *profile = profiles[i];
        
        if ([profileName isEqualToString: [profile profileName]]) {
            return profile;
        }
    }
    return nil;
}

/* private */
- (LocalOAuthSQLiteScopeInfo *) findScopeInfoByProfileName: (NSArray *)scopeInfos
                                               profileName: (NSString *)profileName {
    
    NSUInteger scopeInfoCount = [scopeInfos count];
    for (NSUInteger i = 0; i < scopeInfoCount; i++) {
        LocalOAuthSQLiteScopeInfo *scopeInfo = scopeInfos[i];
        
        if ([[scopeInfo profileName] isEqualToString: profileName]) {
            return scopeInfo;
        }
    }
    
    return nil;
}

- (void) flush {
    // do nothing.
}

#pragma mark - DConnectSQLiteOpenHelperDelegate

- (void) openHelper:(DConnectSQLiteOpenHelper *)helper didCreateDatabase:(DConnectSQLiteDatabase *)database {
    
    @try {
        [LocalOAuthProfileDao createWithDatabase:database];
        [LocalOAuthClientDao createWithDatabase:database];
        [LocalOAuthScopeDao createWithDatabase:database];
        [LocalOAuthTokenDao createWithDatabase:database];
    }
    @catch (NSString *exception) {
        
        // 本来は上で閉じるがエラーを投げるのでとりあえず閉じておく。
        [database close];
        
        // 作成に失敗したらDBを削除。
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *path = paths[0];
        NSString *dbFilePath = [path stringByAppendingPathComponent:database.dbName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:dbFilePath error:nil];
        
        @throw @"ERROR: Could not create DB.";
    }
}

- (void) openHelper:(DConnectSQLiteOpenHelper *)helper didUpgradeDatabase:(DConnectSQLiteDatabase *)database
         oldVersion:(int)oldVersion
         newVersion:(int)newVersion
{
    // バージョン1なので特に処理無し。バージョンの変更がある場合は要対応。
    
}

#pragma mark - static

+ (LocalOAuthDbCacheController *) controllerWithClass:(Class)clazz {
    return [[LocalOAuthDbCacheController alloc] initWithClass:clazz];
}

+ (LocalOAuthDbCacheController *) controllerWithKey:(NSString *)key {
    return [[LocalOAuthDbCacheController alloc] initWithKey:key];
}

@end
