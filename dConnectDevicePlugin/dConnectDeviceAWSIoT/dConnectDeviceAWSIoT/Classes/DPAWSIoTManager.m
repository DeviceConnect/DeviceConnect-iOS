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
	
	[AWSLogger defaultLogger].logLevel = AWSLogLevelWarn;
	// 切断
	if (_isConnected) {
		[self disconnect];
	}
	// 認証設定
	[AWSIoTDataManager removeIoTDataManagerForKey:@"dconnect"];
	AWSStaticCredentialsProvider *provider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accessKey secretKey:secretKey];
	AWSServiceConfiguration *config = [[AWSServiceConfiguration alloc] initWithRegion:region credentialsProvider:provider];
	[AWSIoTDataManager registerIoTDataManagerWithConfiguration:config forKey:@"dconnect"];
	[AWSIoTData registerIoTDataWithConfiguration:config forKey:@"dconnect"];
	
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	// MQTT接続
	NSString *clientID = [[NSUUID UUID] UUIDString];
	if (![manager connectUsingWebSocketWithClientId:clientID cleanSession:YES statusCallback:^(AWSIoTMQTTStatus status) {
		dispatch_async(dispatch_get_main_queue(), ^{
			// 接続成功
			if (status == AWSIoTMQTTStatusConnected) {
				if (!_isConnected) {
					_isConnected = YES;
					if (handler) {
						handler(nil);
					}
				}
			}
			// 接続エラー
			if (status == AWSIoTMQTTStatusConnectionError) {
				// 接続時のエラーはhandlerを呼んで再接続処理をキャンセル。接続中のエラーは再接続処理が走るので無視。
				if (!_isConnected) {
					if (handler) {
						handler([NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
					}
					[manager disconnect];
				}
			}
		});
	}]) {
		if (handler) {
			handler([NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		}
	}
}

// 自分のRegion名を取得
- (NSString*)regionName {
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	AWSRegionType type = manager.configuration.regionType;
	return [DPAWSIoTManager regionNameFromType:type];
}

// 切断
- (void)disconnect {
	_isConnected = NO;
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	[manager disconnect];
}

// Shadow取得
- (void)fetchShadowWithName:(NSString*)name completionHandler:(void (^)(id json, NSError *error))handler {
	if (!_isConnected) {
		if (handler) {
			handler(nil, [NSError errorWithDomain:ERROR_DOMAIN code:-1 userInfo:nil]);
		}
		return;
	}
	AWSIoTData *iotData = [AWSIoTData IoTDataForKey:@"dconnect"];
	AWSIoTDataGetThingShadowRequest *request = [AWSIoTDataGetThingShadowRequest new];
	request.thingName = name;
	[iotData getThingShadow:request
		  completionHandler:^(AWSIoTDataGetThingShadowResponse * _Nullable response, NSError * _Nullable error) {
		if (handler) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error) {
					handler(nil, error);
				} else {
					NSError *error;
					id json = [NSJSONSerialization JSONObjectWithData:response.payload options:NSJSONReadingAllowFragments error:&error];
					handler(json, error);
				}
			});
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
	AWSIoTData *iotData = [AWSIoTData IoTDataForKey:@"dconnect"];
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
- (BOOL)subscribeWithTopic:(NSString*)topic messageHandler:(void (^)(id json, NSError *error))handler {
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	return [manager subscribeToTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce messageCallback:^(NSData *data) {
		if (handler) {
			NSError *error;
			id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			handler(json, error);
		}
	}];
}

// MQTTのTopicの購読を解除
- (void)unsubscribeWithTopic:(NSString*)topic {
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	[manager unsubscribeTopic:topic];
}

// MQTTのTopicにメッセージを配信
- (BOOL)publishWithTopic:(NSString*)topic message:(NSString*)message {
	AWSIoTDataManager *manager = [AWSIoTDataManager IoTDataManagerForKey:@"dconnect"];
	return [manager publishString:message onTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
}

// リージョンIDから名前を取得
+ (NSString *)regionNameFromType:(AWSRegionType)regionType {
	switch (regionType) {
		case AWSRegionUSEast1:
			return @"米国東部 (バージニア北部)";
		case AWSRegionUSWest2:
			return @"米国西部 (北カリフォルニア)";
		case AWSRegionUSWest1:
			return @"米国西部 (オレゴン)";
		case AWSRegionEUWest1:
			return @"EU (アイルランド)";
		case AWSRegionEUCentral1:
			return @"EU (フランクフルト)";
		case AWSRegionAPSoutheast1:
			return @"アジアパシフィック (シンガポール)";
		case AWSRegionAPSoutheast2:
			return @"アジアパシフィック (シドニー)";
		case AWSRegionAPNortheast1:
			return @"アジアパシフィック (東京)";
		case AWSRegionAPNortheast2:
			return @"アジアパシフィック (ソウル)";
		case AWSRegionAPSouth1:
			return @"アジアパシフィック (ムンバイ)";
		case AWSRegionSAEast1:
			return @"南アメリカ (サンパウロ)";
		case AWSRegionCNNorth1:
			return @"中国 (北京)";
		case AWSRegionUSGovWest1:
			return @"AWS GovCloud (US)";
		default:
			return nil;
	}
}

@end
