//
//  DPSpheroService.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroService.h"
#import "DPSpheroSensorProfile.h"
#import "DPSpheroDriveControllerProfile.h"
#import "DPSpheroLightProfile.h"
#import "DPSpheroDeviceOrientationProfile.h"

@implementation DPSpheroService

- (instancetype) initWithServiceId:(NSString *)serviceId deviceName: (NSString *) deviceName {
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeBluetooth];
        [self setOnline: YES];
        
        // Sphero Profileの追加
        [self addProfile:[DPSpheroSensorProfile new]];
        [self addProfile:[DPSpheroDriveControllerProfile new]];
        [self addProfile:[DPSpheroLightProfile new]];
        [self addProfile:[DPSpheroDeviceOrientationProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
    }
    return self;
}

@end
