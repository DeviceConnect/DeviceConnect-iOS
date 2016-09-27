//
//  DPIRKitService.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitService.h"
#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectProfile.h>
#import "DPIRKitRemoteControllerProfile.h"

@implementation DPIRKitService

- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id)plugin{
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setServiceId:serviceId];
        [self setName: serviceId];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        // サービスで登録するProfile
        [self addProfile: [[DPIRKitRemoteControllerProfile alloc] initWithDevicePlugin:plugin]];
    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource Implement.

- (DConnectServiceInformationProfileConnectState)profile:(DConnectServiceInformationProfile *)profile
                                   wifiStateForServiceId:(NSString *)serviceId {
    
    DConnectServiceInformationProfileConnectState wifiState;
    if (self.online) {
        wifiState = DConnectServiceInformationProfileConnectStateOn;
    } else {
        wifiState = DConnectServiceInformationProfileConnectStateOff;
    }
    return wifiState;
}

@end
