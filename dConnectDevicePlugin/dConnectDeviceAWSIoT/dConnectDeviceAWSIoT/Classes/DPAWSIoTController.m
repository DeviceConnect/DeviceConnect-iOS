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

#import "DPAWSIoTRemoteClientManager.h"
#import "DPAWSIoTRemoteServerManager.h"
#import "DPAWSIoTLocalClientManager.h"
#import "DPAWSIoTLocalServerManager.h"
#import "DPAWSIoTWebClient.h"

// Shadow名
#define kShadowName @"DeviceConnect"

// Topic名の前置詞
static NSString *const kTopicPrefix = kShadowName;

// Topic名のタイプ
static NSString *const kTopicRequest = @"request";
static NSString *const kTopicResponse = @"response";
static NSString *const kTopicEvent = @"event";

// 生存報告間隔
#define kAliveInterval (5 * 60)

@interface DPAWSIoTController () <DPAWSIoTWebClientDataSource, DPAWSIoTRemoteServerManagerDelegate, DPAWSIoTLocalClientManagerDelegate, DPAWSIoTLocalServerManagerDelegate, DPAWSIoTRemoteClientManagerDelegate> {
	NSMutableDictionary *_responses;
	NSDictionary *_managers;
	DPAWSIoTWebSocket *_webSocket;
    
    DPAWSIoTRemoteClientManager *_remoteClientManager;
    DPAWSIoTRemoteServerManager *_remoteServerManager;
    DPAWSIoTLocalClientManager *_localClientManager;
    DPAWSIoTLocalServerManager *_localServerManager;
    
    NSMutableDictionary *_tempDataDic;

    NSMutableDictionary *_lastPublishedEvents;
	NSTimer *_publishEventTimer;
	
	NSTimer *_sendAliveTimer;
}
@end

@implementation DPAWSIoTController


// ManagerUUIDを返す
+ (NSString*)managerUUID {
	DConnectManager *manager = [DConnectManager sharedManager];
	NSString *managerUUID = [manager managerUUID];
	if (!managerUUID) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *managerUUID = [defaults stringForKey:@"ManagerUUID"];
		if (!managerUUID) {
			managerUUID = [[NSUUID UUID] UUIDString];
			[defaults setObject:managerUUID forKey:@"ManagerUUID"];
			[defaults synchronize];
		}
	}
	return managerUUID;
}

// ManagerNameを返す
+ (NSString*)managerName {
	DConnectManager *manager = [DConnectManager sharedManager];
	NSString *managerName = [manager managerName];
	if (!managerName) {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *managerName = [defaults stringForKey:@"ManagerName"];
		if (!managerName) {
			int num = abs((int)arc4random() % 1000);
			managerName = [NSString stringWithFormat:@"Manager-%04d", num];
			[defaults setObject:managerName forKey:@"ManagerName"];
			[defaults synchronize];
		}
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
		_sharedInstance->_lastPublishedEvents = [NSMutableDictionary dictionary];
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
		 if ([myInfo isKindOfClass:[NSNull class]]) {
			 myInfo = nil;
		 }
		 // 自分以外の情報
		 NSMutableDictionary *managers = [json[@"state"][@"reported"] mutableCopy];
		 if ([managers isKindOfClass:[NSNull class]]) {
			 managers = nil;
		 } else {
			 // 自分の情報は削除
			 [managers removeObjectForKey:[DPAWSIoTController managerUUID]];
		 }
		 handler(managers, myInfo, nil);
	 }];
}

