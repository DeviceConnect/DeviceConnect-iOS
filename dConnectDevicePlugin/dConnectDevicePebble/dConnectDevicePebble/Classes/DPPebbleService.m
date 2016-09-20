//
//  DPPebbleService.m
//  dConnectDevicePebble
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleService.h"
#import "DPPebbleBatteryProfile.h"
#import "DPPebbleVibrationProfile.h"
#import "DPPebbleSettingsProfile.h"
#import "DPPebbleDeviceOrientationProfile.h"
#import "DPPebbleNotificationProfile.h"
#import "DPPebbleCanvasProfile.h"
#import "DPPebbleKeyEventProfile.h"

@implementation DPPebbleService

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName plugin: (id) plugin {
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeBluetooth];
        [self setOnline: YES];
        
        [self addProfile:[DPPebbleNotificationProfile new]];
        [self addProfile:[DPPebbleBatteryProfile new]];
        [self addProfile:[DPPebbleSettingsProfile new]];
        [self addProfile:[DPPebbleVibrationProfile new]];
        [self addProfile:[DPPebbleDeviceOrientationProfile new]];
        [self addProfile:[DPPebbleCanvasProfile new]];
        [self addProfile:[DPPebbleKeyEventProfile new]];
    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource Implement.

- (DConnectServiceInformationProfileConnectState)profile:(DConnectServiceInformationProfile *)profile
                              bluetoothStateForServiceId:(NSString *)serviceId {
    
    DConnectServiceInformationProfileConnectState bluetoothState;
    if (self.online) {
        bluetoothState = DConnectServiceInformationProfileConnectStateOn;
    } else {
        bluetoothState = DConnectServiceInformationProfileConnectStateOff;
    }
    return bluetoothState;
}

@end
