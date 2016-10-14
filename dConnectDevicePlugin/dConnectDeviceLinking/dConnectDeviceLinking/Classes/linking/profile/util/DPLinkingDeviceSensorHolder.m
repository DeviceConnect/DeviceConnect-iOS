//
//  DPLinkingDeviceSensorHolder.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceSensorHolder.h"

@implementation DPLinkingDeviceSensorHolder {
    BOOL _supportGyro;
    BOOL _supportAcceleration;
    BOOL _supportCompass;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super init];
    if (self) {
        self.device = device;
        self.orientation = [DConnectMessage new];
        _supportGyro = NO;
        _supportAcceleration = NO;
        _supportCompass = NO;
    }
    return self;
}

- (void) clearFlag
{
    _supportGyro = NO;
    _supportAcceleration = NO;
    _supportCompass = NO;
}

- (BOOL) isFlag
{
    return [self.device isSupportGryo] == _supportGyro &&
            [self.device isSupportAcceleration] == _supportAcceleration &&
            [self.device isSupportCompass] == _supportCompass;
}

- (void) setSensorData:(DPLinkingSensorData *)data
{
    switch (data.type) {
        case DPLinkingSensorTypeGyroscope:
            _supportGyro = YES;
            break;
        case DPLinkingSensorTypeAccelerometer:
            _supportAcceleration = YES;
            break;
        case DPLinkingSensorTypeOrientation:
            _supportCompass = YES;
            break;
        default:
            return;
    }
}

@end
