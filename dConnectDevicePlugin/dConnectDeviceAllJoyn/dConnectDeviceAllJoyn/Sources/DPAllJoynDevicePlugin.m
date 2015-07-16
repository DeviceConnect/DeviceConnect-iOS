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
#import "DPAllJoynSystemProfile.h"


@implementation DPHostDevicePlugin

- (instancetype) init {
    self = [super init];
    if (self) {
        self.pluginName = @"AllJoyn 1.0.0";
        
        // プロファイルを追加
        [self addProfile:[DPAllJoynServiceDiscoveryProfile new]];
        [self addProfile:[DPAllJoynSystemProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
    }
    return self;
}

@end
