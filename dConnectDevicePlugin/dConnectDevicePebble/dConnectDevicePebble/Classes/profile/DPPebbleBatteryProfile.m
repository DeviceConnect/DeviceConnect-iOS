//
//  DPPebbleBatteryProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPPebbleBatteryProfile.h"
#import "DPPebbleDevicePlugin.h"
#import "DPPebbleManager.h"
#import "DPPebbleProfileUtil.h"

@interface DPPebbleBatteryProfile ()
@end

@implementation DPPebbleBatteryProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
        __weak id weakSelf = self;
        
        // API登録(didReceiveGetLevelRequest相当)
        NSString *getLevelRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectBatteryProfileAttrLevel];
        [self addGetPath: getLevelRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSString *serviceId = [request serviceId];
            [[DPPebbleManager sharedManager] fetchBatteryLevel:serviceId callback:^(float level, NSError *error) {
                
                // エラーチェック
                if ([DPPebbleProfileUtil handleError:error response:response]) {
                    // レベルを設定
                    [DConnectBatteryProfile setLevel:level target:response];
                    // 正常
                    [response setResult:DConnectMessageResultTypeOk];
                }
                
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            }];
            return NO;
        }];
        
        // API登録(didReceiveGetChargingRequest相当)
        NSString *getChargingRequestApiPath = [self apiPath: nil
                                              attributeName: DConnectBatteryProfileAttrCharging];
        [self addGetPath: getChargingRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSString *serviceId = [request serviceId];
            [[DPPebbleManager sharedManager] fetchBatteryCharging:serviceId callback:^(BOOL isCharging, NSError *error) {
                
                // エラーチェック
                if ([DPPebbleProfileUtil handleError:error response:response]) {
                    // ステータスを設定
                    [DConnectBatteryProfile setCharging:isCharging target:response];
                    // 正常
                    [response setResult:DConnectMessageResultTypeOk];
                }
                
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            }];
            return NO;
        }];
        
        // API登録(didReceiveGetAllRequest相当)
        NSString *getAllRequestApiPath = [self apiPath: nil
                                         attributeName: nil];
        [self addGetPath: getAllRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSString *serviceId = [request serviceId];
            [[DPPebbleManager sharedManager] fetchBatteryInfo:serviceId callback:^(float level, BOOL isCharging, NSError *error) {
                
                // エラーチェック
                if ([DPPebbleProfileUtil handleError:error response:response]) {
                    // レベルとステータスを設定
                    [DConnectBatteryProfile setLevel:level target:response];
                    [DConnectBatteryProfile setCharging:isCharging target:response];
                    // 正常
                    [response setResult:DConnectMessageResultTypeOk];
                }
                
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            }];
            return NO;
        }];
        
        // API登録(didReceivePutOnChargingChangeRequest相当)
        NSString *putOnChargingChangeRequestApiPath = [self apiPath: nil
                                                      attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addPutPath: putOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            __block BOOL responseFlg = YES;
 
            // イベント登録
            [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
                
                // Pebbleに登録
                NSString *serviceId = [request serviceId];
                [[DPPebbleManager sharedManager] registChargingChangeEvent:serviceId callback:^(NSError *error) {
                    // 登録成功
                    // エラーチェック
                    [DPPebbleProfileUtil handleErrorNormal:error response:response];
                    
                } eventCallback:^(BOOL isCharging) {
                    // イベントコールバック
                    // DConnectイベント作成
                    DConnectMessage *message = [DConnectMessage message];
                    [DConnectBatteryProfile setCharging:isCharging target:message];
                    
                    // DConnectにイベント送信
                    [DPPebbleProfileUtil sendMessageWithPlugin:[weakSelf plugin]
                                                         profile:DConnectBatteryProfileName
                                                       attribute:DConnectBatteryProfileAttrOnChargingChange
                                                       serviceID:serviceId
                                                 messageCallback:^(DConnectMessage *eventMsg)
                     {
                         // イベントにメッセージ追加
                         [DConnectBatteryProfile setBattery:message target:eventMsg];
                         
                     } deleteCallback:^
                     {
                         // Pebbleのイベント削除
                         [[DPPebbleManager sharedManager] deleteChargingChangeEvent:serviceId callback:^(NSError *error) {
                             if (error) NSLog(@"Error:%@", error);
                         }];
                     }];
                }];
                
                responseFlg = NO;
            }];
            
            return responseFlg;
        }];
        
        // API登録(didReceivePutOnBatteryChangeRequest相当)
        NSString *putOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addPutPath: putOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            __block BOOL responseFlg = YES;
            // イベント登録
            [DPPebbleProfileUtil handleRequest:request response:response isRemove:NO callback:^{
                
                // Pebbleに登録
                NSString *serviceId = [request serviceId];
                [[DPPebbleManager sharedManager] registBatteryLevelChangeEvent:serviceId callback:^(NSError *error) {
                    // 登録成功
                    // エラーチェック
                    [DPPebbleProfileUtil handleErrorNormal:error response:response];
                    
                } eventCallback:^(float level) {
                    // イベントコールバック
                    // DConnectイベント作成
                    DConnectMessage *message = [DConnectMessage message];
                    [DConnectBatteryProfile setLevel:level target:message];
                    
                    // DConnectにイベント送信
                    [DPPebbleProfileUtil sendMessageWithPlugin:[weakSelf plugin]
                                                         profile:DConnectBatteryProfileName
                                                       attribute:DConnectBatteryProfileAttrOnBatteryChange
                                                       serviceID:serviceId
                                                 messageCallback:^(DConnectMessage *eventMsg)
                     {
                         // イベントにメッセージ追加
                         [DConnectBatteryProfile setBattery:message target:eventMsg];
                         
                     } deleteCallback:^
                     {
                         // Pebbleのイベント削除
                         [[DPPebbleManager sharedManager] deleteBatteryLevelChangeEvent:serviceId callback:^(NSError *error) {
                             if (error) NSLog(@"Error:%@", error);
                         }];
                     }];
                }];
                
                responseFlg = NO;
            }];
            
            return responseFlg;
        }];
        
        // API登録(didReceiveDeleteOnChargingChangeRequest相当)
        NSString *deleteOnChargingChangeRequestApiPath = [self apiPath: nil
                                                         attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addDeletePath: deleteOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            // DConnectイベント削除
            [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
                // Pebbleのイベント削除
                NSString *serviceId = [request serviceId];
                [[DPPebbleManager sharedManager] deleteChargingChangeEvent:serviceId callback:^(NSError *error) {
                    if (error) NSLog(@"Error:%@", error);
                }];
            }];
            return YES;
        }];

        // API登録(didReceiveDeleteOnBatteryChangeRequest相当)
        NSString *deleteOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addDeletePath: deleteOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            // DConnectイベント削除
            [DPPebbleProfileUtil handleRequest:request response:response isRemove:YES callback:^{
                // Pebbleのイベント削除
                NSString *serviceId = [request serviceId];
                [[DPPebbleManager sharedManager] deleteBatteryLevelChangeEvent:serviceId callback:^(NSError *error) {
                    if (error) NSLog(@"Error:%@", error);
                }];
            }];
            return YES;
        }];
	}
	return self;
	
}

@end
