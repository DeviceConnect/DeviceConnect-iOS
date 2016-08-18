//
//  DPAWSIoTDevicePlugin.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTDevicePlugin.h"
#import "DPAWSIoTSystemProfile.h"
#import "DPAWSIoTServiceDiscoveryProfile.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTManager.h"
#import "DConnectDevicePlugin+Private.h"
#import "DConnectMessage+Private.h"

#import <AWSIoT.h>

// TODO: 本来は定数じゃなくManagerの名前を取得
#define kManagerName @"abc"

@interface DPAWSIoTDevicePlugin () {
	NSMutableDictionary *_responses;
}
@end

@implementation DPAWSIoTDevicePlugin

- (id)init {
	self = [super init];
	if (self) {
		self.pluginName = @"AWSIoT (Device Connect Device Plug-in)";
		_responses = [NSMutableDictionary dictionary];
		self.useLocalOAuth = NO;
		
		// イベントマネージャの準備
		Class key = [self class];
		[[DConnectEventManager sharedManagerForClass:key]
		 setController:[DConnectDBCacheController
						controllerWithClass:key]];
		
		// プロファイルを追加
		[self addProfile:[DPAWSIoTServiceDiscoveryProfile new]];
		[self addProfile:[DPAWSIoTSystemProfile new]];
		[self addProfile:[DConnectServiceInformationProfile new]];
		
		// アカウントの設定がある場合は
		if ([DPAWSIoTUtils hasAccount]) {
			// ログイン
			[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
				if (error) {
					// TODO: エラー処理
					NSLog(@"%@", error);
					return;
				}
				// RequestTopic購読
				// TODO: 設定でonの時だけ購読
				NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", kManagerName];
				[[DPAWSIoTManager sharedManager] subscribeWithTopic:requestTopic messageHandler:^(id json, NSError *error) {
					// TODO: 処理
					NSLog(@"request:%@", json);
				}];
				// Shadow取得
				[DPAWSIoTUtils fetchShadowWithHandler:^(id json, NSError *error) {
					if (error) {
						// TODO: エラー処理
						NSLog(@"%@", error);
						return;
					}
					// ResponseTopic購読
					NSDictionary *devices = json[@"state"][@"reported"];
					for (NSString *key in devices.allKeys) {
						// onlineじゃない場合は無視
						if (![devices[key][@"online"] boolValue]) continue;

						// Topicを購読
						NSString *responseTopic = [NSString stringWithFormat:@"deviceconnect/%@/response", key];
						[[DPAWSIoTManager sharedManager] subscribeWithTopic:responseTopic messageHandler:^(id json, NSError *error) {
							if (error) {
								// TODO: エラー処理
								NSLog(@"%@", error);
								return;
							}
							[self receivedResponseFromMQTT:json];
						}];
					}
				}];
			}];
		}

	}
	
	return self;
}

// リクエスト処理
- (BOOL)executeRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
	//NSLog(@"*********** executeRequest: %@, %@,%@,%@", [request serviceId], [request profile], [request interface], [request attribute]);
	if ([request serviceId] && ![[request profile] isEqualToString:@"system"]) {
		return [self sendRequestToMQTT:request response:response];
	} else {
		return [super executeRequest:request response:response];
	}
}

// MQTTにリクエストを送信
- (BOOL)sendRequestToMQTT:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
	// Actionコードを文字列に修正
	NSMutableDictionary *reqDic = [request internalDictionary];
	NSInteger actionCode = [reqDic[@"action"] integerValue];
	switch (actionCode) {
		case DConnectMessageActionTypeGet:
			reqDic[@"action"] = @"get";
			break;
		case DConnectMessageActionTypePost:
			reqDic[@"action"] = @"post";
			break;
		case DConnectMessageActionTypePut:
			reqDic[@"action"] = @"put";
			break;
		case DConnectMessageActionTypeDelete:
			reqDic[@"action"] = @"delete";
			break;
	}
	// リクエストjson構築
	int requestCode = arc4random();
	NSMutableDictionary *dic = [NSMutableDictionary dictionary];
	[dic setObject:@(requestCode) forKey:@"requestCode"];
	[dic setObject:[request internalDictionary] forKey:@"request"];
	NSError *err;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&err];
	if (err) {
		[response setResult:DConnectMessageResultTypeError];
		return YES;
	}
	NSString *msg = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	// レスポンス保持
	[_responses setObject:response forKey:[@(requestCode) stringValue]];
	// MQTT送信
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", kManagerName];
	[[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg];
	return NO;
}

// MQTTからレスポンスを受診
- (void)receivedResponseFromMQTT:(id)json {
	NSString *requestCode = [json[@"requestCode"] stringValue];
	DConnectResponseMessage *response = _responses[requestCode];
	if (response) {
		NSDictionary *resJson = json[@"response"];
		for (NSString *key in resJson.allKeys) {
			id obj = resJson[key];
			[response.internalDictionary setObject:obj forKey:key];
		}
		[[DConnectManager sharedManager] sendResponse:response];
	}
}

@end
