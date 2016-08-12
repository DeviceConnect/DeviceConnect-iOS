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

@implementation DPAWSIoTUtils

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
@end
