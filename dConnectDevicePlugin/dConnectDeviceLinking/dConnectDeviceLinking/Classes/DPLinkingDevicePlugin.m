//
//  DPLinkingDevicePlugin.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDevicePlugin.h"
#import "DPLinkingServiceDiscoveryProfile.h"
#import "DPLinkingSystemProfile.h"
#import "DPLinkingDeviceManager.h"

@implementation DPLinkingDevicePlugin

- (id) init
{
    self = [super initWithObject: self];
    if (self) {
        self.pluginName = @"Linking (Device Connect Device Plug-in)";

        DConnectMemoryCacheController *ctl = [[DConnectMemoryCacheController alloc] init];
        [[DConnectEventManager sharedManagerForClass:[self class]] setController:ctl];

        [self addProfile:[[DPLinkingServiceDiscoveryProfile alloc] initWithServiceProvider: self.serviceProvider]];
        [self addProfile:[DPLinkingSystemProfile systemProfile]];

        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            [notificationCenter addObserver:weakSelf
                                   selector:@selector(enterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
        });
    }
    return self;
}

- (void) enterForeground {
    [[DPLinkingDeviceManager sharedInstance] restart];
}

#pragma mark - DevicePlugin's icon image

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceLinking_resources" ofType:@"bundle"]];
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
    return nil;
}

#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceLinking_resources" ofType:@"bundle"]];
}
@end
