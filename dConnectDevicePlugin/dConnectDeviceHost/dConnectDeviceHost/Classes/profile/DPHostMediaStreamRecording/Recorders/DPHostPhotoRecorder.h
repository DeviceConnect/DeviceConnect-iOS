//
//  DPHostPhotoRecorder.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectFileManager.h>

#import "DPHostRecorder.h"

@interface DPHostPhotoRecorder : DPHostRecorder

// 写真撮影
- (void)takePhotoWithSuccessCompletion:(void (^)(NSURL *assetURL))successCompletion
                        failCompletion:(void (^)(NSString *errorMessage))failCompletion;
// バックカメラか
- (BOOL)isBack;
// カメラのライトをつける
- (void)turnOnFlashLight;
// カメラのライトを消す
- (void)turnOffFlashLight;
// カメラのライトの状態を取得する
- (BOOL)getFlashLightState;
// カメラのライトが使用中であるかどうかを返す
- (BOOL)useFlashLight;
// Preview用のサーバを起動
- (void)startWebServerWithSuccessCompletion:(void (^)(NSString *uri))successCompletion
                             failCompletion:(void (^)(NSString *errorMessage))failCompletion;
// Preview用のサーバを停止
- (void)stopWebServer;
@end
