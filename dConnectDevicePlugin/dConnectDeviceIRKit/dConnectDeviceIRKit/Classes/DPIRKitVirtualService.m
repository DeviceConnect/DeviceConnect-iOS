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
#import <DConnectSDK/DConnectLightProfile.h>
#import "DPIRKitRemoteControllerProfile.h"
#import "DPIRKitTVProfile.h"
#import "DPIRKitLightProfile.h"
#import "DPIRKitDialog.h"
@implementation DPIRKitVirtualService

- (instancetype) initWithServiceId: (NSString *)serviceId name:(NSString*)name
                            plugin:(id)plugin profileName:(NSString *)profileName {
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setServiceId:serviceId];
        [self setName: name];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        // サービスで登録するProfile
        if ([profileName isEqualToString:DPIRKitCategoryLight]) {
            [self addProfile: [[DPIRKitLightProfile alloc] initWithDevicePlugin:plugin]];
        } else {
            [self addProfile: [[DPIRKitTVProfile alloc] initWithDevicePlugin:plugin]];
        }
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
