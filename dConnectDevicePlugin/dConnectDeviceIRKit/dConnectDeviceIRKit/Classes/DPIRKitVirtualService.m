//
//  DPIRKitVirtualService.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitVirtualService.h"
#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectProfile.h>
#import "DPIRKitRemoteControllerProfile.h"
#import "DPIRKitTVProfile.h"
#import "DPIRKitLightProfile.h"


@implementation DPIRKitVirtualService
- (instancetype) initWithServiceId:(NSString *)serviceId plugin:(id)plugin name:(NSString*)name {
    self = [super initWithServiceId: serviceId plugin: plugin dataSource: self];
    if (self) {
        [self setName: serviceId];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        [self setName:name];
        
        // サービスで登録するProfile
        [self addProfile: [[DPIRKitTVProfile alloc] initWithDevicePlugin:plugin]];
        [self addProfile: [[DPIRKitLightProfile alloc] initWithDevicePlugin:plugin]];
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
