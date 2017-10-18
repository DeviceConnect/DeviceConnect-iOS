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

#define DPSpheroBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceSphero_resources" ofType:@"bundle"]]

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
        [[DPSpheroManager sharedManager] setPlugin:self];

        // System Profileの追加
        [self addProfile:[DPSpheroSystemProfile new]];

        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter addObserver:_self selector:@selector(enterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
            [notificationCenter addObserver:_self selector:@selector(enterBackground)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
            
            // Takes ~20 seconds to recognize a ball going offline
            // Recognizes immediately when we close the connection to the ball
            [notificationCenter addObserver:_self
                                   selector:@selector(handleRobotOffline)
                                       name:kRobotIsAvailableNotification
                                     object:nil];
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

- (void)handleRobotOnline {
    [[DPSpheroManager sharedManager] updateManageServices];
}
- (void)handleRobotOffline {
    [[DPSpheroManager sharedManager] updateManageServices];
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPSpheroBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceSphero_resources" ofType:@"bundle"]];
}

- (void) dealloc {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
    [notificationCenter removeObserver:self name:kRobotIsAvailableNotification object:application];
    [notificationCenter removeObserver:self name:kRobotDidChangeStateNotification object:application];
}
@end
