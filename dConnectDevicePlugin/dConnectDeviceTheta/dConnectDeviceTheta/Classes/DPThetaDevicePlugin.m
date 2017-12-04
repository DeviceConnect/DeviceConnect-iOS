//
//  dConnectDeviceTheta.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaDevicePlugin.h"
#import "DPThetaSystemProfile.h"
#import "DPThetaManager.h"

@implementation DPThetaDevicePlugin


- (id) init
{
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Theta (Device Connect Device Plug-in)";
        [[DPThetaManager sharedManager] setServiceProvider: self.serviceProvider];
        [[DPThetaManager sharedManager] setPlugin:self];
        
        self.fileMgr = [DConnectFileManager fileManagerForPlugin:self];
        [self addProfile:[DPThetaSystemProfile new]];
        __weak typeof(self) _self = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            [notificationCenter addObserver:_self selector:@selector(applicationWillEnterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
            [notificationCenter addObserver:_self selector:@selector(applicationDidEnterBackground)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:application];
        });
    }
    
    return self;
}
- (void) dealloc {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    UIApplication *application = [UIApplication sharedApplication];
    
    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
    [notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
}

- (void) applicationWillEnterForeground {
    [[DPThetaManager sharedManager] applicationWillEnterForeground];
}

- (void) applicationDidEnterBackground {
    [[DPThetaManager sharedManager] applicationDidEnterBackground];
}


- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DPThetaBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceTheta_resources" ofType:@"bundle"]];
}

@end
