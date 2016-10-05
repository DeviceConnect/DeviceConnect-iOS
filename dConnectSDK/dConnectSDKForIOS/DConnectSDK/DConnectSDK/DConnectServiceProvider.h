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

@interface DConnectServiceProvider : NSObject

- (id) plugin;

- (BOOL) hasService: (NSString *) serviceId;

- (DConnectService *) service: (NSString *) serviceId;

/*!
 @brief サービス配列を返す.
 @retval DConnectServiceの配列
 */
- (NSArray *) services;

- (void) addService: (DConnectService *) service;

- (void) addService: (DConnectService *) service bundle:(NSBundle *) selfBundle;

- (void) removeService: (DConnectService *) service;

- (void) removeAllServices;

/*!
 * @brief サービスの追加または削除イベントを受信するためのリスナーを追加する.
 * @param[in] listener リスナー
 */
- (void) addServiceListener: (id<DConnectServiceListener>) listener;

/*!
 * サービスの追加または削除イベントを受信するためのリスナーを削除する.
 * @param[in] listener リスナー
 */
- (void) removeServiceListener: (id<DConnectServiceListener>) listener;

@end
