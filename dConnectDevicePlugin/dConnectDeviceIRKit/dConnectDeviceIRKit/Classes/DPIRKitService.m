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

@implementation DPIRKitService

- (instancetype) initWithServiceId: (NSString *)serviceId profiles: (NSArray *) profiles plugin: (id) plugin {
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: serviceId];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        for (DConnectProfile *profile in profiles) {
            [self addProfile: profile];
        }
    }
    return self;
}




@end
