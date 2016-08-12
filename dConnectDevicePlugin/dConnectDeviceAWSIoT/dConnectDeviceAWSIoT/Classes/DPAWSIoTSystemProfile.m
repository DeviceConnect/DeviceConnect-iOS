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
		self.delegate = self;
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

// イベント一括解除リクエストを受け取った
- (BOOL)                  profile:(DConnectSystemProfile *)profile
	didReceiveDeleteEventsRequest:(DConnectRequestMessage *)request
						 response:(DConnectResponseMessage *)response
					   sessionKey:(NSString *)sessionKey
{
	DConnectEventManager *eventMgr = [DConnectEventManager sharedManagerForClass:[DPAWSIoTDevicePlugin class]];
	if ([eventMgr removeEventsForSessionKey:sessionKey]) {
		[response setResult:DConnectMessageResultTypeOk];
	} else {
		[response setErrorToUnknownWithMessage:
		 @"Failed to remove events associated with the specified session key."];
	}
	return YES;
}

@end
