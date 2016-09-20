//
//  DPLinkingDeviceService.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceService.h"
#import "DPLinkingDeviceBatteryProfile.h"
#import "DPLinkingDeviceOrientationProfile.h"
#import "DPLinkingDeviceHumidityProfile.h"
#import "DPLinkingDeviceKeyEventProfile.h"
#import "DPLinkingDeviceLightProfile.h"
#import "DPLinkingDeviceNotificationProfile.h"
#import "DPLinkingDeviceProximityProfile.h"
#import "DPLinkingDeviceTemperatureProfile.h"
#import "DPLinkingDeviceVibrationProfile.h"
#import "DPLinkingDeviceAtmosphericPressureProfile.h"

@implementation DPLinkingDeviceService {
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice: (DPLinkingDevice *)device plugin:(DConnectDevicePlugin *)plugin
{
    self = [super initWithServiceId:device.identifier plugin:plugin];
    if (self) {
        _device = device;

        [self setName:_device.name];
        [self setOnline:_device.online];
        [self setNetworkType:DConnectServiceDiscoveryProfileNetworkTypeBLE];

        [self addProfile:[DPLinkingDeviceNotificationProfile new]];
        [self addProfile:[DPLinkingDeviceProximityProfile new]];
        
        if ([device isSupportLED]) {
            [self addProfile:[DPLinkingDeviceLightProfile new]];
        }
        
        if ([device isSupportVibration]) {
            [self addProfile:[DPLinkingDeviceVibrationProfile new]];
        }
        
        if ([device isSupportSensor]) {
            [self addProfile:[DPLinkingDeviceOrientationProfile new]];
        }
        
        if ([device isSupportButtonId]) {
            [self addProfile:[DPLinkingDeviceKeyEventProfile new]];
        }
        
        if ([device isSupportTemperature]) {
            [self addProfile:[DPLinkingDeviceTemperatureProfile new]];
        }
        
        if ([device isSupportHumidity]) {
            [self addProfile:[DPLinkingDeviceHumidityProfile new]];
        }
        
        if ([device isSupportBattery]) {
            [self addProfile:[DPLinkingDeviceBatteryProfile new]];
        }
        
        if ([device isSupportAtmosphericPressure]) {
            [self addProfile:[DPLinkingDeviceAtmosphericPressureProfile new]];
        }
    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                               bluetoothStateForServiceId:(NSString *)serviceId
{
    if (_device.online) {
        return DConnectServiceInformationProfileConnectStateOn;
    } else {
        return DConnectServiceInformationProfileConnectStateOff;
    }
}

@end
