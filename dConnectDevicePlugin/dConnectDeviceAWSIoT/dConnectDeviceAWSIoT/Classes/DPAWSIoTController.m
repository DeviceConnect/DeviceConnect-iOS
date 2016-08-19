//
//  DPAWSIoTController.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTController.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTUtils.h"

// TODO: 名前を決める
#define kShadowName @"dconnect"
// TODO: 本来は定数じゃなくManagerのUUID/Nameを取得
#define kManagerUUID @"abc"
#define kManagerName @"あいう"

@implementation DPAWSIoTController

// 共有インスタンス
+ (instancetype)sharedManager {
	static DPAWSIoTController *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[DPAWSIoTController alloc] init];
	});
	return _sharedInstance;
}

// ManagerUUIDを返す
+ (NSString*)managerUUID {
	// TODO: 仮
	return kManagerUUID;
}

// ManagerNameを返す
+ (NSString*)managerName {
	// TODO: 仮
	return kManagerName;
}


// Shadowからデバイス情報を取得する
+ (void)fetchManagerInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler {
	[[DPAWSIoTManager sharedManager] fetchShadowWithName:kShadowName
									   completionHandler:^(id json, NSError *error)
	 {
		 if (error) {
			 handler(nil, nil, error);
			 return;
		 }
		 // 自分の情報
		 NSDictionary *myInfo = json[@"state"][@"reported"][kManagerUUID];
		 // 自分以外の情報
		 NSMutableDictionary *managers = [json[@"state"][@"reported"] mutableCopy];
		 [managers removeObjectForKey:kManagerUUID];
		 handler(managers, myInfo, nil);
	 }];
}

// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler {
	NSDictionary *info = @{@"name": kManagerName, @"online": @(online), @"timeStamp": @([[NSDate date] timeIntervalSince1970])};
	NSDictionary *dic = @{@"state": @{@"reported": @{kManagerUUID: info}}};
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
	if (error) {
		handler(error);
		return;
	}
	NSString *val = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	[[DPAWSIoTManager sharedManager] updateShadowWithName:kShadowName value:val completionHandler:^(NSError *error) {
		handler(error);
	}];
}

// RequestTopic購読
+ (void)subscribeRequest {
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", kManagerUUID];
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:requestTopic messageHandler:^(id json, NSError *error) {
		if (error) {
			// TODO: エラー処理
			NSLog(@"%@", error);
			return;
		}
		// MQTTからHTTPへ
		//NSLog(@"request:%@", json);
		[DPAWSIoTUtils sendRequest:json[@"request"] handler:^(NSData *data, NSError *error) {
			if (error) {
				// TODO: エラー処理
				NSLog(@"%@", error);
				return;
			}
			// 返却形式にフォーマット
			NSDictionary *resJson = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			NSMutableDictionary *dic = [NSMutableDictionary dictionary];
			[dic setObject:json[@"requestCode"] forKey:@"requestCode"];
			[dic setObject:resJson forKey:@"response"];
			NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
			if (error) {
				// TODO: エラー処理
				NSLog(@"%@", error);
				return;
			}
			// レスポンスをMQTT送信
			NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
			NSString *responseTopic = [NSString stringWithFormat:@"deviceconnect/%@/response", kManagerUUID];
			NSLog(@"%@, %@", responseTopic, msg);
			if (![[DPAWSIoTManager sharedManager] publishWithTopic:responseTopic message:msg]) {
				// TODO: エラー処理
			}
		}];
	}];
}

// RequestTopic購読解除
+ (void)unsubscribeRequest {
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", kManagerUUID];
	[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:requestTopic];
}

@end
