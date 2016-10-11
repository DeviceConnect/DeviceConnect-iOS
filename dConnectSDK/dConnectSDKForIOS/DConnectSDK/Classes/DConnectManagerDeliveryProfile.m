//
//  DConnectManagerDeliveryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManagerDeliveryProfile.h"
#import "DConnectMessage+Private.h"
#import "DConnectManager+Private.h"
#import "DConnectDevicePluginManager.h"
#import "DConnectAuthorizationProfile.h"
#import "DConnectServiceDiscoveryProfile.h"
#import "DConnectSystemProfile.h"
#import "DConnectUtil.h"
#import "DConnectLocalOAuthDB.h"
#import "DConnectConst.h"

@interface DConnectManagerDeliveryProfile ()

/*!
 @brief デバイスプラグインにLocalOAuth認証を行う。
 
 @param[in] plugin 認証を行うデバイスプラグイン
 @param[in] origin オリジン
 @param[in] serviceId サービスID
 
 @retval アクセストークン
 @retval nil 認証失敗
 */
- (NSString *) authorizationToDevicePlugin:(DConnectDevicePlugin *)plugin
                                    origin:(NSString *)origin
                                 serviceId:(NSString *)serviceId;

/*!
 @brief デバイスプラグイン上にアプリケーション用のクライアントデータを作成する。
 
 @param[in] plugin デバイスプラグイン
 @param[in] origin アプリケーションのオリジン
 @param[in] serviceId サービスID
 
 @retval レスポンス
 */
- (DConnectResponseMessage *) createClientToDevicePlugin:(DConnectDevicePlugin *)plugin
                                                  origin:(NSString*)origin
                                               serviceId:(NSString*)serviceId;

/*!
 @brief デバイスプラグインに対してアクセストークンを要求する。
 
 @param[in] plugin デバイスプラグイン
 @param[in] origin アプリケーションのオリジン
 @param[in] serviceId サービスID
 @param[in] clientId クライアントID
 
 @retval デバイスプラグインからのレスポンス
 */
- (DConnectResponseMessage *) requestAccessTokenToDevicePlugin:(DConnectDevicePlugin *)plugin
                                                        origin:(NSString *)origin
                                                     serviceId:(NSString *)serviceId
                                                      clientId:(NSString *)clientId;

/*!
 @brief 使用するプロファイル一覧を取得する。
 @param[in] plugin プロファイル一覧を取得するデバイスプラグイン
 @param[in] serviceId サービスID
 @retval プロファイル一覧
 */
- (NSArray *)getScopeFromDevicePlugin:(DConnectDevicePlugin *)plugin
                            serviceId:(NSString *)serviceId;

@end



@implementation DConnectManagerDeliveryProfile

- (NSString *) profileName {
    return @"*";
}

