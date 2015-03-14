//
//  DPPebbleDeviceOrientationProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleDeviceOrientationProfile.h"
#import "DPPebbleDevicePlugin.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"

@interface DPPebbleDeviceOrientationProfile ()

///!< Orientationデータを一時的にキャッシュする.
@property DConnectMessage *cacheOrientationData;

/*!
 @brief イベント登録の有無を確認する.
 @param serviceId サービスID
 @retval 登録されている場合はYES
 @retval 登録されていない場合はNO
 */
- (BOOL)hasEventList:(NSString *)serviceId;

/*!
 @brief Orientationデータを作成する.
 @param accelX x軸への加速度
 @param accelY y軸への加速度
 @param accelZ z軸への加速度
 @param interval インターバル
 @return Orientationデータ
 */
- (DConnectMessage *)createOrientationWithAccelX:(float)accelX accelY:(float)accelY
                                          accelZ:(float)accelZ interval:(long long)interval;
@end

@implementation DPPebbleDeviceOrientationProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.delegate = self;
        self.cacheOrientationData = nil;
    }
	return self;
}

- (BOOL)hasEventList:(NSString *)serviceId {
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPPebbleDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:serviceId
                                          profile:DConnectDeviceOrientationProfileName
                                        attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    return events != nil && events.count > 0;
}

- (DConnectMessage *)createOrientationWithAccelX:(float)accelX
                                          accelY:(float)accelY
                                          accelZ:(float)accelZ
                                        interval:(long long)interval {
    DConnectMessage *message = [DConnectMessage message];
    DConnectMessage *accelerationIncludingGravity = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setX:accelX target:accelerationIncludingGravity];
    [DConnectDeviceOrientationProfile setY:accelY target:accelerationIncludingGravity];
    [DConnectDeviceOrientationProfile setZ:accelZ target:accelerationIncludingGravity];
    
    [DConnectDeviceOrientationProfile setAccelerationIncludingGravity:accelerationIncludingGravity target:message];
    [DConnectDeviceOrientationProfile setInterval:interval target:message];
    return message;
}

#pragma mark - DConnectDeviceOrientationProfileDelegate

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
    if ([self hasEventList:serviceId]) {
        if (self.cacheOrientationData) {
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectDeviceOrientationProfile setOrientation:self.cacheOrientationData target:response];
        } else {
            [response setErrorToIllegalDeviceStateWithMessage:@"device is not ready."];
        }
        return YES;
    } else {
        __unsafe_unretained typeof(self) weakSelf = self;

        [[DPPebbleManager sharedManager] registDeviceOrientationEvent:serviceId callback:^(NSError *error) {
            if (error) {
                [response setErrorToIllegalDeviceStateWithMessage:@"device is not ready."];
                [[DConnectManager sharedManager] sendResponse:response];
            }
        } eventCallback:^(float accelX, float accelY, float accelZ, long long interval) {
            DConnectMessage * orientation = [self createOrientationWithAccelX:accelX
                                                                       accelY:accelY
                                                                       accelZ:accelZ
                                                                     interval:interval];
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectDeviceOrientationProfile setOrientation:orientation target:response];
            
            [[DConnectManager sharedManager] sendResponse:response];
            
            if (![weakSelf hasEventList:serviceId]) {
                [[DPPebbleManager sharedManager] deleteDeviceOrientationEvent:serviceId callback:^(NSError *error) {
                    if (error) {
                        NSLog(@"Error:%@", error);
                    }
                }];
            }
        }];
        return NO;
    }
}

// ondeviceorientationイベント登録リクエストを受け取った
- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    __unsafe_unretained typeof(self) weakSelf = self;
	__block BOOL responseFlg = YES;
	// イベント登録
	[DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
		
		// Pebbleに登録
		[[DPPebbleManager sharedManager] registDeviceOrientationEvent:serviceId callback:^(NSError *error) {
			// 登録成功
			// エラーチェック
			[DPPebbleProfileUtil handleErrorNormal:error response:response];
		} eventCallback:^(float accelX, float accelY, float accelZ, long long interval) {
			// イベントコールバック
			// DConnectメッセージ作成
            DConnectMessage * message = [weakSelf createOrientationWithAccelX:accelX
                                                                   accelY:accelY
                                                                   accelZ:accelZ
                                                                 interval:interval];
            // キャッシュ保持
            weakSelf.cacheOrientationData = message;
			// DConnectにイベント送信
			[DPPebbleProfileUtil sendMessageWithProvider:weakSelf.provider
												 profile:DConnectDeviceOrientationProfileName
											   attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation
												serviceID:serviceId
										 messageCallback:^(DConnectMessage *eventMsg) {
				 // イベントにメッセージ追加
				 [DConnectDeviceOrientationProfile setOrientation:message target:eventMsg];
			 } deleteCallback:^ {
				 // Pebbleのイベント削除
				 [[DPPebbleManager sharedManager] deleteDeviceOrientationEvent:serviceId callback:^(NSError *error) {
                     if (error) {
                         NSLog(@"Error:%@", error);
                     }
				 }];
			 }];
		}];
		
		responseFlg = NO;
	}];
	
	return responseFlg;
}

// ondeviceorientationイベント解除リクエストを受け取った
- (BOOL)                           profile:(DConnectDeviceOrientationProfile *)profile
didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                  serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey
{
	// DConnectイベント削除
	[DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
		// Pebbleのイベント削除
		[[DPPebbleManager sharedManager] deleteDeviceOrientationEvent:serviceId callback:^(NSError *error) {
            if (error) {
                NSLog(@"Error:%@", error);
            }
		}];
	}];
	return YES;
}

@end
