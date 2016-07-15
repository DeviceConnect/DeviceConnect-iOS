//
//  DPHostService.m
//  dConnectDeviceHost
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostService.h"
#import "DPHostDevicePlugin.h"

static NSString *const ServiceDiscoveryServiceId = @"host";

@implementation DPHostService

- (instancetype) initWithFileManager: (DConnectFileManager *) fileMgr {
    self = [super init];
    if (self) {
        UIDevice *device = [UIDevice currentDevice];
        NSString *name = [NSString stringWithFormat:@"Host: %@", device.name];
        NSString *config = [NSString stringWithFormat:@"{\"OS\":\"%@ %@\"}",
                            device.systemName, device.systemVersion];
        [self setId: ServiceDiscoveryServiceId];
        [self setName: name];
        [self setOnline: YES];
        [self setConfig:config];
        
        // プロファイルを追加
        [self addProfile:[DPHostBatteryProfile new]];
        [self addProfile:[DPHostDeviceOrientationProfile new]];
        [self addProfile:[[DPHostFileDescriptorProfile alloc] initWithFileManager: fileMgr]];
        [self addProfile:[DPHostFileProfile new]];
        [self addProfile:[DPHostMediaPlayerProfile new]];
        [self addProfile:[DPHostMediaStreamRecordingProfile new]];
        [self addProfile:[DPHostNotificationProfile new]];
        [self addProfile:[DPHostPhoneProfile new]];
        [self addProfile:[DPHostProximityProfile new]];
        [self addProfile:[DPHostSettingsProfile new]];
        [self addProfile:[DPHostVibrationProfile new]];
        [self addProfile:[DPHostConnectProfile new]];
        [self addProfile:[DPHostCanvasProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
        [self addProfile:[DPHostTouchProfile new]];
    }
    return self;
}

@end
