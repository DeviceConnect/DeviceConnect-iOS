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
						// 許可されていない場合は無視
						if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
						
						// Topicを購読
						NSString *responseTopic = [NSString stringWithFormat:@"deviceconnect/%@/response", key];
						NSLog(@"subscribeWithTopic:%@, %@", responseTopic, key);
						[[DPAWSIoTManager sharedManager] subscribeWithTopic:responseTopic messageHandler:^(id json, NSError *error) {
							if (error) {
								// TODO: エラー処理
								NSLog(@"%@", error);
								return;
							}
							[self receivedResponseFromMQTT:json from:managers[key] uuid:key];
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
	// リクエストコード生成
	u_int32_t requestCode = arc4random();
	
	if ([request serviceId] && ![[request profile] isEqualToString:DConnectSystemProfileName]) {
		// 通常処理
		return [self sendRequestToMQTT:request code:requestCode response:response];
	} else if ([[request profile] isEqualToString:DConnectServiceDiscoveryProfileName]) {
		// servicediscoveryは独自処理
		// 自分のServiceを検索
		[super executeRequest:request response:response];
		// フラグでloop防止
		if ([request hasKey:@"_awsiot"]) {
			return YES;
		}
		[request setString:@"true" forKey:@"_awsiot"];
		// クラウド上のServiceを検索
		if (_managers) {
			// TODO: 最適化
			// サービス数を保持
			int count = 0;
			for (NSString *key in _managers.allKeys) {
				// 許可されていない場合は無視
				if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
				count++;
			}
			[response setInteger:count forKey:@"servicecount"];
			// クラウド上のServiceを検索
			for (NSString *key in _managers.allKeys) {
				// 許可されていない場合は無視
				if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
				// ServiceIdにManagerのUUIDを埋め込む
				[request setString:key forKey:@"serviceId"];
				[self sendRequestToMQTT:request code:requestCode response:response];
			}
			// タイムアウトの処理（servicediscoveryのタイムアウトが8秒なので、こちらは7秒）
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				NSString *requestCodeStr = [@(requestCode) stringValue];
				if (_responses[requestCodeStr]) {
					[[DConnectManager sharedManager] sendResponse:response];
					[_responses removeObjectForKey:requestCodeStr];
				}
				NSLog(@"timeout!!:%@, %@", _responses, requestCodeStr);
			});
			return NO;
		} else {
			return YES;
		}
	} else {
		// 自分のServiceを検索
		return [super executeRequest:request response:response];
	}
}

// MQTTにリクエストを送信
- (BOOL)sendRequestToMQTT:(DConnectRequestMessage *)request code:(u_int32_t)requestCode response:(DConnectResponseMessage *)response {
	// Actionコードを文字列に修正
	NSString *requestCodeStr = [@(requestCode) stringValue];
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
			[_responses removeObjectForKey:requestCodeStr];
			return YES;
		}
		managerUUID = [domains objectAtIndex:0];
		serviceId = [serviceId stringByReplacingOccurrencesOfString:[managerUUID stringByAppendingString:@"."] withString:@""];
		reqDic[@"serviceId"] = serviceId;
	}
	// 不要なパラメータ削除
	[reqDic removeObjectForKey:@"accessToken"];
	[reqDic removeObjectForKey:@"version"];
	// リクエストjson構築
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
	[_responses setObject:response forKey:requestCodeStr];
	// MQTT送信
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", managerUUID];
	[[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg];
	return NO;
}

// MQTTからレスポンスを受診
- (void)receivedResponseFromMQTT:(id)json from:(NSDictionary*)manager uuid:(NSString*)uuid {
	NSLog(@"receivedResponseFromMQTT:%@", json);
	NSString *requestCode = [json[@"requestCode"] stringValue];
	DConnectResponseMessage *response = _responses[requestCode];
	//NSLog(@"%@, %@, %@", response, _responses, requestCode);
	if (response) {
		int count = (int)[response integerForKey:@"servicecount"];
		NSLog(@"count:%d", count);
		if (count > 0) {
			// servicediscoveryの場合各サービスからのレスポンスを保持
			NSDictionary *resJson = json[@"response"];
			int result = [resJson[DConnectMessageResult] intValue];
			if (result == DConnectMessageResultTypeOk) {
				NSArray *foundServices = resJson[DConnectServiceDiscoveryProfileParamServices];
				if ([foundServices count] > 0) {
					// responseに追加
					DConnectArray *services = [response arrayForKey:DConnectServiceDiscoveryProfileParamServices];
					for (id item in foundServices) {
						// idとnameを加工
						DConnectMessage *msg = [DConnectMessage initWithDictionary:item];
						NSString *serviceId = [msg stringForKey:DConnectServiceDiscoveryProfileParamId];
						if (serviceId) {
							serviceId = [uuid stringByAppendingString:[@"." stringByAppendingString:serviceId]];
							[msg setString:serviceId forKey:DConnectServiceDiscoveryProfileParamId];
						}
						NSString *serviceName = [msg stringForKey:DConnectServiceDiscoveryProfileParamName];
						if (serviceName) {
							NSString *str = [NSString stringWithFormat:@" (%@)", manager[@"name"]];
							NSString *name = [serviceName stringByAppendingString:str];
							[msg setString:name forKey:DConnectServiceDiscoveryProfileParamName];
						}
						[services addMessage:msg];
					}
				}
			}
			// カウントダウン
			count -= 1;
			if (count == 0) {
				// 送信
				[[DConnectManager sharedManager] sendResponse:response];
				[_responses removeObjectForKey:requestCode];
			} else {
				// カウントダウンの値を保持
				[response setInteger:(int)count forKey:@"servicecount"];
			}
		} else {
			// 通常の処理
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
