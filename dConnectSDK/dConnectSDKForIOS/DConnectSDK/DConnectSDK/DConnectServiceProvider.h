//
//  DConnectServiceProvider.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectServiceListener.h>

@class DConnectService;

/*!
 @class DConnectServiceProvider
 @brief プラグインのサービス管理機能のインターフェース。
 */
@interface DConnectServiceProvider : NSObject

/*!
 @brief サービスの公開元であるプラグインを取得する。
 @return DConnectDevicePluginのインスタンス。
 */
- (id) plugin;

/*!
 @brief 指定されたサービスを保持しているかどうかを返す。
 @param[in] serviceId サービスID
 @return 保持している場合はYES、そうでない場合はNO
 */
- (BOOL) hasService: (NSString *) serviceId;

/*!
 @brief 指定されたサービスのインスタンスを返す。
 @param[in] serviceId サービスID
 @return DConnectServiceのインスタンス。存在しなかった場合は、nilを返す。
 */
- (DConnectService *) service: (NSString *) serviceId;

/*!
 @brief サービス配列を返す。
 @retval DConnectServiceの配列
 */
- (NSArray *) services;

/*!
 @brief サービスを追加する。
 @param[in] service DConnectServiceのインスタンス
 */
- (void) addService: (DConnectService *) service;

/*!
 @brief サービスを追加する。
 @param[in] service DConnectServiceのインスタンス
 @param[in] selfBundle NSBundleのインスタンス
 */
- (void) addService: (DConnectService *) service bundle:(NSBundle *) selfBundle;

/*!
 @brief サービスを削除する。
 @param[in] service DConnectServiceのインスタンス
 */
- (void) removeService: (DConnectService *) service;

/*!
 @brief 全てのサービスを削除する。
 */
- (void) removeAllServices;

/*!
 @brief サービスの追加または削除イベントを受信するためのリスナーを追加する。
 @param[in] listener リスナー
 */
- (void) addServiceListener: (id<DConnectServiceListener>) listener;

/*!
 @brief サービスの追加または削除イベントを受信するためのリスナーを削除する。
 @param[in] listener リスナー
 */
- (void) removeServiceListener: (id<DConnectServiceListener>) listener;

@end
