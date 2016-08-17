//
//  DPLinkingBeaconAtmosphericPressureOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconAtmosphericPressureOnce.h"
#import "DConnectAtmosphericPressureProfile.h"

@implementation DPLinkingBeaconAtmosphericPressureOnce {
    DPLinkingBeaconManager *_beaconManager;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addAtmosphericPressureDelegate:self];
    }
    return self;
}

#pragma mark - DPLinkingBeaconAtmosphericPressureDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon AtmosphericPressure:(DPLinkingAtmosphericPressureData *)atmosphericPressure
{
    [self.response setResult:DConnectMessageResultTypeOk];
    [DConnectAtmosphericPressureProfile setAtmosphericPressure:atmosphericPressure.value target:self.response];
    [DConnectAtmosphericPressureProfile setTimeStamp:atmosphericPressure.timeStamp target:self.response];
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
    [_beaconManager removeAtmosphericPressureDelegate:self];
}

@end
