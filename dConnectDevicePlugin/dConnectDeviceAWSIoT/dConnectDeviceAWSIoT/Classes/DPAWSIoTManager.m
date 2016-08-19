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

// 切断
- (void)disconnect {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
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
	AWSIoTData *iotData = [AWSIoTData defaultIoTData];
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
- (BOOL)subscribeWithTopic:(NSString*)topic messageHandler:(void (^)(id json, NSError *error))handler {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	return [manager subscribeToTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce messageCallback:^(NSData *data) {
		if (handler) {
			NSError *error;
			id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			handler(json, error);
		}
	}];
}

// MQTTのTopicにメッセージを配信
- (BOOL)publishWithTopic:(NSString*)topic message:(NSString*)message {
	AWSIoTDataManager *manager = [AWSIoTDataManager defaultIoTDataManager];
	return [manager publishString:message onTopic:topic QoS:AWSIoTMQTTQoSMessageDeliveryAttemptedAtMostOnce];
}

// リージョンIDから名前を取得
+ (NSString *)regionNameFromType:(AWSRegionType)regionType {
	switch (regionType) {
		case AWSRegionUSEast1:
			return @"us-east-1";
		case AWSRegionUSWest2:
			return @"us-west-2";
		case AWSRegionUSWest1:
			return @"us-west-1";
		case AWSRegionEUWest1:
			return @"eu-west-1";
		case AWSRegionEUCentral1:
			return @"eu-central-1";
		case AWSRegionAPSoutheast1:
			return @"ap-southeast-1";
		case AWSRegionAPSoutheast2:
			return @"ap-southeast-2";
		case AWSRegionAPNortheast1:
			return @"ap-northeast-1";
		case AWSRegionAPNortheast2:
			return @"ap-northeast-2";
		case AWSRegionAPSouth1:
			return @"ap-south-1";
		case AWSRegionSAEast1:
			return @"sa-east-1";
		case AWSRegionCNNorth1:
			return @"cn-north-1";
		case AWSRegionUSGovWest1:
			return @"us-gov-west-1";
		default:
			return nil;
	}
}

@end
