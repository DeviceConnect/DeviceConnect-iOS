//
//  DPHostRecorderUtils.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectFileManager.h>

@interface DPHostRecorderUtils : NSObject

/*!
 @brief 画像の傾き調整。
 */
+ (UIImage *)fixOrientationWithImage:(UIImage *)image
                            position:(AVCaptureDevicePosition) position;
/*!
 @brief 動画の傾き調整。
 */
+ (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation;
/*!
 @brief PresetをCGSizeに変換。
 */
+ (CGSize)getDimensionForPreset:(NSString *)preset;
/*!
 @brief レコーダがサポートしている解像度の取得。
 */
+ (NSArray*)getRecorderSizesForSession:(AVCaptureSession*)session;
/*!
 @brief レコーダ用のデバイスが存在しているか。
 */
+ (BOOL)containsDevice:(AVCaptureDevice *)device session:(AVCaptureSession *)session;
/*!
 @brief レコーダ用のコネクションが存在しているか。
 */
+ (AVCaptureConnection *)connectionForDevice:(AVCaptureDevice *)device output:(AVCaptureOutput *)output;
/*!
 @brief ライトのON/OFF
 */
+ (void)setLightOnOff:(BOOL)bSwitch;

@end
