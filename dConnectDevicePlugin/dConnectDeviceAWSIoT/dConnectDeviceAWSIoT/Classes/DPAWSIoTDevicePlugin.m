//
//  DPAWSIoTDevicePlugin.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#import "DPAWSIoTDevicePlugin.h"
#import "DPAWSIoTSystemProfile.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTController.h"
#import "DPAWSIoTManager.h"
#import "DConnectDevicePlugin+Private.h"

#import <AWSIoT.h>

@interface DPAWSIoTDevicePlugin () {
}
@end

@implementation DPAWSIoTDevicePlugin

// 初期化
- (id)init {
	self = [super initWithObject:self];
	if (self) {
		self.pluginName = @"AWSIoT (Device Connect Device Plug-in)";
		self.useLocalOAuth = NO;
        
        [[DConnectEventManager sharedManagerForClass:[self class]]
            setController:[DConnectMemoryCacheController new]];
		
        // プロファイルを追加
		[self addProfile:[DPAWSIoTSystemProfile new]];

		// AWSIoTログイン処理
		[DPAWSIoTController sharedManager].plugin = self;
		[[DPAWSIoTController sharedManager] login];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            UIApplication *application = [UIApplication sharedApplication];
            
            [notificationCenter addObserver:weakSelf selector:@selector(enterForeground)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:application];
            
            [notificationCenter addObserver:weakSelf selector:@selector(enterBackground)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:application];
        });
	}	
	return self;
}

- (void)enterBackground {
//    [[DPAWSIoTController sharedManager] logout];
}

- (void)enterForeground {
//    [[DPAWSIoTController sharedManager] login];
    NSString *accessToken = [DPAWSIoTUtils accessToken];
    if (accessToken) {
        [[DPAWSIoTController sharedManager] openWebSocket:accessToken];
    }
    [[DPAWSIoTController sharedManager] fetchManagerInfo];
}

// リクエスト処理
- (BOOL)executeRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
	// リクエストコード生成
	u_int32_t requestCode = arc4random();
	
	if ([request serviceId] && ![[request profile] isEqualToString:DConnectSystemProfileName]) {
		// 通常処理
		return [[DPAWSIoTController sharedManager] sendRequestToMQTT:request code:requestCode response:response];
	} else if ([[request profile] isEqualToString:DConnectServiceDiscoveryProfileName]) {
		// servicediscoveryは独自処理
		return [[DPAWSIoTController sharedManager] executeServiceDiscoveryRequest:request response:response requestCode:requestCode];
	} else {
		// 自分のServiceを検索
		return [super executeRequest:request response:response];
	}
}

- (NSString*)iconFilePath:(BOOL)isOnline
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceAWSIoT_resources" ofType:@"bundle"]];
    NSString* filename = isOnline ? @"dconnect_icon" : @"dconnect_icon_off";
    return [bundle pathForResource:filename ofType:@"png"];
}
#pragma mark - DevicePlugin's bundle
- (NSBundle*)pluginBundle
{
    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceAWSIoT_resources" ofType:@"bundle"]];
}
@end
