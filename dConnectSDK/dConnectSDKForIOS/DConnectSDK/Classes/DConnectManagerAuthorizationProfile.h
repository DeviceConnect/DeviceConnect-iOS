//
//  DConnectManagerAuthorizationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAuthorizationProfile+Private.h"

/**
 * アプリケーションの認可を行うプロファイル.
 */
@interface DConnectManagerAuthorizationProfile : DConnectAuthorizationProfile

- (void) didReceiveInvalidOriginRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response;

@end

/*!
 @class DConnectManagerAuthorizationGetCreateClientApi
 @brief Local OAuthで使用するクライアントの作成を要求するAPI。
 */
@interface DConnectManagerAuthorizationGetCreateClientApi : GetApi<DConnectApiDelegate>

@property (nonatomic) id object;

/*!
 @brief 任意のオブジェクトを指定して本クラスのインスタンスを初期化する。
 オブジェクトはDConnectDevicePluginもしくはDConnectManagerのインスタンスでなければならない。
 
 @param[in] object DevicePluginかManagerかを判別するためのオブジェクト
 
 @retval 本クラスのインスタンス
 */
- (id) initWithObject:(id)object;

@end


/*!
 @class DConnectManagerAuthorizationGetRequestAccessTokenApi
 @brief Local OAuthで使用するアクセストークンの作成を要求API。
 */
@interface DConnectManagerAuthorizationGetRequestAccessTokenApi : GetApi<DConnectApiDelegate>

@property (nonatomic) id object;

/*!
 @brief 任意のオブジェクトを指定して本クラスのインスタンスを初期化する。
 オブジェクトはDConnectDevicePluginもしくはDConnectManagerのインスタンスでなければならない。
 
 @param[in] object DevicePluginかManagerかを判別するためのオブジェクト
 
 @retval 本クラスのインスタンス
 */
- (id) initWithObject:(id)object;

@end
