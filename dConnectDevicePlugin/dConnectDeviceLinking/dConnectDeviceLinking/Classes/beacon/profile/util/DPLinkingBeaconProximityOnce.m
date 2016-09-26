//
//  DPLinkingBeaconProximityOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconProximityOnce.h"

@implementation DPLinkingBeaconProximityOnce {
    DPLinkingBeaconManager *_beaconManager;
    DPLinkingBeacon *_beacon;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beacon = beacon;
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addGattDataDelegate:self];
        [_beaconManager startBeaconScanWithTimeout:30.0f];
    }
    return self;
}

#pragma mark - DPLinkingBeaconGattDataDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon gattData:(DPLinkingGattData *)gatt
{
    if (![beacon.beaconId isEqualToString:_beacon.beaconId]) {
        return;
    }

    [self.response setResult:DConnectMessageResultTypeOk];
    
    DConnectMessage *proximity = [DConnectMessage new];
    [DConnectProximityProfile setValue:gatt.distance target:proximity];
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
    [_beaconManager removeGattDataDelegate:self];
}
@end
