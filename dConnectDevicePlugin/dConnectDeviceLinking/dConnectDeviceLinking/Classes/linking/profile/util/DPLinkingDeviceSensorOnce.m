//
//  DPLinkingDeviceSensorOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceSensorOnce.h"
#import "DPLinkingDeviceSensorHolder.h"
#import "DPLinkingDeviceOrientationProfile.h"

@implementation DPLinkingDeviceSensorOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDeviceSensorHolder *_holder;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _holder = [[DPLinkingDeviceSensorHolder alloc] initWithDevice:device];
        
        [_deviceManager enableListenSensor:device delegate:self];
    }
    return self;
}

- (void) didReceivedDevice:(DPLinkingDevice *)device sensor:(DPLinkingSensorData *)data
{
    if (self.cleanupFlag) {
        return;
    }
    
    [DPLinkingDeviceOrientationProfile updateSensorData:data to:_holder.orientation];
    [_holder setSensorData:data];
    
    if ([_holder isFlag]) {
        [self.response setResult:DConnectMessageResultTypeOk];
        [self.response setMessage:_holder.orientation forKey:DConnectDeviceOrientationProfileParamOrientation];
        [[DConnectManager sharedManager] sendResponse:self.response];
        [self cleanup];
    }
}

- (void) onTimeout
{
    [self.response setErrorToTimeout];
    [[DConnectManager sharedManager] sendResponse:self.response];
}

- (void) onCleanup
{
    [_deviceManager disableListenSensor:_holder.device delegate:self];
}

@end
