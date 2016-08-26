//
//  DPHitoeEventDispatcher.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeEventDispatcher.h"


@interface DPHitoeEventDispatcher()
@property (nonatomic, strong)DConnectDevicePlugin *plugin;
@end
@implementation DPHitoeEventDispatcher

- (instancetype)initWithDevicePlugin:(DConnectDevicePlugin *)devicePlugin {
    if (!devicePlugin) {
        [NSException raise:NSInternalInconsistencyException
                    format:@"Service is nil"];

    }
    self = [super init];
    if (self) {
        _plugin = devicePlugin;
    }
    return self;
}

- (void)sendEventForMessge:(DConnectMessage *)message {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}
- (void)start {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];

}
- (void)stop {
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)sendEventInternalForMessage:(DConnectMessage *)message {
    [_plugin sendEvent:message];
}

@end
