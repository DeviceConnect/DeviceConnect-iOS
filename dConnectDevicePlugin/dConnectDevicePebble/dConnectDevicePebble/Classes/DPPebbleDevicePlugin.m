//
//  DPPebbleDevicePlugin.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleDevicePlugin.h"
#import "DPPebbleSystemProfile.h"
#import "PebbleViewController.h"
#import "DPPebbleManager.h"

#define DCPebbleBundle() \
[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDevicePebble_resources" ofType:@"bundle"]]

@interface DPPebbleDevicePlugin ()
@end


@implementation DPPebbleDevicePlugin

- (instancetype) init
{
	self = [super initWithObject: self];
	if (self) {
		// プラグイン名を設定
		self.pluginName = @"Pebble (Device Connect Device Plug-in)";
		
		// EventManagerの初期化
		Class key = [self class];
		[[DConnectEventManager sharedManagerForClass:key] setController:[DConnectMemoryCacheController new]];

        // DPPebbleManagerへServiceProviderを渡す
        [[DPPebbleManager sharedManager] setServiceProvider: self.serviceProvider];
        [[DPPebbleManager sharedManager] setPlugin: self];
        
        // ServiceProvider更新
        [[DPPebbleManager sharedManager] updateManageServices];
        
		// 各プロファイルの追加
        [self addProfile:[DPPebbleSystemProfile new]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
			UIApplication *application = [UIApplication sharedApplication];
			
			[notificationCenter addObserver:self selector:@selector(enterForeground)
					   name:UIApplicationWillEnterForegroundNotification
					 object:application];
			
			[notificationCenter addObserver:self selector:@selector(enterBackground)
					   name:UIApplicationDidEnterBackgroundNotification
					 object:application];
		});

	}
	return self;
}

- (void) dealloc
{
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	UIApplication *application = [UIApplication sharedApplication];
	[notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:application];
	[notificationCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:application];
}

- (void)enterBackground
{
	[[DPPebbleManager sharedManager] applicationDidEnterBackground];
}

- (void)enterForeground
{
	[[DPPebbleManager sharedManager] applicationWillEnterForeground];
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = DCPebbleBundle();
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDevicePebble_resources" ofType:@"bundle"]];
}

@end
