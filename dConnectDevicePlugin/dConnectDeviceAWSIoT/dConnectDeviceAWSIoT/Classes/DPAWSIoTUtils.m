//
//  DPAWSIoTUtils.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTUtils.h"
#import "DPAWSIoTKeychain.h"
#import "DPAWSIoTManager.h"

#define kAccessKeyID @"accessKey"
#define kSecretKey @"secretKey"
#define kRegionKey @"regionKey"


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
	loadingHUD.view.tag = 0;
	[UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
		loadingHUD.view.alpha = 1.0;
	} completion:^(BOOL finished) {
		loadingHUD.view.tag = 1;
	}];
}

// ローディング画面非表示
+ (void)hideLoadingHUD {
	if (loadingHUD.view.tag == 0) {
		[loadingHUD.view removeFromSuperview];
	} else {
		[UIView animateWithDuration:0.2 animations:^{
			loadingHUD.view.alpha = 0;
		} completion:^(BOOL finished) {
			[loadingHUD.view removeFromSuperview];
		}];
	}
}

// メニュー作成
+ (UIAlertController*)createMenu:(NSArray*)items handler:(void (^)(int index))handler {
	UIAlertController *alert =
	[UIAlertController alertControllerWithTitle:nil
										message:nil
								 preferredStyle:UIAlertControllerStyleActionSheet];
 
	// cancel
	UIAlertAction * cancelAction =
	[UIAlertAction actionWithTitle:@"Cancel"
							 style:UIAlertActionStyleCancel
						   handler:nil];
	[alert addAction:cancelAction];

	// メニューアイテム
	for (int i=0; i<items.count; i++) {
		UIAlertAction * action =
		[UIAlertAction actionWithTitle:items[i]
								 style:UIAlertActionStyleDefault
							   handler:^(UIAlertAction * action)
		 {
			 handler(i);
		 }];
		[alert addAction:action];
	}
	return alert;
}

@end
