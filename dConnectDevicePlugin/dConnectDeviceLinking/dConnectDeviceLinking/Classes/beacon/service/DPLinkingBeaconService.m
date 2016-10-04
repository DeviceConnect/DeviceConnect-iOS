//
//  DPLinkingBeaconService.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconService.h"
#import "DPLinkingBeaconAtmosphericPressureProfile.h"
#import "DPLinkingBeaconBatteryProfile.h"
#import "DPLinkingBeaconHumidityProfile.h"
#import "DPLinkingBeaconKeyEventProfile.h"
#import "DPLinkingBeaconProximityProfile.h"
#import "DPLinkingBeaconTemperatureProfile.h"

@implementation DPLinkingBeaconService 

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon plugin:(DConnectDevicePlugin *)plugin
{
    self = [super initWithServiceId:beacon.beaconId plugin:plugin];
    if (self) {
        _beacon = beacon;

        [self setName:beacon.displayName];
        [self setOnline:beacon.online];
        [self setNetworkType:DConnectServiceDiscoveryProfileNetworkTypeBLE];
        
        [self addProfile:[DPLinkingBeaconAtmosphericPressureProfile new]];
        [self addProfile:[DPLinkingBeaconBatteryProfile new]];
        [self addProfile:[DPLinkingBeaconHumidityProfile new]];
        [self addProfile:[DPLinkingBeaconKeyEventProfile new]];
        [self addProfile:[DPLinkingBeaconProximityProfile new]];
        [self addProfile:[DPLinkingBeaconTemperatureProfile new]];
    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                               bleStateForServiceId:(NSString *)serviceId
{
    if (_beacon.online) {
        return DConnectServiceInformationProfileConnectStateOn;
    } else {
        return DConnectServiceInformationProfileConnectStateOff;
    }
}

@end
