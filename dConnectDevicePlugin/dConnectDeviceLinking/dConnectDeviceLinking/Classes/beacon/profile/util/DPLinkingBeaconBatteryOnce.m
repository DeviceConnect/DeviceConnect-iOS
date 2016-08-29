//
//  DPLinkingBeaconBatteryOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconBatteryOnce.h"

@implementation DPLinkingBeaconBatteryOnce {
    DPLinkingBeaconManager *_beaconManager;
    DPLinkingBeacon *_beacon;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beacon = beacon;
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addBatteryDelegate:self];
        [_beaconManager startBeaconScanWithTimeout:30.0f];
    }
    return self;
}

#pragma mark - DPLinkingBeaconBatteryDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon battery:(DPLinkingBattryData *)battery
{
    if (![beacon.beaconId isEqualToString:_beacon.beaconId]) {
        return;
    }
    [self.response setResult:DConnectMessageResultTypeOk];
    [DConnectBatteryProfile setLevel:battery.batteryLevel / 100.0f target:self.response];
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
    [_beaconManager removeBatteryDelegate:self];
}

@end
