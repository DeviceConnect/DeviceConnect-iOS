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
#import "DPAWSIoTManager.h"
#import "DPAWSIoTController.h"
#import "DPAWSIoTWebSocket.h"

#import "DConnectMessage+Private.h"
#import "DConnectDevicePlugin+Private.h"
#import "DConnectManager+Private.h"
#import "DConnectManagerServiceDiscoveryProfile.h"

// TODO: 名前を決める
#define kShadowName @"dconnect"

@interface DPAWSIoTController () {
	NSMutableDictionary *_responses;
	NSDictionary *_managers;
	DPAWSIoTWebSocket *_webSocket;
}
@end

@implementation DPAWSIoTController

#pragma mark - **仮**

// ManagerUUIDを返す
+ (NSString*)managerUUID {
	// TODO: 仮
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *managerUUID = [defaults stringForKey:@"ManagerUUID"];
	if (!managerUUID) {
		managerUUID = [[NSUUID UUID] UUIDString];
		[defaults setObject:managerUUID forKey:@"ManagerUUID"];
		[defaults synchronize];
	}
	return managerUUID;
}

// ManagerNameを返す
+ (NSString*)managerName {
	// TODO: 仮
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *managerName = [defaults stringForKey:@"ManagerName"];
	if (!managerName) {
		int num = abs((int)arc4random() % 1000);
		managerName = [NSString stringWithFormat:@"manager-%04d", num];
		[defaults setObject:managerName forKey:@"ManagerName"];
		[defaults synchronize];
	}
	return managerName;
}


#pragma mark - Static

// 共有インスタンス
+ (instancetype)sharedManager {
	static DPAWSIoTController *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[DPAWSIoTController alloc] init];
	});
	return _sharedInstance;
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
		 NSDictionary *myInfo = json[@"state"][@"reported"][[DPAWSIoTController managerUUID]];
		 // 自分以外の情報
		 NSMutableDictionary *managers = [json[@"state"][@"reported"] mutableCopy];
		 // 自分の情報は削除
		 [managers removeObjectForKey:[DPAWSIoTController managerUUID]];
		 // onlineじゃない場合は削除
		 for (NSString *key in managers.allKeys) {
			 if (![managers[key][@"online"] boolValue]) {
				 [managers removeObjectForKey:key];
			 }
		 }
		 handler(managers, myInfo, nil);
	 }];
}

// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler {
	NSDictionary *info = @{@"name": [DPAWSIoTController managerName], @"online": @(online), @"timeStamp": @([[NSDate date] timeIntervalSince1970])};
	NSDictionary *dic = @{@"state": @{@"reported": @{[DPAWSIoTController managerUUID]: info}}};
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


#pragma mark - Public

// 初期化
- (instancetype)init
{
	self = [super init];
	if (self) {
		_responses = [NSMutableDictionary dictionary];
		_webSocket = [[DPAWSIoTWebSocket alloc] init];
		_webSocket.receivedHandler = ^(NSString *message) {
			// イベント送信
			[[DPAWSIoTController sharedManager] publishEvent:message];
		};
	}
	return self;
}

// ログイン
- (void)login {
	// アカウントの設定がある場合は
	if ([DPAWSIoTUtils hasAccount] && ![DPAWSIoTManager sharedManager].isConnected) {
		// ログイン
		[DPAWSIoTUtils loginWithHandler:^(NSError *error) {
			if (error) {
				// TODO: エラー処理
				NSLog(@"%@", error);
				return;
			}
			// Shadow更新時の処理
			[self subscribeManagerUpdateInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
				if (!error) {
					NSMutableDictionary *dict = [_managers mutableCopy];
					for (NSString *key in managers.allKeys) {
						dict[key] = managers[key];
					}
					_managers = dict;
				}
				[self updateManagers:managers myInfo:myInfo error:error];
			}];
			// Shadow取得
			[self fetchManagerInfo];
		}];
	}
}

