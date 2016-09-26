//
//  DPAWSIoTSystemProfile.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTSystemProfile.h"
#import "DPAWSIoTDevicePlugin.h"

@implementation DPAWSIoTSystemProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.dataSource = self;
		__weak DPAWSIoTSystemProfile *weakSelf = self;
		
		// API登録(dataSourceのsettingPageForRequestを実行する処理を登録)
		NSString *putSettingPageForRequestApiPath = [self apiPath: DConnectSystemProfileInterfaceDevice
													attributeName: DConnectSystemProfileAttrWakeUp];
		[self addPutPath: putSettingPageForRequestApiPath
					 api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
						 
						 BOOL send = [weakSelf didReceivePutWakeupRequest:request response:response];
						 return send;
					 }];
	}
	return self;
}

// デバイスプラグインのバージョン
- (NSString *) versionOfSystemProfile:(DConnectSystemProfile *)profile
{
	return @"2.0.0";
}

// デバイスプラグインの設定画面用のUIViewControllerを要求する
- (UIViewController *) profile:(DConnectSystemProfile *)sender
		 settingPageForRequest:(DConnectRequestMessage *)request
{
	
	// 設定画面用のViewControllerをStoryboardから生成する
	NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"dConnectDeviceAWSIoT_resources" ofType:@"bundle"];
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	
	UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"AWSIoT" bundle:bundle];
	return [storyBoard instantiateInitialViewController];
}


@end
