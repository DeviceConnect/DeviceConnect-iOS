//
//  DPLinkingDeviceButtonOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceButtonOnce.h"

@implementation DPLinkingDeviceButtonOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;
        _type = DPLinkingKeyEventTypeDown;
        
        [_deviceManager enableListenButtonId:device delegate:self];
    }
    return self;
}

#pragma mark - DPLinkingDeviceButtonIdDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device buttonId:(int)buttonId
{
    DConnectMessage *keyEvent = [DConnectMessage new];
    [DConnectKeyEventProfile setId:buttonId target:keyEvent];
    
    if (_type == DPLinkingKeyEventTypeChange) {
        [keyEvent setString:DConnectKeyEventProfileKeyStateDown forKey:DConnectKeyEventProfileParamState];
    }
    
    [self.response setResult:DConnectMessageResultTypeOk];
    [DConnectKeyEventProfile setKeyEvent:keyEvent target:self.response];
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
    [_deviceManager disableListenButtonId:_device delegate:self];
}

@end