// ログアウト
- (void)logout {
	[[DPAWSIoTManager sharedManager] disconnect];
	[DPAWSIoTUtils clearAccount];
}

// マネージャー情報を取得
- (void)fetchManagerInfo {
	// Shadow取得
	[DPAWSIoTController fetchManagerInfoWithHandler:^(NSDictionary *managers, NSDictionary *myInfo, NSError *error) {
		if (!error) {
			_managers = managers;
		}
		[self updateManagers:managers myInfo:myInfo error:error];
	}];
}


// MQTTにリクエストを送信
- (BOOL)sendRequestToMQTT:(DConnectRequestMessage *)request code:(u_int32_t)requestCode response:(DConnectResponseMessage *)response {
	// Actionコードを文字列に修正
	NSString *requestCodeStr = [@(requestCode) stringValue];
	NSMutableDictionary *reqDic = [request internalDictionary];
	NSInteger actionCode = [reqDic[DConnectMessageAction] integerValue];
	switch (actionCode) {
		case DConnectMessageActionTypeGet:
			reqDic[DConnectMessageAction] = @"get";
			break;
		case DConnectMessageActionTypePost:
			reqDic[DConnectMessageAction] = @"post";
			break;
		case DConnectMessageActionTypePut:
			reqDic[DConnectMessageAction] = @"put";
			break;
		case DConnectMessageActionTypeDelete:
			reqDic[DConnectMessageAction] = @"delete";
			break;
	}
	// serviceIdを処理
	NSString *serviceId = reqDic[DConnectMessageServiceId];
	if (!serviceId) {
		[response setResult:DConnectMessageResultTypeError];
		return YES;
	}
	NSString *managerUUID;
	if ([[request profile] isEqualToString:DConnectServiceDiscoveryProfileName]) {
		// servicediscoveryは独自処理
		managerUUID = reqDic[DConnectMessageServiceId];
		[reqDic removeObjectForKey:DConnectMessageServiceId];
	} else {
		// managerのUUIDをserviceIdから取得
		NSArray *domains = [serviceId componentsSeparatedByString:@"."];
		if (domains == nil || [domains count] < 2) {
			[response setResult:DConnectMessageResultTypeError];
			[_responses removeObjectForKey:requestCodeStr];
			return YES;
		}
		managerUUID = [domains objectAtIndex:0];
		// 許可されていない場合はエラー
		if (![DPAWSIoTUtils hasAllowedManager:managerUUID]) {
			[response setErrorToNotFoundService];
			return YES;
		}
		serviceId = [serviceId stringByReplacingOccurrencesOfString:[managerUUID stringByAppendingString:@"."] withString:@""];
		reqDic[DConnectMessageServiceId] = serviceId;
	}
	// 不要なパラメータ削除
	[reqDic removeObjectForKey:DConnectMessageAccessToken];
	[reqDic removeObjectForKey:DConnectMessageVersion];
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

// ServiceDiscoveryのRequestを処理
- (BOOL)executeServiceDiscoveryRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response requestCode:(u_int32_t)requestCode {
	// フラグでloop防止
	if ([request hasKey:@"_awsiot"]) {
		return YES;
	}
	[request setString:@"true" forKey:@"_awsiot"];
	if (_managers) {
		// サービス数を保持
		int count = 0;
		for (NSString *key in _managers.allKeys) {
			// 許可されていない場合は無視
			if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
			count++;
		}
		if (count == 0) {
			return YES;
		}
		[response setInteger:count forKey:@"servicecount"];
		// クラウド上のServiceを検索
		for (NSString *key in _managers.allKeys) {
			// 許可されていない場合は無視
			if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
			// ServiceIdにManagerのUUIDを埋め込む
			[request setString:key forKey:DConnectMessageServiceId];
			NSLog(@"sendRequestToMQTT:%@", key);
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
	
}

// Eventを発行
- (void)publishEvent:(NSString*)msg {
	NSString *topic = [NSString stringWithFormat:@"deviceconnect/%@/event", [DPAWSIoTController managerUUID]];
	NSLog(@"publishEvent:%@, %@", topic, msg);
	if (![[DPAWSIoTManager sharedManager] publishWithTopic:topic message:msg]) {
		// TODO: エラー処理
	}
}

// サービス一覧を取得
- (void)fetchServicesWithHandler:(void (^)(DConnectArray *services))handler {
	dispatch_async(dispatch_get_main_queue(), ^{
		DConnectManager *mgr = [DConnectManager sharedManager];
		DConnectManagerServiceDiscoveryProfile *p = (DConnectManagerServiceDiscoveryProfile*)[mgr profileWithName:DConnectServiceDiscoveryProfileName];
		DConnectResponseMessage *response = [DConnectResponseMessage message];
		DConnectRequestMessage *request = [DConnectRequestMessage new];
		[request setString:@"true" forKey:@"_awsiot"];
		[request setAction: DConnectMessageActionTypeGet];
		[p getServicesRequest:request response:response];
		if (response.result == DConnectMessageResultTypeOk) {
			handler(response.internalDictionary[@"services"]);
		} else {
			handler(nil);
		}
	});
}

// サービス情報を取得
- (DConnectResponseMessage*)fetchServiceInformationWithId:(NSString*)serviceId {
	DConnectManager *mgr = [DConnectManager sharedManager];
	DConnectDevicePlugin *plugin = [mgr.mDeviceManager devicePluginForServiceId:serviceId];
	if (plugin) {
		NSLog(@"plugin:%@", plugin.pluginName);
		DConnectResponseMessage *response = [DConnectResponseMessage message];
		DConnectRequestMessage *request = [DConnectRequestMessage new];
		[request setProfile:DConnectServiceInformationProfileName];
		[request setAction:DConnectMessageActionTypeGet];
		NSArray *names = [serviceId componentsSeparatedByString:@"."];
		[request setServiceId:names[0]];
		[plugin executeRequest:request response:response];
		NSLog(@"plugin-info:%@", response.internalDictionary);
		return response;
	} else {
		return nil;
	}
}

#pragma mark - Private

// Shadowのデバイスの更新情報を購読する
- (void)subscribeManagerUpdateInfoWithHandler:(void (^)(NSDictionary *managers, NSDictionary *myInfo, NSError *error))handler {
	NSString *topic = [NSString stringWithFormat:@"$aws/things/%@/shadow/update/accepted", kShadowName];
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:topic messageHandler:^(id json, NSError *error) {
		if (error) {
			handler(nil, nil, error);
			return;
		}
		// 自分の情報
		NSDictionary *myInfo = json[@"state"][@"reported"][[DPAWSIoTController managerUUID]];
		// 自分以外の情報
		NSMutableDictionary *managers = [json[@"state"][@"reported"] mutableCopy];
		[managers removeObjectForKey:[DPAWSIoTController managerUUID]];
		handler(managers, myInfo, nil);
	}];
}

// RequestTopic購読
- (void)subscribeRequest {
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", [DPAWSIoTController managerUUID]];
	NSLog(@"subscribeRequest:%@", requestTopic);
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:requestTopic messageHandler:^(id json, NSError *error) {
		if (error) {
			// TODO: エラー処理
			NSLog(@"%@", error);
			return;
		}
		if ([json[@"request"][DConnectMessageAction] isEqualToString:@"put"]) {
			// WebSocketにつなぐ
			NSString *key = json[@"request"][DConnectMessageSessionKey];
			NSLog(@"put:sessionKey:%@", key);
			[_webSocket addSocket:key];
		}
		if ([json[@"request"][DConnectMessageAction] isEqualToString:@"delete"]) {
			// WebSocketの接続解除
			NSString *key = json[@"request"][DConnectMessageSessionKey];
			NSLog(@"delete:sessionKey:%@", key);
			[_webSocket removeSocket:key];
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
			NSString *responseTopic = [NSString stringWithFormat:@"deviceconnect/%@/response", [DPAWSIoTController managerUUID]];
			NSLog(@"publish:%@, %@", responseTopic, msg);
			if (![[DPAWSIoTManager sharedManager] publishWithTopic:responseTopic message:msg]) {
				// TODO: エラー処理
			}
		}];
	}];
}

