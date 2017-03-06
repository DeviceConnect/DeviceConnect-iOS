//
//  DPLinkingBeaconTemperatureOnce.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconTemperatureOnce.h"
#import <DCMDevicePluginSDK/DCMTemperatureProfile.h>

@implementation DPLinkingBeaconTemperatureOnce {
    DPLinkingBeaconManager *_beaconManager;
    DPLinkingBeacon *_beacon;
}

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon
{
    self = [super initWithTimeout:30.0f];
    if (self) {
        _beacon = beacon;
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        [_beaconManager addTemperatureDelegate:self];
        [_beaconManager startBeaconScanWithTimeout:30.0f];
    }
    return self;
}

#pragma mark - DPLinkingBeaconTemperatureDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon temperature:(DPLinkingTemperatureData *)temperature
{
    if (![beacon.beaconId isEqualToString:_beacon.beaconId]) {
        return;
    }

    [self.response setResult:DConnectMessageResultTypeOk];
    if (_beacon.temperatureData.temperatureType == DCMTemperatureProfileEnumCelsiusFahrenheit) {
        [DCMTemperatureProfile setTemperature:[DCMTemperatureProfile convertCelsiusToFahrenheit:temperature.value] target:self.response];
    } else {
        [DCMTemperatureProfile setTemperature:temperature.value target:self.response];
    }
    [DCMTemperatureProfile setTimeStamp:temperature.timeStamp target:self.response];
    [DCMTemperatureProfile setType:temperature.temperatureType target:self.response];
    
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
    [_beaconManager removeTemperatureDelegate:self];
}

@end
