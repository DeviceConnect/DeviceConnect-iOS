//
//  DPHitoeService.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeService.h"
#import "DPHitoeHealthProfile.h"
#import "DPHitoeECGProfile.h"
#import "DPHitoeBatteryProfile.h"
#import "DPHitoePoseEstimationProfile.h"
#import "DPHitoeStressEstimationProfile.h"
#import "DPHitoeDeviceOrientationProfile.h"
#import "DPHitoeWalkStateProfile.h"


@interface DPHitoeService()
@property (nonatomic, strong) DPHitoeDevice *device;
@end
@implementation DPHitoeService
- (instancetype) initWithDevice:(DPHitoeDevice *)device {
    self = [super initWithServiceId: device.serviceId];
    if (self) {
        //ServiceDiscoveryの定義
        _device = device;
        [self setName:device.name];
        [self setNetworkType:DConnectServiceDiscoveryProfileNetworkTypeBLE];
        [self setOnline:device.isRegisterFlag];
        [self setConfig:@""];
        
        // サポートするProfileの定義
        [self addProfile:[DPHitoeBatteryProfile new]];
        [self addProfile:[DPHitoeHealthProfile new]];
        [self addProfile:[DPHitoeECGProfile new]];
        [self addProfile:[DPHitoePoseEstimationProfile new]];
        [self addProfile:[DPHitoeStressEstimationProfile new]];
        [self addProfile:[DPHitoeWalkStateProfile new]];
        [self addProfile:[[DConnectServiceInformationProfile alloc] initWithProvider: self]];
        [self addProfile:[DPHitoeDeviceOrientationProfile new]];

    }
    return self;
}
- (void)setOnline:(BOOL)isOnline {
    _device.registerFlag = isOnline;
}


@end
