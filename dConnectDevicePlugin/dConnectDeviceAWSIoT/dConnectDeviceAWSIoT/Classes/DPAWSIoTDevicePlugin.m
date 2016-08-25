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
#import "DPAWSIoTService.h"
#import "DPAWSIoTUtils.h"
#import "DPAWSIoTManager.h"
#import "DPAWSIoTController.h"
#import "DConnectDevicePlugin+Private.h"
#import "DConnectMessage+Private.h"

#import <AWSIoT.h>

@interface DPAWSIoTDevicePlugin () {
	NSMutableDictionary *_responses;
	NSString *_managerUUID;
	NSDictionary *_managers;
}
@end

@implementation DPAWSIoTDevicePlugin

// 初期化
- (id)init {
	self = [super initWithObject:self];
	if (self) {
		self.pluginName = @"AWSIoT (Device Connect Device Plug-in)";
		_responses = [NSMutableDictionary dictionary];
		_managerUUID = [DPAWSIoTController managerUUID];
		self.useLocalOAuth = NO;
		
		// プロファイルを追加
		[self addProfile:[DPAWSIoTSystemProfile new]];
		//
		DPAWSIoTService *service = [[DPAWSIoTService alloc] initWithServiceId:@"awsiot"
																   deviceName:@"AWSIoT"
																	   plugin:self];
		[service setOnline:YES];
		[self.serviceProvider addService:service];
		
		// アカウントの設定がある場合は
		if ([DPAWSIoTUtils hasAccount] && ![DPAWSIoTManager sharedManager].isConnected) {
			// ログイン
			[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
				if (error) {
					// TODO: エラー処理
					NSLog(@"%@", error);
					return;
				}
				// Shadow取得
				[DPAWSIoTController fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
					if (error) {
						// TODO: エラー処理
						NSLog(@"%@", error);
						return;
					}
					_managers = managers;
					// onlineの時だけRequestTopic購読
					if ([myInfo[@"online"] boolValue]) {
						[DPAWSIoTController subscribeRequest];
					}
					// ResponseTopic購読
					for (NSString *key in managers.allKeys) {
						// onlineじゃない場合は無視
						if (![managers[key][@"online"] boolValue]) continue;
						
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
	NSLog(@"*********** executeRequest: %@, %@,%@,%@", [request serviceId], [request profile], [request interface], [request attribute]);
	if ([request serviceId] && ![[request profile] isEqualToString:DConnectSystemProfileName]) {
		return [self sendRequestToMQTT:request response:response];
	} else if ([[request profile] isEqualToString:DConnectServiceDiscoveryProfileName]) {
		// servicediscoveryは独自処理
		// 自分のServiceを検索
		[super executeRequest:request response:response];
		if (_managers) {
			// サービス数を保持
			[response setInteger:(int)_managers.count forKey:@"servicecount"];
			// クラウド上のServiceを検索
			for (NSString *key in _managers.allKeys) {
				// onlineじゃない場合は無視
				if (![_managers[key][@"online"] boolValue]) continue;
				// ServiceIdにManagerのUUIDを埋め込む
				[request setString:key forKey:@"serviceId"];
				[self sendRequestToMQTT:request response:response];
				// TODO: タイムアウトを実装（7秒以下で）
			}
			return NO;
		} else {
			return YES;
		}
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
	// serviceIdを処理
	NSString *serviceId = reqDic[@"serviceId"];
	if (!serviceId) {
		[response setResult:DConnectMessageResultTypeError];
		return YES;
	}
	NSString *managerUUID;
	if ([[request profile] isEqualToString:DConnectServiceDiscoveryProfileName]) {
		// servicediscoveryは独自処理
		managerUUID = reqDic[@"serviceId"];
		[reqDic removeObjectForKey:@"serviceId"];
	} else {
		// managerのUUIDをserviceIdから取得
		NSArray *domains = [serviceId componentsSeparatedByString:@"."];
		if (domains == nil || [domains count] < 2) {
			[response setResult:DConnectMessageResultTypeError];
			return YES;
		}
		managerUUID = [domains objectAtIndex:0];
		serviceId = [serviceId stringByReplacingOccurrencesOfString:[managerUUID stringByAppendingString:@"."] withString:@""];
		reqDic[@"serviceId"] = serviceId;
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
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", managerUUID];
	[[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg];
	return NO;
}

// MQTTからレスポンスを受診
- (void)receivedResponseFromMQTT:(id)json {
	NSString *requestCode = [json[@"requestCode"] stringValue];
	DConnectResponseMessage *response = _responses[requestCode];
	if (response) {
		NSInteger count = [response integerForKey:@"servicecount"];
		if (count > 0) {
			// servicediscoveryの場合各サービスからのレスポンスを保持
			// TODO: 実装
		} else {
			NSDictionary *resJson = json[@"response"];
			for (NSString *key in resJson.allKeys) {
				id obj = resJson[key];
				[response.internalDictionary setObject:obj forKey:key];
			}
			[[DConnectManager sharedManager] sendResponse:response];
			[_responses removeObjectForKey:requestCode];
		}
	}
}

@end
