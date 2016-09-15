//
//  DPHitoeAccelerationData.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeAccelerationData.h"

@implementation DPHitoeAccelerationData
- (id)copyWithZone:(NSZone *)zone {
    id copiedObject = [[[self class] allocWithZone:zone] init];
    return copiedObject;
}

- (DConnectMessage*)toDConnectMessage {
    DConnectMessage *message = [DConnectMessage new];
    DConnectMessage *accel = [DConnectMessage new];
    [DConnectDeviceOrientationProfile setX:self.accelX target:accel];
    [DConnectDeviceOrientationProfile setY:self.accelY target:accel];
    [DConnectDeviceOrientationProfile setZ:self.accelZ target:accel];
    
    [DConnectDeviceOrientationProfile setAcceleration:accel target:message];
    [DConnectDeviceOrientationProfile setInterval:self.interval target:message];
    return message;
}

@end
