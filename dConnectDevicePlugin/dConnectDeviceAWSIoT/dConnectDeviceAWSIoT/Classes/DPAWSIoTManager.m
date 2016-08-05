//
//  DPAWSIoTManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AWSIoT.h>
#import "DPAWSIoTManager.h"

#define ERROR_DOMAIN @"DPAWSIoTManager"

@interface DPAWSIoTManager () {
	BOOL _isConnected;
}
@end

@implementation DPAWSIoTManager

// 共有インスタンス
+ (instancetype)sharedManager {
	static DPAWSIoTManager *_sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[DPAWSIoTManager alloc] init];
	});
	return _sharedInstance;
}

// 接続
- (void)connectWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey region:(AWSRegionType)region completionHandler:(void (^)(NSError *error))handler {
	
	// 切断
	if (_isConnected) {
		[self disconnect];
	}
	_isConnected = NO;
	// 認証設定
	AWSStaticCredentialsProvider *provider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
	AWSServiceConfiguration *config = [[AWSServiceConfiguration alloc] initWithRegion:region credentialsProvider:provider];
	[[AWSServiceManager defaultServiceManager] setDefaultServiceConfiguration:config];
	// MQTT接続
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	NSString *clientID = [[NSUUID UUID] UUIDString];
	if (![manager connectUsingWebSocketWithClientId:clientID cleanSession:YES statusCallback:^(AWSIoTMQTTStatus status) {
		NSLog(@"* mqtt status: %ld", (long)status);
		if (status == AWSIoTMQTTStatusConnected) {
			if (!_isConnected) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (handler) {
						handler(nil);
					}
				});
				_isConnected = YES;
			}
		}
		if (status == AWSIoTMQTTStatusConnectionRefused) {
			// FIXME: エラーなどで接続出来ない場合もhandlerで返事を返す。
		}
	}]) {
		if (handler) {
			handler([NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		}
	}

}

// 切断
- (void)disconnect {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	[manager disconnect];
}

// Shadow取得
- (void)fetchShadowWithName:(NSString*)name completionHandler:(void (^)(NSString *result, NSError *error))handler {
	if (!_isConnected) {
		if (handler) {
			handler(nil, [NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		}
		return;
	}
	AWSIoTData *iotData = [AWSIoTData defaultIoTData];
	AWSIoTDataGetThingShadowRequest *request = [AWSIoTDataGetThingShadowRequest new];
	request.thingName = name;
	[iotData getThingShadow:request
		  completionHandler:^(AWSIoTDataGetThingShadowResponse * _Nullable response, NSError * _Nullable error) {
		if (handler) {
			NSString *str = [[NSString alloc] initWithData:response.payload encoding:NSUTF8StringEncoding];
			handler(str, error);
		}
	}];
}

// Shadow更新
- (void)updateShadowWithName:(NSString*)name value:(NSString*)str
		   completionHandler:(void (^)(NSError *error))handler {
	if (!_isConnected) {
		if (handler) {
			handler([NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		}
		return;
	}
	AWSIoTData *iotData = [AWSIoTData defaultIoTData];
	AWSIoTDataUpdateThingShadowRequest *request = [AWSIoTDataUpdateThingShadowRequest new];
	request.thingName = name;
	request.payload = [str dataUsingEncoding:NSUTF8StringEncoding];
	[iotData updateThingShadow:request
			 completionHandler:^(AWSIoTDataUpdateThingShadowResponse * _Nullable response, NSError * _Nullable error) {
		if (handler) {
			handler(error);
		}
	}];
}

// MQTTのTopicを購読
- (BOOL)subscribeWithTopic:(NSString*)topic messageHandler:(void (^)(NSString *message))handler {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	return [manager subscribeToTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce messageCallback:^(NSData *data) {
		if (handler) {
			NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			handler(message);
		}
	}];
}

// MQTTのTopicにメッセージを配信
- (BOOL)publishWithTopic:(NSString*)topic message:(NSString*)message {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	return [manager publishString:message onTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
}

@end
