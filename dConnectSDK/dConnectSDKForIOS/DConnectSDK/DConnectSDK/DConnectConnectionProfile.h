//
//  DConnectConnectionProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Connectionプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectConnectionProfileName;

/*!
 @brief インターフェース: bluethooth。
 */
extern NSString *const DConnectConnectionProfileInterfaceBluetooth;

/*!
 @brief アトリビュート: wifi。
 */
extern NSString *const DConnectConnectionProfileAttrWifi;

/*!
 @brief アトリビュート: bluetooth。
 */
extern NSString *const DConnectConnectionProfileAttrBluetooth;

/*!
 @brief アトリビュート: discoverable。
 */
extern NSString *const DConnectConnectionProfileAttrDiscoverable;

/*!
 @brief アトリビュート: ble。
 */
extern NSString *const DConnectConnectionProfileAttrBLE;

/*!
 @brief アトリビュート: nfc。
 */
extern NSString *const DConnectConnectionProfileAttrNFC;

/*!
 @brief アトリビュート: wifichange。
 */
extern NSString *const DConnectConnectionProfileAttrOnWifiChange;

/*!
 @brief アトリビュート: bluetoothchange。
 */
extern NSString *const DConnectConnectionProfileAttrOnBluetoothChange;

/*!
 @brief アトリビュート: blechange。
 */
extern NSString *const DConnectConnectionProfileAttrOnBLEChange;

/*!
 @brief アトリビュート: nfcchange。
 */
extern NSString *const DConnectConnectionProfileAttrOnNFCChange;

/*!
 @brief パラメータ: enable。
 */
extern NSString *const DConnectConnectionProfileParamEnable;

/*!
 @brief パラメータ: connectStatus。
 */
extern NSString *const DConnectConnectionProfileParamConnectStatus;

/*!
 @class DConnectConnectionProfile
 @brief Connectプロファイル。
 
 Connect Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectConnectionProfile : DConnectProfile

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
