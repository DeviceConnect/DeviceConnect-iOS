//
//  DPLinkingDevicePlugin.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDevicePlugin.h"
#import "DPLinkingServiceDiscoveryProfile.h"
#import "DPLinkingSystemProfile.h"

@implementation DPLinkingDevicePlugin

- (id) init
{
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Linking (Device Connect Device Plug-in)";

        DConnectMemoryCacheController *ctl = [[DConnectMemoryCacheController alloc] init];
        [[DConnectEventManager sharedManagerForClass:[self class]] setController:ctl];

        [self addProfile:[[DPLinkingServiceDiscoveryProfile alloc] initWithServiceProvider: self.serviceProvider]];
        [self addProfile:[DPLinkingSystemProfile systemProfileWithVersion:@"1.0"]];
    }
    return self;
}

@end