- (BOOL) didReceiveRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    // MARK: wakeup以外にも例外的な動きをするProfileがある場合には再検討すること。
    // System Profileのwakeupは例外的にpluginIdで宛先を決める
    // ここでは、/system/device/wakeupの場合のみpluginIdを使用するようにする
    NSString *profileName = [request profile];
    if (profileName && [profileName localizedCaseInsensitiveCompare: DConnectSystemProfileName] == NSOrderedSame) {
        NSString *inter = [request interface];
        NSString *attr = [request attribute];
        if (inter && [inter localizedCaseInsensitiveCompare: DConnectSystemProfileInterfaceDevice] == NSOrderedSame
            && attr && [attr localizedCaseInsensitiveCompare: DConnectSystemProfileAttrWakeUp] == NSOrderedSame) {
            serviceId = [request pluginId];
            if (!serviceId) {
                [response setErrorToInvalidRequestParameterWithMessage:@"pluginId is required."];
                return YES;
            }
        }
    }
    
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else {
        // 各デバイスプラグインに配送
        DConnectManager *mgr = (DConnectManager *) self.provider;
        DConnectDevicePlugin *plugin = [mgr.mDeviceManager devicePluginForServiceId:serviceId];
        if (plugin) {
            NSString *origin = [request stringForKey:DConnectMessageOrigin];
            if (self.eventBroker) {
                [self.eventBroker onRequest: request plugin: plugin webSocket:self.webSocket];
            }
            
            // セッションキーにデバイスプラグインIDを付加する
            NSString *sessionKey = [request stringForKey:DConnectMessageSessionKey];
            if (sessionKey) {
                NSMutableString *session = [NSMutableString stringWithString:sessionKey];
                [session appendString:@"."];
                [session appendString:NSStringFromClass([plugin class])];
                [request setString:session forKey:DConnectMessageSessionKey];
            }
            
            // サービスIDからデバイスプラグインIDを削除してから、
            // 各デバイスプラグインに配送する
            NSString *did = [mgr.mDeviceManager spliteServiceId:serviceId byDevicePlugin:plugin];
            DConnectRequestMessage *copyRequest = [request copy];
            [copyRequest setString:did forKey:DConnectMessageServiceId];
            
            // アクセストークンの取得
            // 特定のプロファイルはアクセストークン無しでもアクセスできるので無視する
            NSString *accessToken = nil;
            NSArray *scopes = DConnectPluginIgnoreProfiles();
            if (![scopes containsObject:profileName]) {
                accessToken = [self authorizationToDevicePlugin:plugin
                                                         origin:origin
                                                      serviceId:serviceId];
                if (accessToken) {
                    [copyRequest setString:accessToken forKey:DConnectMessageAccessToken];
                } else {
                    // アクセストークンの取得に失敗
                    [response setErrorToAuthorization];
                    return YES;
                }
            }

            // 実際にデバイスプラグインに送信
            BOOL send = [plugin didReceiveRequest:copyRequest response:response];
            if (send && [response result] == DConnectMessageResultTypeError) {
                DConnectLocalOAuthDB *authDB = [DConnectLocalOAuthDB sharedLocalOAuthDB];
                if ([response errorCode] == DConnectMessageErrorCodeNotFoundClientId) {
                    [authDB deleteAuthDataByServiceId:serviceId];
                } else if ([response errorCode] == DConnectMessageErrorCodeExpiredAccessToken) {
                    [authDB deleteAccessToken:accessToken];
                } else {
                    return YES;
                }
                // アクセストークンの再取得
                accessToken = [self authorizationToDevicePlugin:plugin
                                                         origin:origin
                                                      serviceId:serviceId];
                if (accessToken) {
                    [copyRequest setString:accessToken forKey:DConnectMessageAccessToken];
                    [[response internalDictionary] removeAllObjects];
                    send = [plugin didReceiveRequest:copyRequest response:response];
                } else {
                    [response setErrorToAuthorization];
                    return YES;
                }
            }
            return send;
        }
        [response setErrorToNotFoundService];
    }
    return YES;
}

- (NSString *) authorizationToDevicePlugin:(DConnectDevicePlugin *)plugin
                                    origin:(NSString *)origin
                                 serviceId:(NSString *)serviceId
{
    DConnectLocalOAuthDB *authDB = [DConnectLocalOAuthDB sharedLocalOAuthDB];
    DConnectAuthData *data;
    NSString *accessToken;
    
    if (!plugin.useLocalOAuth) {
        // ダミーの認可情報を保存
        data = [authDB getAuthDataByServiceId:serviceId];
        if (!data) {
            [authDB addAuthDataWithServiceId:serviceId clientId:[plugin pluginId]];
            data =[authDB getAuthDataByServiceId:serviceId];
        }
        accessToken = [authDB getAccessTokenByAuthData:data];
        if (!accessToken) {
            accessToken = [plugin pluginId]; // プラグインIDをダミーのアクセストークンとする.
            [authDB addAccessToken:accessToken withAuthData:data];
        }
        return accessToken;
    }

    data = [authDB getAuthDataByServiceId:serviceId];
    if (data == nil) {
		DConnectResponseMessage *response = [self createClientToDevicePlugin:plugin
                                                                      origin:origin
                                                                   serviceId:serviceId];
        if ([response result] == DConnectMessageResultTypeOk) {
            NSString *clientId = [response stringForKey:DConnectAuthorizationProfileParamClientId];
            [authDB addAuthDataWithServiceId:serviceId
                                   clientId:clientId];
            data = [authDB getAuthDataByServiceId:serviceId];
        } else {
            return nil;
        }
    }
    
    accessToken = [authDB getAccessTokenByAuthData:data];
    if (accessToken == nil) {
        DConnectResponseMessage *response =
        [self requestAccessTokenToDevicePlugin:plugin
                                        origin:origin
                                      serviceId:serviceId
                                      clientId:data.clientId];
        if ([response result] == DConnectMessageResultTypeOk) {
            accessToken = [response stringForKey:DConnectMessageAccessToken];
            [authDB addAccessToken:accessToken withAuthData:data];
        } else {
            return nil;
        }
    }
    return accessToken;
}

