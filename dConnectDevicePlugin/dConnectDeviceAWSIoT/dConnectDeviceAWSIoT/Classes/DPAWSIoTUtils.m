//
//  DPAWSIoTUtils.m
//  dConnectDeviceAWSIoT
//
//  Created by zuvola on 2016/08/12.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "DPAWSIoTUtils.h"
#import "DPAWSIoTKeychain.h"
#import "DPAWSIoTManager.h"

#define kAccessKeyID @"accessKey"
#define kSecretKey @"secretKey"
#define kRegionKey @"regionKey"

// TODO: 名前を決める
#define kShadowName @"dconnect"

@implementation DPAWSIoTUtils

// ローディング画面
static UIViewController *loadingHUD;


// アカウントの設定があるか
+ (BOOL)hasAccount {
	NSString *accessKey = [DPAWSIoTKeychain findWithKey:kAccessKeyID];
	NSString *secretKey = [DPAWSIoTKeychain findWithKey:kSecretKey];
	return accessKey!=nil && secretKey!=nil;
}

// アカウントの設定をクリア
+ (void)clearAccount {
	[DPAWSIoTKeychain deleteWithKey:kAccessKeyID];
	[DPAWSIoTKeychain deleteWithKey:kSecretKey];
	[DPAWSIoTKeychain deleteWithKey:kRegionKey];
}

// アカウントを設定
+ (void)setAccount:(NSString*)accessKey secretKey:(NSString*)secretKey region:(NSInteger)region {
	[DPAWSIoTKeychain updateValue:accessKey key:kAccessKeyID];
	[DPAWSIoTKeychain updateValue:secretKey key:kSecretKey];
	[DPAWSIoTKeychain updateValue:[@(region) stringValue] key:kRegionKey];
}

// ログイン
+ (void)loginWithHandler:(void (^)(NSError *error))handler {
	NSString *accessKey = [DPAWSIoTKeychain findWithKey:kAccessKeyID];
	NSString *secretKey = [DPAWSIoTKeychain findWithKey:kSecretKey];
	NSInteger region = [[DPAWSIoTKeychain findWithKey:kRegionKey] integerValue];
	[[DPAWSIoTManager sharedManager] connectWithAccessKey:accessKey secretKey:secretKey region:region completionHandler:^(NSError *error) {
		if (error) {
			// TODO: アラート
			NSLog(@"%@", error);
			// 失敗したアカウントはクリアする
			[DPAWSIoTUtils clearAccount];
		}
		if (handler) {
			handler(error);
		}
	}];
}

// ローディング画面表示
+ (void)showLoadingHUD:(UIStoryboard*)storyboard {
	if (!loadingHUD) {
		loadingHUD = [storyboard instantiateViewControllerWithIdentifier:@"LoadingHUD"];
	}
	[[UIApplication sharedApplication].keyWindow addSubview:loadingHUD.view];
	loadingHUD.view.alpha = 0;
	[UIView animateWithDuration:0.4 animations:^{
		loadingHUD.view.alpha = 1.0;
	}];
}

// ローディング画面非表示
+ (void)hideLoadingHUD {
	[UIView animateWithDuration:0.3 animations:^{
		loadingHUD.view.alpha = 0;
	} completion:^(BOOL finished) {
		[loadingHUD.view removeFromSuperview];
	}];
}

// Shadow取得
+ (void)fetchShadowWithHandler:(void (^)(id json, NSError *error))handler {
	[[DPAWSIoTManager sharedManager] fetchShadowWithName:kShadowName completionHandler:handler];
}

@end
