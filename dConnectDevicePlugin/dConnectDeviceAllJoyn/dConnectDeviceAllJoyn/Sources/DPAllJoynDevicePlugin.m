//
//  DPAllJoynDevicePlugin.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAllJoynDevicePlugin.h"

#import "AJNInit.h"
#import <DConnectSDK/DConnectServiceInformationProfile.h>
#import "DPAllJoynHandler.h"
#import "DPAllJoynLightProfile.h"
#import "DPAllJoynServiceDiscoveryProfile.h"
#import "DPAllJoynServiceInformationProfile.h"
#import "DPAllJoynSystemProfile.h"


static NSString *const VERSION = @"1.0.0";


@implementation DPAllJoynDevicePlugin {
    DPAllJoynHandler *_handler;
}

- (instancetype) init {
    if ([AJNInit alljoynInit] != ER_OK) {
        DCLogError(@"AllJoyn global init failed.");
        return nil;
    }
    if ([AJNInit alljoynRouterInit] != ER_OK) {
        DCLogError(@"AllJoyn global router init failed.");
        [AJNInit alljoynShutdown];
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.pluginName = [NSString stringWithFormat:@"AllJoyn %@", VERSION];
        
        _handler = [DPAllJoynHandler new];
        
        // Add profiles.
        [self addProfile:[[DPAllJoynServiceDiscoveryProfile alloc]
                          initWithHandler:_handler]];
        [self addProfile:[DPAllJoynSystemProfile systemProfileWithVersion:VERSION]];
        [self addProfile:[[DPAllJoynServiceInformationProfile alloc]
                          initWithProvider:self handler:_handler
                          version:VERSION]];
        [self addProfile:[[DPAllJoynLightProfile alloc]
                          initWithHandler:_handler]];
        
        id block;
        block = ^(BOOL result) {
            if (!result) {
                DCLogWarn2(@"DPAllJoynDevicePlugin:init", @"AllJoyn init failed, retrying...");
                [_handler postBlock:^{
                    [_handler initAllJoynContextWithBlock:block];
                } withDelay:5000];
            }
        };
        [_handler initAllJoynContextWithBlock:block];
    }
    return self;
}


- (void)dealloc
{
    [AJNInit alljoynRouterShutdown];
    [AJNInit alljoynShutdown];
}

@end