// RequestTopic購読解除
- (void)unsubscribeRequest {
	NSString *requestTopic = [NSString stringWithFormat:@"deviceconnect/%@/request", [DPAWSIoTController managerUUID]];
	NSLog(@"unsubscribeRequest:%@", requestTopic);
	[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:requestTopic];
}

// EventTopic購読
- (void)subscribeEvent:(NSString*)uuid {
	NSString *topic = [NSString stringWithFormat:@"deviceconnect/%@/event", uuid];
	NSLog(@"subscribeEvent:%@", topic);
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:topic messageHandler:^(id json, NSError *error) {
		if (error) {
			// TODO: エラー処理
			NSLog(@"%@", error);
			return;
		}
		// イベント送信
		DConnectMessage *message = [self convertJsonToMessage:json];
		[_plugin sendEvent:message];
	}];
}

// EventTopic購読解除
- (void)unsubscribeEvent:(NSString*)uuid {
	NSString *topic = [NSString stringWithFormat:@"deviceconnect/%@/event", uuid];
	NSLog(@"unsubscribeEvent:%@", topic);
	[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:topic];
}

// マネージャー情報を更新
- (void)updateManagers:(NSDictionary*)managers myInfo:(NSDictionary*)myInfo error:(NSError*)error {
	if (error) {
		// TODO: エラー処理
		NSLog(@"%@", error);
		return;
	}
	// onlineの時だけRequestTopic購読
	if (myInfo) {
		if ([myInfo[@"online"] boolValue]) {
			[self subscribeRequest];
		} else {
			[self unsubscribeRequest];
		}
	}
	// ResponseTopic購読・解除
	for (NSString *key in managers.allKeys) {
		// Topic名
		NSString *responseTopic = [NSString stringWithFormat:@"deviceconnect/%@/response", key];
		// Onlineかつ許可されている場合は購読対象
		if ([DPAWSIoTUtils hasAllowedManager:key] &&
			[managers[key][@"online"] boolValue])
		{
			NSLog(@"subscribeWithTopic:%@, %@", responseTopic, key);
			[[DPAWSIoTManager sharedManager] subscribeWithTopic:responseTopic messageHandler:^(id json, NSError *error) {
				if (error) {
					// TODO: エラー処理
					NSLog(@"%@", error);
					return;
				}
				[self receivedResponseFromMQTT:json from:managers[key] uuid:key];
			}];
			// イベント購読
			[self subscribeEvent:key];
		} else {
			NSLog(@"unsubscribeWithTopic:%@, %@", responseTopic, key);
			[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:responseTopic];
			// イベント購読解除
			[self unsubscribeEvent:key];
		}
		
	}
	
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

// JsonからDConnectMessageへ変換
- (id)convertJsonToMessage:(id)json {
	if ([json isKindOfClass:[NSDictionary class]]) {
		DConnectMessage *dicMessage = [DConnectMessage message];
		for (NSString *key in [json allKeys]) {
			id msg = [self convertJsonToMessage:json[key]];
			[dicMessage.internalDictionary setObject:msg forKey:key];
		}
		return dicMessage;
	} else if ([json isKindOfClass:[NSArray class]]) {
		DConnectArray *arrayMessage = [DConnectArray array];
		for (id obj in json) {
			id msg = [self convertJsonToMessage:obj];
			[arrayMessage.internalArray addObject:msg];
		}
		return arrayMessage;
	} else {
		return json;
	}
}


@end
