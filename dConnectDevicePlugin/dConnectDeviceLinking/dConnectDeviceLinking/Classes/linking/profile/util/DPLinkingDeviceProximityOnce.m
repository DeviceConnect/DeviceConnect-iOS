//
//  DPLinkingDeviceProximityOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceProximityOnce.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation DPLinkingDeviceProximityOnce {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingDevice *_device;
}

- (instancetype) initWithDevice:(DPLinkingDevice *)device
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _device = device;

        [_deviceManager enableListenRange:device delegate:self];
    }
    return self;
}

#pragma mark - Private Method

- (NSString *) convertRange:(DPLinkingRange)range
{
    switch (range) {
        case DPLinkingRangeImmediate:
            return DConnectProximityProfileRangeImmediate;
        case DPLinkingRangeNear:
            return DConnectProximityProfileRangeNear;
        case DPLinkingRangeFar:
            return DConnectProximityProfileRangeFar;
        default:
            return DConnectProximityProfileRangeUnknown;
    }
}

#pragma mark - DPLinkingDeviceRangeDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device range:(DPLinkingRange)range
{
    [self.response setResult:DConnectMessageResultTypeOk];
    DConnectMessage *proximity = [DConnectMessage new];
    [DConnectProximityProfile setRange:[self convertRange:range] target:proximity];
    [DConnectProximityProfile setProximity:proximity target:self.response];
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
    [_deviceManager disableListenRange:_device delegate:self];
}

@end