// 自分のデバイス情報をShadowに登録
+ (void)setManagerInfo:(BOOL)online handler:(void (^)(NSError *error))handler {
	id info;
	if (online) {
		info = @{@"name": [DPAWSIoTController managerName], @"online": @(online), @"timeStamp": @(floor([[NSDate date] timeIntervalSince1970] * 1000.0))};
	} else {
		info = [NSNull null];
	}
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

// Topicを作成
+ (NSString*)myTopic:(NSString*)type {
    return [DPAWSIoTController topic:type uuid:[DPAWSIoTController managerUUID]];
}

+ (NSString *)topic:(NSString *)type uuid:(NSString *)uuid {
    return [NSString stringWithFormat:@"%@/%@/%@", kTopicPrefix, uuid, type];
}

#pragma mark - Public

// 初期化
- (instancetype)init
{
	self = [super init];
	if (self) {
		_responses = [NSMutableDictionary dictionary];
        
        // P2Pの処理
        _remoteClientManager = [DPAWSIoTRemoteClientManager new];
        _remoteClientManager.delegate = self;
        
        _remoteServerManager = [DPAWSIoTRemoteServerManager new];
        _remoteServerManager.delegate = self;
                
        _localClientManager = [DPAWSIoTLocalClientManager new];
        _localClientManager.delegate = self;
        
        _localServerManager = [DPAWSIoTLocalServerManager new];
        _localServerManager.delegate = self;
        
        _tempDataDic = [NSMutableDictionary dictionary];
        // P2Pの処理 ここまで
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
				NSLog(@"Error on Login: %@", error);
				return;
			}

            if ([DPAWSIoTUtils isOnline]) {
                [DPAWSIoTController setManagerInfo:YES handler:^(NSError *error) {
                    if (error) {
                        NSLog(@"enterForeground: %@", error);
                    }
                }];
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
	NSMutableDictionary *reqDic = [[request internalDictionary] mutableCopy];
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

	// 余計なオブジェクトを削除
	NSArray *keys = [reqDic.allKeys copy];
	for (id key in keys) {
		if (![key isKindOfClass:[NSString class]]) {
			continue;
		}
        // URI変換 dataパラメータが存在する場合にはローカルサーバとして動作するようにURIに変換
        if ([@"data" isEqualToString:key]) {
            NSData *data = reqDic[@"data"];
            if (data && data.length > 0) {
                NSString *uuid = [self addData:data];
                reqDic[@"uri"] = [NSString stringWithFormat:@"http://localhost/contentProvider?%@", uuid];
            }
        }
        // URI変換 ここまで

        id value = reqDic[key];
		if ([value isKindOfClass:[NSString class]] ||
			[value isKindOfClass:[NSNumber class]] ||
			[value isKindOfClass:[NSArray class]] ||
			[value isKindOfClass:[NSDictionary class]] ) {
		} else {
			[reqDic removeObjectForKey:key];
		}
	}
	[dic setObject:reqDic forKey:@"request"];
    
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
    NSString *requestTopic = [DPAWSIoTController topic:kTopicRequest uuid:managerUUID];
	[[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg];
	return NO;
}

// ServiceDiscoveryのRequestを処理
- (BOOL)executeServiceDiscoveryRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response requestCode:(u_int32_t)requestCode {
	// フラグでloop防止
	if ([request hasKey:@"_selfOnly"]) {
		return YES;
	}
    
	[request setString:@"true" forKey:@"_selfOnly"];
	if (_managers) {
		// サービス数を保持
		int count = 0;
		for (NSString *key in _managers.allKeys) {
			// 許可されていない場合は無視
			if (![DPAWSIoTUtils hasAllowedManager:key]) continue;
			// 時間が経っているマネージャーは生存していないとみなす
			if (![self checkIfManagerIsAlive:_managers[key]]) continue;
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
			// 時間が経っているマネージャーは生存していないとみなす
			if (![self checkIfManagerIsAlive:_managers[key]]) continue;
			// ServiceIdにManagerのUUIDを埋め込む
			[request setString:key forKey:DConnectMessageServiceId];
			[self sendRequestToMQTT:request code:requestCode response:response];
		}
		// タイムアウトの処理（servicediscoveryのタイムアウトが8秒なので、こちらは7秒）
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			NSString *requestCodeStr = [@(requestCode) stringValue];
			if (_responses[requestCodeStr]) {
				[[DConnectManager sharedManager] sendResponse:response];
				[_responses removeObjectForKey:requestCodeStr];
			}
		});
		return NO;
	} else {
		return YES;
	}
}

// Eventを発行
- (void)publishEvent:(NSString*)msg key:(NSString*)key {
	NSInteger syncInterval = [DPAWSIoTUtils eventSyncInterval];
	if (syncInterval > 0) {
		// 最後のイベントを保持
		_lastPublishedEvents[key] = msg;
		// タイマーのインターバルが変わったら再生成
		if (syncInterval != _publishEventTimer.timeInterval) {
			[_publishEventTimer invalidate];
			_publishEventTimer = nil;
		}
		// タイマーを生成
		if (!_publishEventTimer) {
			_publishEventTimer = [NSTimer scheduledTimerWithTimeInterval:syncInterval target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
		}
	} else {
		// リアルタイム
        NSString *topic = [DPAWSIoTController myTopic:kTopicEvent];
		if (![[DPAWSIoTManager sharedManager] publishWithTopic:topic message:msg]) {
			NSLog(@"Error on PublishEvent:[%@] %@", topic, msg);
		}
		// タイマーがあったら削除
		if (_publishEventTimer) {
			[_publishEventTimer invalidate];
			_publishEventTimer = nil;
		}
	}
}

// タイマーでイベントを送信
- (void)timerFireMethod:(NSTimer *)timer {
	if (_lastPublishedEvents.count == 0) return;
    NSString *topic = [DPAWSIoTController myTopic:kTopicEvent];
    for (id key in _lastPublishedEvents.allKeys) {
		NSString *msg = _lastPublishedEvents[key];
		if (![[DPAWSIoTManager sharedManager] publishWithTopic:topic message:msg]) {
			NSLog(@"Error on PublishEvent:[%@] %@", topic, msg);
		} else {
			[_lastPublishedEvents removeObjectForKey:key];
		}
	}
}

- (void) openWebSocket:(NSString*) accessToken {
    DConnectManager *mgr = [DConnectManager sharedManager];
    
    _webSocket = [DPAWSIoTWebSocket new];
    _webSocket.receivedHandler = ^(NSString *key, NSString *message) {
        [[DPAWSIoTController sharedManager] publishEvent:message key:key];
    };
    [_webSocket setPort:mgr.settings.port];
    [_webSocket openWebSocketWithAccessToken:accessToken];
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
		if ([myInfo isKindOfClass:[NSNull class]]) {
			myInfo = nil;
		}
		// 自分以外の情報
		NSMutableDictionary *managers = [json[@"state"][@"reported"] mutableCopy];
		if ([managers isKindOfClass:[NSNull class]]) {
			managers = nil;
		}
		[managers removeObjectForKey:[DPAWSIoTController managerUUID]];
		handler(managers, myInfo, nil);
	}];
}

