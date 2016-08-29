//
//  DPLinkingBeaconKeyEventOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconKeyEventOnce.h"

@implementation DPLinkingBeaconKeyEventOnce {
    DPLinkingBeaconManager *_beaconManager;
    DPLinkingBeacon *_beacon;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beacon = beacon;
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addButtonIdDelegate:self];
        [_beaconManager startBeaconScanWithTimeout:30.0f];
    }
    return self;
}

#pragma mark - DPLinkingBeaconButtonIdDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon ButtonId:(int)buttonId
{
    if (![beacon.beaconId isEqualToString:_beacon.beaconId]) {
        return;
    }
    
    [self.response setResult:DConnectMessageResultTypeOk];
    DConnectMessage *keyEvent = [DConnectMessage new];
    [DConnectKeyEventProfile setId:buttonId target:keyEvent];
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
    [_beaconManager removeButtonIdDelegate:self];
}
@end
