//
//  DPHitoeEventDispatcherFactory.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeEventDispatcherFactory.h"

@implementation DPHitoeEventDispatcherFactory

+ (DPHitoeEventDispatcher*)createEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin
                                                        request:(DConnectRequestMessage*)request {
    if ([request stringForKey:@"interval"]) {
        int interval = [self getInterval:request];
        if (interval > 0) {
            return [self createIntervalEventDispatcherForDevicePlugin:devicePlugin periodTime:interval];
        }
    }
    return [self createImmediateEventDispatcherForDevicePlugin:devicePlugin];
}
+ (DPHitoeEventDispatcher*)createIntervalEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin
                                                             periodTime:(int)periodTime {
    return [[DPHitoeIntervalEventDispatcher alloc] initWithDevicePlugin:devicePlugin firstPeriodTime:periodTime periodTime:periodTime];
}
+ (DPHitoeEventDispatcher*)createImmediateEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin {
    return [[DPHItoeImmediateEventDispatcher alloc] initWithDevicePlugin:devicePlugin];
}

+ (int)getInterval:(DConnectRequestMessage*)request {
    NSString *interval = [request stringForKey:@"interval"];
    return [interval intValue];
}
@end