- (DConnectResponseMessage *) createClientToDevicePlugin:(DConnectDevicePlugin *)plugin
                                                  origin:(NSString *)origin
                                               serviceId:(NSString*)serviceId
{
    DConnectRequestMessage *request = [DConnectRequestMessage message];
    [request setAction:DConnectMessageActionTypeGet];
    [request setProfile:DConnectAuthorizationProfileName];
    [request setAttribute:DConnectAttributeNameCreateClient];
    [request setString:origin forKey:DConnectAuthorizationProfileParamPackage];
	[request setServiceId:serviceId];
	
    DConnectResponseMessage *response = [DConnectResponseMessage message];
    BOOL result = [plugin didReceiveRequest:request response:response];
    if (!result) {
        // ここに入る場合はプログラム的にバグ
        [NSException raise:@"AuthorizationException" format:@"テスト"];
    }
    return response;
}

- (DConnectResponseMessage *) requestAccessTokenToDevicePlugin:(DConnectDevicePlugin *)plugin
                                                        origin:(NSString *)origin
                                                     serviceId:(NSString *)serviceId
                                                      clientId:(NSString *)clientId
{
    NSArray *scopes = [self getScopeFromDevicePlugin:plugin serviceId: serviceId];
    NSString *scope = [DConnectUtil combineScopes:scopes];
    
    DConnectRequestMessage *request = [DConnectRequestMessage message];
    [request setAction:DConnectMessageActionTypeGet];
    [request setProfile:DConnectAuthorizationProfileName];
    [request setAttribute:DConnectAttributeNameRequestAccessToken];
    [request setString:origin forKey:DConnectAuthorizationProfileParamPackage];
    [request setString:clientId forKey:DConnectAuthorizationProfileParamClientId];
    [request setString:scope forKey:DConnectAuthorizationProfileParamScope];
    
    DConnectResponseMessage *response = [DConnectResponseMessage message];
    BOOL result = [plugin didReceiveRequest:request response:response];
    if (!result) {
        // ここに入る場合はプログラム的にバグ
        [NSException raise:@"AuthorizationException" format:@"テスト"];
    }
    return response;
}

- (NSArray *)getScopeFromDevicePlugin:(DConnectDevicePlugin *)plugin
                            serviceId:(NSString *)serviceId {
    NSMutableArray *scopes = [NSMutableArray array];
    
    
    // デバイスプラグインから取得
    NSArray *profiles = [plugin profiles];
    for (DConnectProfile *profile in profiles) {
        [scopes addObject:[profile profileName]];
    }
    
    // サービスデータから取得
    DConnectManager *mgr = (DConnectManager *) self.provider;
    NSString *did = [mgr.mDeviceManager spliteServiceId:serviceId byDevicePlugin:plugin];
    NSArray * serviceScopes = [plugin serviceProfilesWithServiceId: did];
    for (DConnectProfile *profile in serviceScopes) {
        [scopes addObject: [profile profileName]];
    }
    
    return [scopes sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

@end
