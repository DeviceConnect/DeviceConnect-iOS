//
//  DPPebbleDevicePlugin.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleDevicePlugin.h"
#import "DPPebbleServiceDiscoveryProfile.h"
#import "DPPebbleSystemProfile.h"
#import "DPPebbleBatteryProfile.h"
#import "DPPebbleVibrationProfile.h"
#import "DPPebbleSettingsProfile.h"
#import "DPPebbleDeviceOrientationProfile.h"
#import "DPPebbleNotificationProfile.h"
#import "DPPebbleCanvasProfile.h"
#import "DPPebbleKeyEventProfile.h"
#import "PebbleViewController.h"
#import "DPPebbleManager.h"


@interface DPPebbleDevicePlugin ()
@end


@implementation DPPebbleDevicePlugin

- (instancetype) init
{
	self = [super init];
	if (self) {
		// プラグイン名を設定
		self.pluginName = @"Pebble (Device Connect Device Plug-in)";
		
		// EventManagerの初期化
		Class key = [self class];
		[[DConnectEventManager sharedManagerForClass:key] setController:[DConnectMemoryCacheController new]];
		
		// 各プロファイルの追加
		[self addProfile:[DPPebbleServiceDiscoveryProfile new]];
		[self addProfile:[DPPebbleNotificationProfile new]];
		[self addProfile:[DPPebbleSystemProfile new]];
		[self addProfile:[DPPebbleBatteryProfile new]];
		[self addProfile:[DPPebbleSettingsProfile new]];
		[self addProfile:[DPPebbleVibrationProfile new]];
		[self addProfile:[DPPebbleDeviceOrientationProfile new]];
        [self addProfile:[DPPebbleCanvasProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
        [self addProfile:[DPPebbleKeyEventProfile new]];
		
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

@end
