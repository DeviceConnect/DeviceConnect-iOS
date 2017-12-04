//
//  DPHitoeImmediateEventDispatcher.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeImmediateEventDispatcher.h"

@implementation DPHitoeImmediateEventDispatcher
- (instancetype)initWithDevicePlugin:(DConnectDevicePlugin *)devicePlugin {
    return [super initWithDevicePlugin:devicePlugin];
}

- (void)sendEventForMessge:(DConnectMessage *)message {
    [super sendEventInternalForMessage:message];
}
- (void)start {
    //do nothing
}
- (void)stop {
    //do nothing
}

@end
