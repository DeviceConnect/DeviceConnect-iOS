//
//  DPLinkingDeviceTemperatureOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceTemperatureOnce.h"
#import <DCMDevicePluginSDK/DCMTemperatureProfile.h>

@implementation DPLinkingDeviceTemperatureOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;
        
        [_deviceManager enableListenTemperature:device delegate:self];
    }
    return self;
}

#pragma mark - DPLinkingDeviceTemperatureDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device temperature:(float)temperature
{
    [self.response setResult:DConnectMessageResultTypeOk];
    if (_device.temperatureType == DCMTemperatureProfileEnumCelsiusFahrenheit) {
        [DCMTemperatureProfile setTemperature:[DCMTemperatureProfile convertCelsiusToFahrenheit:temperature] target:self.response];
    } else {
        [DCMTemperatureProfile setTemperature:temperature target:self.response];
    }
    [DCMTemperatureProfile setType:_device.temperatureType target:self.response];
    [DCMTemperatureProfile setTimeStamp:[NSDate date].timeIntervalSince1970 target:self.response];
    [[DConnectManager sharedManager] sendResponse:self.response];
    [self cleanup];
}

#pragma mark - DPLinkingTimeoutSchedule

- (void) onTimeout
{
    [self.response setErrorToTimeout];
    [[DConnectManager sharedManager] sendResponse:self.response];
}

- (void) onCleanup
{
    [_deviceManager disableListenTemperature:_device delegate:self];
}

@end
