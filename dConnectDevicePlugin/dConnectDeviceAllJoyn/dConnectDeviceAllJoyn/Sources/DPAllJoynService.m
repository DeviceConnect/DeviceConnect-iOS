//
//  DPAllJoynService.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynService.h"
#import "DPAllJoynLightProfile.h"

@implementation DPAllJoynService

- (instancetype) initWithServiceId: (NSString *) serviceId serviceName: (NSString *)serviceName plugin: (id) plugin handler: (DPAllJoynHandler *) handler {
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: serviceName];
        [self setOnline: YES];
        
        [self addProfile:[[DPAllJoynLightProfile alloc] initWithHandler: handler]];
    }
    return self;
}

@end
