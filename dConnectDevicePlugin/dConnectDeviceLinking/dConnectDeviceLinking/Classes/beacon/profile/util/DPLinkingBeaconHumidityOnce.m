//
//  DPLinkingBeaconHumidityOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconHumidityOnce.h"
#import <DCMDevicePluginSDK/DCMHumidityProfile.h>

@implementation DPLinkingBeaconHumidityOnce {
    DPLinkingBeaconManager *_beaconManager;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addHumidityDelegate:self];
    }
    return self;
}

#pragma mark - DPLinkingBeaconHumidityDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon humidty:(DPLinkingHumidityData *)humidity
{
    [self.response setResult:DConnectMessageResultTypeOk];
    [DCMHumidityProfile setHumidity:humidity.value / 100.0 target:self.response];
    [DCMHumidityProfile setTimeStamp:humidity.timeStamp target:self.response];
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
    [_beaconManager removeHumidityDelegate:self];
}

@end
