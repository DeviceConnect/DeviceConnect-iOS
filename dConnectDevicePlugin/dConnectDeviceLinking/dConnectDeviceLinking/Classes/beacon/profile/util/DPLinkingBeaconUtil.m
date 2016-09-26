
//
//  DPLinkingBeaconUtil.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconUtil.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingDevicePlugin.h"

@implementation DPLinkingBeaconUtil

+ (BOOL) isEmptyEvent
{
    DPLinkingBeaconManager *mgr = [DPLinkingBeaconManager sharedInstance];
    NSArray *array = [mgr getBeacons];
    
    __block BOOL result = YES;
    
    [array enumerateObjectsUsingBlock:^(DPLinkingBeacon *beacon, NSUInteger idx, BOOL *stop) {
        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];

        NSArray *events;
        events = [mgr eventListForServiceId:beacon.beaconId
                                    profile:DConnectKeyEventProfileName
                                attribute:DConnectKeyEventProfileAttrOnDown];
        if ([events count] > 0) {
            result = NO;
            *stop = YES;
            return;
        }
        
        events = [mgr eventListForServiceId:beacon.beaconId
                                    profile:DConnectProximityProfileName
                                  attribute:DConnectProximityProfileAttrOnDeviceProximity];
        if ([events count] > 0) {
            result = NO;
            *stop = YES;
            return;
        }
        
        events = [mgr eventListForServiceId:beacon.beaconId
                                    profile:DConnectBatteryProfileName
                                  attribute:DConnectBatteryProfileAttrOnBatteryChange];
        if ([events count] > 0) {
            result = NO;
            *stop = YES;
            return;
        }
    }];
    
    return result;
}


@end
