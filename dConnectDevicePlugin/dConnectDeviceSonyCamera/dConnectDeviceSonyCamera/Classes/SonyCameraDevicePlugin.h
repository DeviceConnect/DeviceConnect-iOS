//
//  SonyCameraDevicePlugin.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>


@class SonyCameraManager;
@class SonyCameraService;


/*!
 @brief SonyCameraデバイスプラグインのデリゲート。
 */
@protocol SonyCameraDevicePluginDelegate <NSObject>
@optional

/*!
 @brief デバイスの発見通知。
 @param[in] discover デバイスが発見された場合はYES、それ以外はNO
 */
- (void) didReceiveDeviceList:(BOOL)discover;

/*!
 @brief WiFiの状態が更新されたことを通知.
 */
- (void) didReceiveUpdateDevice;

@end

/**
 * Sony Remote Camera API用デバイスプラグイン.
 */
@interface SonyCameraDevicePlugin : DConnectDevicePlugin

/*!
 @brief デリゲート。
 */
@property (weak, nonatomic) id<SonyCameraDevicePluginDelegate> delegate;

/*!
 @brief SonyCamera制御クラス.
 */
@property (strong, nonatomic) SonyCameraManager *sonyCameraManager;

/*!
 @brief Sonyカメラに接続されているか確認を行う.
 
 @retval YES Sonyカメラに接続されている
 @retval NO Sonyカメラに接続されていない
 */
- (BOOL) isConnectedSonyCamera;

/*!
 @brief 指定されたサービスを削除します.
 
 @param[in] servie 削除するサービス
 */
- (void) removeSonyCamera:(SonyCameraService *)service;

@end
