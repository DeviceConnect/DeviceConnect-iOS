//
//  DPHostBatteryProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostDevicePlugin.h"
#import "DPHostBatteryProfile.h"
#import "DPHostService.h"
#import "DPHostUtils.h"

@interface DPHostBatteryProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

- (void) sendOnChargingChangeEvent:(NSNotification *)notification;
- (void) sendOnBatteryChangeEvent:(NSNotification *)notification;

@end

@implementation DPHostBatteryProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        __weak id weakEventMgr = self.eventMgr;
        
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendOnBatteryChangeEvent:)
                                                     name:UIDeviceBatteryLevelDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sendOnChargingChangeEvent:)
                                                     name:UIDeviceBatteryStateDidChangeNotification
                                                   object:nil];
        
        // API登録(didReceiveGetLevelRequest相当)
        NSString *getLevelRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectBatteryProfileAttrLevel];
        [self addGetPath: getLevelRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            float level = [[UIDevice currentDevice] batteryLevel];
            if (level < 0 || level > 1) {
                // 未知のステータス；エラーレスポンスを返す。
                [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
            } else {
                [DConnectBatteryProfile setLevel:level target:response];
                [response setResult:DConnectMessageResultTypeOk];
            }
            return YES;
            
        }];
        
        // API登録(didReceiveGetChargingRequest相当)
        NSString *getChargingRequestApiPath = [self apiPath: nil
                                              attributeName: DConnectBatteryProfileAttrCharging];
        [self addGetPath: getChargingRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            NSNumber *charging;
            switch ([[UIDevice currentDevice] batteryState]) {
                case UIDeviceBatteryStateFull:
                case UIDeviceBatteryStateCharging:
                    charging = @YES;
                    break;
                case UIDeviceBatteryStateUnplugged:
                    charging = @NO;
                    break;
                case UIDeviceBatteryStateUnknown:
                default:
                    // 未知のステータス；エラーレスポンスを返す。
                    [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
                    return YES;
            }
            [DConnectBatteryProfile setCharging:[charging boolValue] target:response];
            [response setResult:DConnectMessageResultTypeOk];
            return YES;
        }];
        
        // API登録(didReceiveGetAllRequest相当)
        NSString *getAllRequestApiPath = [self apiPath: nil
                                         attributeName: nil];
        [self addGetPath: getAllRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            float level = [[UIDevice currentDevice] batteryLevel];
            NSNumber *charging;
            switch ([[UIDevice currentDevice] batteryState]) {
                case UIDeviceBatteryStateFull:
                case UIDeviceBatteryStateCharging:
                    charging = @YES;
                    break;
                case UIDeviceBatteryStateUnplugged:
                    charging = @NO;
                    break;
                case UIDeviceBatteryStateUnknown:
                default:
                    // 未知のステータス
                    charging = nil;
                    break;
            }
            if (level >= 0 && level <= 1) {
                [DConnectBatteryProfile setLevel:level target:response];
            }
            if (charging) {
                [DConnectBatteryProfile setCharging:[charging boolValue] target:response];
            }
            if ((level >= 0 && level <= 1) || charging) {
                [response setResult:DConnectMessageResultTypeOk];
            } else {
                // 未知のステータス；エラーレスポンスを返す。
                [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
            }
            return YES;
         }];

        // API登録(didReceivePutOnChargingChangeRequest相当)
        NSString *putOnChargingChangeRequestApiPath = [self apiPath: nil
                                                      attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addPutPath: putOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            switch ([weakEventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    break;
                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                    [response setErrorToInvalidRequestParameter];
                    break;
                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                case DConnectEventErrorFailed:           // 処理失敗.
                    [response setErrorToUnknown];
                    break;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnBatteryChangeRequest相当)
        NSString *putOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addPutPath: putOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            switch ([weakEventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    break;
                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                    [response setErrorToInvalidRequestParameter];
                    break;
                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                case DConnectEventErrorFailed:           // 処理失敗.
                    [response setErrorToUnknown];
                    break;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnChargingChangeRequest相当)
        NSString *deleteOnChargingChangeRequestApiPath = [self apiPath: nil
                                                         attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addDeletePath: deleteOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            switch ([weakEventMgr removeEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    break;
                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                    [response setErrorToInvalidRequestParameter];
                    break;
                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                case DConnectEventErrorFailed:           // 処理失敗.
                    [response setErrorToUnknown];
                    break;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnBatteryChangeRequest相当)
        NSString *deleteOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addDeletePath: deleteOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            switch ([weakEventMgr removeEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    break;
                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                    [response setErrorToInvalidRequestParameter];
                    break;
                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                case DConnectEventErrorFailed:           // 処理失敗.
                    [response setErrorToUnknown];
                    break;
            }
            
            return YES;
        }];
    }
    return self;
}

- (void)dealloc
{
    // 通知の受領をやめる。
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) sendOnChargingChangeEvent:(NSNotification *)notification
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectBatteryProfileName
                                          attribute:DConnectBatteryProfileAttrOnChargingChange];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *battery = [DConnectMessage message];
        BOOL charging;
        switch ([notification.object batteryState]) {
            case UIDeviceBatteryStateFull:
            case UIDeviceBatteryStateCharging:
                charging = YES;
                break;
            case UIDeviceBatteryStateUnplugged:
                charging = NO;
                break;
            case UIDeviceBatteryStateUnknown:
            default:
                // 未知のステータス；イベントをそもそも発送しない。
                return;
        }
        [DConnectBatteryProfile setCharging:charging target:battery];
        [DConnectBatteryProfile setBattery:battery target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (void) sendOnBatteryChangeEvent:(NSNotification *)notification
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectBatteryProfileName
                                          attribute:DConnectBatteryProfileAttrOnBatteryChange];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *battery = [DConnectMessage message];
        float level = [notification.object batteryLevel];
        if (level < 0) {
            // 未知のステータス；イベントをそもそも発送しない。
            return;
        }
        [DConnectBatteryProfile setLevel:level target:battery];
        [DConnectBatteryProfile setBattery:battery target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}
@end