// RequestTopic購読
- (void)subscribeRequest {
    NSString *requestTopic = [DPAWSIoTController myTopic:kTopicRequest];
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:requestTopic messageHandler:^(id json, NSError *error) {
		if (error) {
			NSLog(@"Error on SubscribeWithTopic: [%@] %@", requestTopic, error);
			return;
		}

        // P2Pの処理
        if (json[@"p2p_local"]) {
            NSDictionary *p2pLocalJson = json[@"p2p_local"];
            if (p2pLocalJson) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:p2pLocalJson options:0 error:&error];
                if (error) {
                    NSLog(@"Error: %@", error);
                    return;
                }
                [_localServerManager didReceivedSignaling:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
            }
        }

        if (json[@"p2p_remote"]) {
            NSDictionary *p2pRemoteJson = json[@"p2p_remote"];
            if (p2pRemoteJson) {
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:p2pRemoteJson options:0 error:&error];
                if (error) {
                    NSLog(@"Error: %@", error);
                    return;
                }
                [_localClientManager didReceivedSignaling:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] dataSource:self];
            }
        }
        // P2Pの処理 ここまで

        NSMutableDictionary *requestDic = [json[@"request"] mutableCopy];

        // URI変換
        if (requestDic[@"uri"]) {
            NSURL *url = [NSURL URLWithString:(NSString *)requestDic[@"uri"]];
            NSString *path = [NSString stringWithFormat:@"%@", [url path]];
            if ([url query]) {
                path = [path stringByAppendingString:@"?"];
                path = [path stringByAppendingString:[url query]];
            }
            int port = 80;
            if ([url port]) {
                port = [[url port] intValue];
            }
            NSString *uri = [_localServerManager createWebServer:[url host] port:port path:path];
            if (uri) {
                requestDic[@"uri"] = uri;
            }
        }
        // URI変換 ここまで
		// MQTTからHTTPへ
        [DPAWSIoTUtils sendRequestDictionary:requestDic callback:^(DConnectResponseMessage *response) {
            // 返却形式にフォーマット
            NSString *responseJson = [response convertToJSONString];
            NSString *msg = [NSString stringWithFormat:@"{\"requestCode\":%@,\"response\":%@}", json[@"requestCode"], responseJson];
            // レスポンスをMQTT送信
            NSString *responseTopic = [DPAWSIoTController myTopic:kTopicResponse];
            if (![[DPAWSIoTManager sharedManager] publishWithTopic:responseTopic message:msg]) {
                NSLog(@"Error on PublishWithTopic: [%@] %@", responseTopic, msg);
            }
        }];
    }];
}

