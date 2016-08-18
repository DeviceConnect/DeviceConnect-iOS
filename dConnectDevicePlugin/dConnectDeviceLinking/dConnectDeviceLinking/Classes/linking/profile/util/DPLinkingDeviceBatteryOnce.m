//
//  DPLinkingDeviceBatteryOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceBatteryOnce.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation DPLinkingDeviceBatteryOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;
        
        [_deviceManager enableListenBattery:device delegate:self];
    }
    return self;
}

#pragma mark - DPLinkingDeviceBatteryDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device lowBattery:(BOOL)lowBattery level:(float)level
{
    [self.response setResult:DConnectMessageResultTypeOk];
    [DConnectBatteryProfile setLevel:level target:self.response];
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
    [_deviceManager disableListenBattery:_device delegate:self];
}

@end
