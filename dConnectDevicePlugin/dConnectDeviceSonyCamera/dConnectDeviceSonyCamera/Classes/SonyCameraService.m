//
//  SonyCameraService.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraService.h"

@implementation SonyCameraService

- (instancetype) initWithServiceId: (NSString *) serviceId profiles: (NSArray *) profiles {
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: SonyDeviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        for (DConnectProfiles *profile in profiles) {
            [self addProfile: profile];
        }
    }
    return self;
}

@end