// RequestTopic購読解除
- (void)unsubscribeRequest {
    NSString *requestTopic = [DPAWSIoTController myTopic:kTopicRequest];
	[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:requestTopic];
}

// EventTopic購読
- (void)subscribeEvent:(NSString*)uuid {
    NSString *topic = [DPAWSIoTController topic:kTopicEvent uuid:uuid];
	[[DPAWSIoTManager sharedManager] subscribeWithTopic:topic messageHandler:^(id json, NSError *error) {
		if (error) {
			NSLog(@"Error on SubscribeWithTopic: [%@] %@", topic, error);
			return;
		}
		// イベント送信
		DConnectMessage *message = [self convertJsonToMessage:json];
        NSString *localServiceId = [message stringForKey:DConnectMessageServiceId];
        NSString *serviceId = [NSString stringWithFormat:@"%@.%@", uuid, localServiceId];
        [message setString:serviceId forKey:DConnectMessageServiceId];
        [message setString:_plugin.pluginId  forKey:DConnectMessageAccessToken]; // リモートのサービスIDに差し替え
		[_plugin sendEvent:message];
	}];
}

// EventTopic購読解除
- (void)unsubscribeEvent:(NSString*)uuid {
    NSString *topic = [DPAWSIoTController topic:kTopicEvent uuid:uuid];
    [[DPAWSIoTManager sharedManager] unsubscribeWithTopic:topic];
}

// 生存報告
- (void)sendAliveTimerEvent:(id)sender {
	[DPAWSIoTController setManagerInfo:YES handler:^(NSError *error) {
		if (error) {
			NSLog(@"Error on Sending Alive State.");
		}
	}];
}

