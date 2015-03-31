//
//  AppDelegate.m
//  dConnectSDKSample
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"
#import <DConnectSDK/DConnectSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[DConnectManager sharedManager] start];
    return YES;
}

@end
