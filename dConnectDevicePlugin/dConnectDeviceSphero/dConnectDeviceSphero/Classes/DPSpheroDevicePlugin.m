//
//  DPSpheroDevicePlugin.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroDevicePlugin.h"
#import "DPSpheroSystemProfile.h"
#import "DPSpheroManager.h"
#import <RobotKit/RobotKit.h>

@interface DPSpheroDevicePlugin()
@end

@implementation DPSpheroDevicePlugin

// 初期化
- (id) init
{
    self = [super initWithObject: self];
    
    if (self) {
        self.pluginName = @"Sphero (Device Connect Device Plug-in)";

        Class key = [self class];
        [[DConnectEventManager sharedManagerForClass:key]
                setController:[DConnectMemoryCacheController new]];
        
        [[DPSpheroManager sharedManager] setServiceProvider: self.serviceProvider];

        // System Profileの追加
        [self addProfile:[DPSpheroSystemProfile new]];

        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            
            [notificationCenter addObserver:_self selector:@selector(enterForeground)
                       name:UIApplicationWillEnterForegroundNotification
                     object:application];
            
            [notificationCenter addObserver:_self selector:@selector(enterBackground)
                       name:UIApplicationDidEnterBackgroundNotification
                     object:application];
            [notificationCenter addObserver:_self selector:@selector(enterNoLongerAvailable)
                                       name:RKRobotIsNoLongerAvailableNotification
                                     object:application];

        });
    }
    
    return self;
}
- (void)enterBackground {
    [[DPSpheroManager sharedManager] applicationDidEnterBackground];
}

- (void)enterForeground {
    [[DPSpheroManager sharedManager] applicationWillEnterForeground];
}
- (void)enterNoLongerAvailable {
    [[DPSpheroManager sharedManager] applicationDidEnterBackground];
}
- (void) dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
    [notificationCenter removeObserver:self name:RKRobotIsNoLongerAvailableNotification object:application];
}
@end
