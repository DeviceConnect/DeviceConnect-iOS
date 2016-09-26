//
//  DPLinkingDeviceHumidityOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceHumidityOnce.h"
#import <DCMDevicePluginSDK/DCMHumidityProfile.h>

@implementation DPLinkingDeviceHumidityOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;
        
        [_deviceManager enableListenHumidity:device delegate:self];
    }
    return self;
}

#pragma mark - DPLinkingDeviceHumidityDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device humidity:(float)humidity
{
    [self.response setResult:DConnectMessageResultTypeOk];
    [DCMHumidityProfile setHumidity:humidity target:self.response];
    [DCMHumidityProfile setTimeStamp:[NSDate date].timeIntervalSince1970 target:self.response];
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
    [_deviceManager disableListenHumidity:_device delegate:self];
}

@end
