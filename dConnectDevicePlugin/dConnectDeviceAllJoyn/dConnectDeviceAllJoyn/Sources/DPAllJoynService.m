//
//  DPAllJoynService.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynService.h"
#import <DConnectSDK/DConnectServiceInformationProfile.h>
#import "DPAllJoynLightProfile.h"

@implementation DPAllJoynService

- (instancetype) initWithServiceId: (NSString *) serviceId serviceName: (NSString *)serviceName handler: (DPAllJoynHandler *) handler {
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: serviceName];
        [self setNetworkType: @"wifi"];
        [self setOnline: YES];
        
        [self addProfile:[DConnectServiceInformationProfile new]];
        [self addProfile:[[DPAllJoynLightProfile alloc] initWithHandler: handler]];
    }
    return self;
}

@end
