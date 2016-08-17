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
#import "DPIRKitTVProfile.h"
#import "DPIRKitLightProfile.h"

@implementation DPIRKitService

- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id)plugin{
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: serviceId];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        // サービスで登録するProfile
        [self addProfile: [[DPIRKitRemoteControllerProfile alloc] initWithDevicePlugin:plugin]];
        [self addProfile: [[DPIRKitTVProfile alloc] initWithDevicePlugin:plugin]];
        [self addProfile: [[DPIRKitLightProfile alloc] initWithDevicePlugin:plugin]];
    }
    return self;
}




@end