// マネージャー情報を更新
- (void)updateManagers:(NSDictionary*)managers myInfo:(NSDictionary*)myInfo error:(NSError*)error {
	if (error) {
		NSLog(@"Error on UpdateManagers: %@", error);
		return;
	}
	// onlineの時だけRequestTopic購読
	if (myInfo) {
		if ([myInfo[@"online"] boolValue]) {
			[self subscribeRequest];
			// 生存報告タイマー開始
			if (!_sendAliveTimer) {
				_sendAliveTimer = [NSTimer scheduledTimerWithTimeInterval:kAliveInterval target:self selector:@selector(sendAliveTimerEvent:) userInfo:nil repeats:YES];
				[self sendAliveTimerEvent:nil];
			}
		} else {
			[self unsubscribeRequest];
			// 生存報告タイマー停止
			[_sendAliveTimer invalidate];
			_sendAliveTimer = nil;
		}
	} else {
		[self unsubscribeRequest];
		// 生存報告タイマー停止
		[_sendAliveTimer invalidate];
		_sendAliveTimer = nil;
	}
	
	// ResponseTopic購読・解除
	if (!managers) return;
	for (NSString *key in managers.allKeys) {
        NSString *responseTopic = [DPAWSIoTController topic:kTopicResponse uuid:key];
		// Onlineかつ許可されている場合は購読対象
		if ([DPAWSIoTUtils hasAllowedManager:key] &&
			![managers[key] isKindOfClass:[NSNull class]] &&
			[managers[key][@"online"] boolValue] &&
			[self checkIfManagerIsAlive:managers[key]])
		{
			NSDictionary *from = managers[key];
			[[DPAWSIoTManager sharedManager] subscribeWithTopic:responseTopic messageHandler:^(id json, NSError *error) {
				if (error) {
					NSLog(@"Error on SubscribeWithTopic: %@, %@", responseTopic, error);
					return;
				}
				[self receivedResponseFromMQTT:json from:from uuid:key];
			}];
			// イベント購読
			[self subscribeEvent:key];
		} else {
			[[DPAWSIoTManager sharedManager] unsubscribeWithTopic:responseTopic];
			// イベント購読解除
			[self unsubscribeEvent:key];
		}
	}
}

// 時間が経っているマネージャーは生存していないとみなす
- (BOOL)checkIfManagerIsAlive:(id)manager {
	NSInteger timestamp = [manager[@"timeStamp"] integerValue];
	NSInteger limit = kAliveInterval * 2 * 1000;
	NSInteger now = [@(floor([[NSDate date] timeIntervalSince1970] * 1000.0)) integerValue];
	return now < timestamp + limit;
}

