//
//  DPLinkingDeviceAtmosphericPressureOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceAtmosphericPressureOnce.h"
#import "DConnectAtmosphericPressureProfile.h"

@implementation DPLinkingDeviceAtmosphericPressureOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;
        
        [_deviceManager enableListenAtmosphericPressure:device delegate:self];
    }
    return self;
}

#pragma mark - DPLinkingDeviceAtmosphericPressureDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device atmosphericPressure:(float)atmosphericPressure
{
    [self.response setResult:DConnectMessageResultTypeOk];
    [DConnectAtmosphericPressureProfile setAtmosphericPressure:atmosphericPressure target:self.response];
    [DConnectAtmosphericPressureProfile setTimeStamp:[NSDate date].timeIntervalSince1970 target:self.response];
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
    [_deviceManager disableListenAtmosphericPressure:_device delegate:self];
}


@end
