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
#import "DPAllJoynHandler.h"
#import "DPAllJoynLightProfile.h"
#import "DPAllJoynSystemProfile.h"


static NSString *const VERSION = @"2.0.0";


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
    
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"AllJoyn (Device Connect Device Plug-in)";
        
        _handler = [DPAllJoynHandler new];
        [_handler setServiceProvider: self.serviceProvider];
        [_handler setPlugin: self];
        
        // Add profiles.
        [self addProfile:[DPAllJoynSystemProfile systemProfileWithVersion:VERSION]];
        
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
- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPAllJoynResourceBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceAllJoyn_resources" ofType:@"bundle"]];
}

@end
