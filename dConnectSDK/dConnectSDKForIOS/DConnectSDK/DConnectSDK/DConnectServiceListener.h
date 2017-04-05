//
//  DConnectServiceListener.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

@class DConnectService;

/*!
 @brief サービス一覧の状態変更通知を受信するリスナー。
 */
@protocol DConnectServiceListener <NSObject>
@optional

/*!
 @brief サービスが追加された時に実行される。
 @param[in] 追加されたサービス。
 */
- (void) didServiceAdded: (DConnectService *) service;

/*!
 @brief サービスが削除された時に実行される。
 @param[in] 削除されたサービス。
 */
- (void) didServiceRemoved: (DConnectService *) service;

/*!
 @brief サービスの状態が変更された時に実行される。
 @param[in] 状態の変更されたサービス。
 */
- (void) didStatusChange: (DConnectService *) service;

@end
