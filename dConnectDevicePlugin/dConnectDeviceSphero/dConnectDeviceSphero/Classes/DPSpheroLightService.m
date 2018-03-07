//
//  DPSpheroLightService.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPSpheroLightService.h"
#import "DPSpheroLightProfile.h"

@implementation DPSpheroLightService

- (instancetype) initWithServiceId:(NSString *)serviceId
                           lightId:(NSString *)lightId
                        deviceName: (NSString *) deviceName
                            plugin: (id) plugin {
    NSString *serviceIdForLight = [NSString stringWithFormat:@"%@_%@", serviceId, lightId];
    self = [super initWithServiceId: serviceIdForLight plugin: plugin];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeBluetooth];
        [self setOnline: YES];
        
        // Sphero Profileの追加
        [self addProfile:[DPSpheroLightProfile new]];
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
