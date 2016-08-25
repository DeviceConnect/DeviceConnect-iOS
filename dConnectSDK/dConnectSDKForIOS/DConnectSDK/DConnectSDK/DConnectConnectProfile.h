//
//  DConnectConnectProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Connectプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectConnectProfileName;

/*!
 @brief インターフェース: bluethooth。
 */
extern NSString *const DConnectConnectProfileInterfaceBluetooth;

/*!
 @brief アトリビュート: wifi。
 */
extern NSString *const DConnectConnectProfileAttrWifi;

/*!
 @brief アトリビュート: bluetooth。
 */
extern NSString *const DConnectConnectProfileAttrBluetooth;

/*!
 @brief アトリビュート: discoverable。
 */
extern NSString *const DConnectConnectProfileAttrDiscoverable;

/*!
 @brief アトリビュート: ble。
 */
extern NSString *const DConnectConnectProfileAttrBLE;

/*!
 @brief アトリビュート: nfc。
 */
extern NSString *const DConnectConnectProfileAttrNFC;

/*!
 @brief アトリビュート: wifichange。
 */
extern NSString *const DConnectConnectProfileAttrOnWifiChange;

/*!
 @brief アトリビュート: bluetoothchange。
 */
extern NSString *const DConnectConnectProfileAttrOnBluetoothChange;

/*!
 @brief アトリビュート: blechange。
 */
extern NSString *const DConnectConnectProfileAttrOnBLEChange;

/*!
 @brief アトリビュート: nfcchange。
 */
extern NSString *const DConnectConnectProfileAttrOnNFCChange;

/*!
 @brief パラメータ: enable。
 */
extern NSString *const DConnectConnectProfileParamEnable;

/*!
 @brief パラメータ: connectStatus。
 */
extern NSString *const DConnectConnectProfileParamConnectStatus;

/*!
 @class DConnectConnectProfile
 @brief Connectプロファイル。
 
 Connect Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DConnectConnectProfile : DConnectProfile

#pragma mark - Setters

/*!
 @brief メッセージに有効状態を設定する。
 @param[in] enable 有効状態
 @param[in,out] message 有効状態を格納するメッセージ
 */
+ (void) setEnable:(BOOL)enable target:(DConnectMessage *)message;

/*!
 @brief メッセージに接続状態を設定する。
 @param[in] connectStatus 接続状態
 @param[in,out] message 接続状態を格納するメッセージ
 */
+ (void) setConnectStatus:(DConnectMessage *)connectStatus target:(DConnectMessage *)message;

@end
