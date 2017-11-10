//
//  DPHostPhotoRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostPhotoRecorder.h"

@implementation DPHostPhotoRecorder


- (void)takePhotoWithSuccessCompletion:(void (^)(NSURL *assetURL))successCompletion
                        failCompletion:(void (^)(NSString *errorMessage))failCompletion
{
    // override subclass

}
- (BOOL)isBack
{
    // override subclass
    return NO;
}
- (void)turnOnFlashLight
{
    // override subclass
}
- (void)turnOffFlashLight
{
    // override subclass
}
- (BOOL)getFlashLightState
{
    // override subclass
    return NO;
}
- (BOOL)useFlashLight
{
    // override subclass
    return NO;
}
- (void)startWebServerWithSuccessCompletion:(void (^)(NSString *uri))successCompletion
                             failCompletion:(void (^)(NSString *errorMessage))failCompletion
{
    // override subclass
}
// Preview用のサーバを停止
- (void)stopWebServer
{
    // override subclass
}

@end
