//
//  SonyCameraService.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraService.h"
#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectProfile.h>

@implementation SonyCameraService

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName profiles: (NSArray *) profiles {
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        for (DConnectProfile *profile in profiles) {
            [self addProfile: profile];
        }
    }
    return self;
}

@end