// MQTTからレスポンスを受診
- (void)receivedResponseFromMQTT:(id)json from:(NSDictionary*)manager uuid:(NSString*)uuid {
	NSString *requestCode = [json[@"requestCode"] stringValue];
	DConnectResponseMessage *response = _responses[requestCode];
	if (response) {
		int count = (int)[response integerForKey:@"servicecount"];
		if (count > 0) {
			// servicediscoveryの場合各サービスからのレスポンスを保持
			NSDictionary *resJson = json[@"response"];
			int result = [resJson[DConnectMessageResult] intValue];
			if (result == DConnectMessageResultTypeOk) {
				NSArray *foundServices = resJson[DConnectServiceDiscoveryProfileParamServices];
                DConnectArray *services = [DConnectArray array];
				if ([foundServices count] > 0) {
					// responseに追加
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
                [response setArray:services forKey:DConnectServiceDiscoveryProfileParamServices];
                [response setResult:DConnectMessageResultTypeOk];
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
                
                if ([key isEqualToString:@"uri"]) {
                    // URIの変換処理
                    NSURL *url = [NSURL URLWithString:(NSString *)obj];
                    NSString *path = [NSString stringWithFormat:@"%@", [url path]];
                    if ([url query]) {
                        path = [path stringByAppendingString:@"?"];
                        path = [path stringByAppendingString:[url query]];
                    }
                    int port = 80;
                    if ([url port]) {
                        port = [[url port] intValue];
                    }
                    NSString *uri = [_remoteServerManager createWebServer:[url host] port:port path:path to:uuid];
                    [response.internalDictionary setObject:uri forKey:key];
                    // URIの変換処理 ここまで
                } else {
                    [response.internalDictionary setObject:obj forKey:key];
                }
			}
			[[DConnectManager sharedManager] sendResponse:response];
			[_responses removeObjectForKey:requestCode];
		}
	}
    
    // P2Pの処理
    if (json[@"p2p_local"]) {
       NSDictionary *p2pLocalJson = json[@"p2p_local"];
        if (p2pLocalJson) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:p2pLocalJson options:0 error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
                return;
            }
            [_remoteClientManager didReceivedSignaling:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] dataSource:self to:uuid];
        }
    }
    
    if (json[@"p2p_remote"]) {
        NSDictionary *p2pRemoteJson = json[@"p2p_remote"];
        if (p2pRemoteJson) {
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:p2pRemoteJson options:0 error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
                return;
            }
            [_remoteServerManager didReceivedSignaling:[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
        }
    }
    // P2Pの処理 ここまで
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

- (NSString *) createP2PRemoteSignaling:(NSString *)signaling
{
    return [NSString stringWithFormat:@"{\"requestCode\": %@, \"p2p_remote\": %@}", @(arc4random()), signaling];
}

- (NSString *) createP2PLocalSignaling:(NSString *)signaling
{
    return [NSString stringWithFormat:@"{\"requestCode\": %@, \"p2p_local\": %@}", @(arc4random()),signaling];
}

#pragma mark - DPAWSIoTRemoteServerManagerDelegate

-(void) remoteServerManager:(DPAWSIoTRemoteServerManager *)manager didNotifiedSignaling:(NSString *)signaling to:(NSString *)uuid
{
    NSString *msg = [self createP2PRemoteSignaling: signaling];
    NSString *requestTopic = [DPAWSIoTController topic:kTopicRequest uuid:uuid];
    if (![[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg]) {
        NSLog(@"Failed to publish topic. topic=%@", requestTopic);
    }
}

#pragma mark - DPAWSIoTRemoteClientManagerDelegate

-(void) remoteClientManager:(DPAWSIoTRemoteClientManager *)client didNotifiedSignaling:(NSString *)signaling to:(NSString *)uuid
{
    NSString *msg = [self createP2PLocalSignaling:signaling];
    NSString *requestTopic = [DPAWSIoTController topic:kTopicRequest uuid:uuid];
    if (![[DPAWSIoTManager sharedManager] publishWithTopic:requestTopic message:msg]) {
        NSLog(@"Failed to publish topic. topic=%@", requestTopic);
    }
}

#pragma mark - DPAWSIoTLocalClientManagerDelegate

-(void) localClientManager:(DPAWSIoTLocalClientManager *)manager didNotifiedSignaling:(NSString *)signaling;
{
    NSString *msg = [self createP2PRemoteSignaling: signaling];
    NSString *responseTopic = [DPAWSIoTController myTopic:kTopicResponse];
    if (![[DPAWSIoTManager sharedManager] publishWithTopic:responseTopic message:msg]) {
        NSLog(@"Failed to publish topic. topic=%@", responseTopic);
    }
}

#pragma mark - DPAWSIoTLocalServerManagerDelegate

-(void) localServerManager:(DPAWSIoTLocalServerManager *)manager didNotifiedSignaling:(NSString *)signaling
{
    NSString *msg = [self createP2PLocalSignaling:signaling];
    NSString *responseTopic = [DPAWSIoTController myTopic:kTopicResponse];
    if (![[DPAWSIoTManager sharedManager] publishWithTopic:responseTopic message:msg]) {
        NSLog(@"Failed to publish topic. topic=%@", responseTopic);
    }
}

#pragma mark - DPAWSIoTWebClientDataSource

- (NSString *) addData:(NSData *)data
{
    NSString *uuid = [NSUUID UUID].UUIDString;
    _tempDataDic[uuid] = data;
    return uuid;
}

- (NSData *) getData:(NSString *)uuid
{
    NSData *data = _tempDataDic[uuid];
    if (data) {
        [_tempDataDic removeObjectForKey:uuid];
    }
    return data;
}

- (void) removeData:(NSString *)uuid
{
    [_tempDataDic removeObjectForKey:uuid];
}

@end
