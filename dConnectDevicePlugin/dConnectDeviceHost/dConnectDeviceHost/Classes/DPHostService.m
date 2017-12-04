//
//  DPHostService.m
//  dConnectDeviceHost
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import "DPHostService.h"
#import "DPHostDevicePlugin.h"
#import "DPHostBatteryProfile.h"
#import "DPHostDeviceOrientationProfile.h"
#import "DPHostFileProfile.h"
#import "DPHostMediaPlayerProfile.h"
#import "DPHostMediaStreamRecordingProfile.h"
#import "DPHostNotificationProfile.h"
#import "DPHostPhoneProfile.h"
#import "DPHostProximityProfile.h"
#import "DPHostSettingProfile.h"
#import "DPHostVibrationProfile.h"
#import "DPHostConnectionProfile.h"
#import "DPHostCanvasProfile.h"
#import "DPHostTouchProfile.h"
#import "DPHostGeolocationProfile.h"
#import "DPHostLightProfile.h"

NSString *const DPHostDevicePluginServiceId = @"host";

@implementation DPHostService

- (instancetype) initWithFileManager: (DConnectFileManager *) fileMgr plugin: (id) plugin {
    self = [super initWithServiceId: DPHostDevicePluginServiceId plugin: plugin];
    if (self) {
        UIDevice *device = [UIDevice currentDevice];
        NSString *name = [NSString stringWithFormat:@"Host: %@", device.name];
        NSString *config = [NSString stringWithFormat:@"{\"OS\":\"%@ %@\"}",
                            device.systemName, device.systemVersion];
        [self setName: name];
        [self setOnline: YES];
        [self setConfig:config];
        
        // プロファイルを追加
        [self addProfile:[DPHostBatteryProfile new]];
        [self addProfile:[DPHostDeviceOrientationProfile new]];
        [self addProfile:[DPHostFileProfile new]];
        [self addProfile:[DPHostMediaPlayerProfile new]];
        [self addProfile:[DPHostMediaStreamRecordingProfile new]];
        float iOSVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(iOSVersion >= 10.0) {
            [self addProfile:[DPHostNotificationProfile new]];
        }
        [self addProfile:[DPHostPhoneProfile new]];
        [self addProfile:[DPHostProximityProfile new]];
        [self addProfile:[DPHostSettingProfile new]];
        [self addProfile:[DPHostVibrationProfile new]];
        [self addProfile:[DPHostConnectionProfile new]];
        [self addProfile:[DPHostCanvasProfile new]];
        [self addProfile:[DPHostTouchProfile new]];
        [self addProfile:[DPHostGeolocationProfile new]];

        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([captureDevice isTorchAvailable]
            && [captureDevice isTorchModeSupported:AVCaptureTorchModeOn]
            && [captureDevice isTorchModeSupported:AVCaptureTorchModeOff]) {
            [self addProfile:[DPHostLightProfile new]];
        }
    }
    return self;
}

@end
