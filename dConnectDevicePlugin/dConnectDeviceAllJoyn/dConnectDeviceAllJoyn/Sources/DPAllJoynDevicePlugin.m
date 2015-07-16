//
//  DPAllJoynDevicePlugin.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynDevicePlugin.h"

#import <DConnectSDK/DConnectServiceInformationProfile.h>
#import "DPAllJoynServiceDiscoveryProfile.h"
#import "DPAllJoynServiceInformationProfile.h"
#import "DPAllJoynSystemProfile.h"


static NSString *const VERSION = @"1.0.0";


@implementation DPAllJoynDevicePlugin

- (instancetype) init {
    self = [super init];
    if (self) {
        self.pluginName = [NSString stringWithFormat:@"AllJoyn %@", VERSION];
        
        // Add profiles.
        [self addProfile:[DPAllJoynServiceDiscoveryProfile new]];
        [self addProfile:[DPAllJoynSystemProfile systemProfileWithVersion:VERSION]];
        [self addProfile:[DPAllJoynServiceInformationProfile new]];
    }
    return self;
}

@end
