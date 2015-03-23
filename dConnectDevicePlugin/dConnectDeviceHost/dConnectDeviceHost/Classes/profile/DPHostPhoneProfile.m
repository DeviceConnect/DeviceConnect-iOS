//
//  DPHostPhoneProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "DPHostDevicePlugin.h"
#import "DPHostPhoneProfile.h"
#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostUtils.h"

@interface DPHostPhoneProfile()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

// 通話イベントを処理するオブジェクト
@property CTCallCenter *callCenter;

//　通話中の番号
@property (nonatomic) NSString *callingNumber;

@end

@implementation DPHostPhoneProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
            return nil;
        }
        self.delegate = self;
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        _callCenter = [CTCallCenter new];
        __weak typeof(self) weakSelf = self;
        _callCenter.callEventHandler = ^(CTCall *call) {
            DConnectPhoneProfileCallState callState;
            if (call.callState == CTCallStateDialing) {
                return;
            } else if(call.callState == CTCallStateIncoming) {
                return;
            } else if(call.callState == CTCallStateConnected) {
                callState = DConnectPhoneProfileCallStateStart;
            } else if(call.callState == CTCallStateDisconnected) {
                callState = DConnectPhoneProfileCallStateFinished;
            } else {
                return;
            }
            NSArray *evts = [weakSelf.eventMgr eventListForServiceId:ServiceDiscoveryServiceId
                                                    profile:DConnectPhoneProfileName
                                                  attribute:DConnectPhoneProfileAttrOnConnect];
            for (DConnectEvent *evt in evts) {
                DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
                DConnectMessage *phoneStatus = [DConnectMessage message];
                [DConnectPhoneProfile setPhoneNumber:weakSelf.callingNumber target:phoneStatus];
                [DConnectPhoneProfile setState:callState target:phoneStatus];
                [DConnectPhoneProfile setPhoneStatus:phoneStatus target:eventMsg];
                [((DPHostDevicePlugin *)weakSelf.provider) sendEvent:eventMsg];
            }
        };
    }
    return self;
}

- (void)dealloc
{
    _callCenter.callEventHandler = nil;
}

#pragma mark - Post Methods

- (BOOL)          profile:(DConnectPhoneProfile *)profile
didReceivePostCallRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
              phoneNumber:(NSString *)phoneNumber
{
    if (!phoneNumber || phoneNumber.length > 11
        || ![DPHostUtils existDigitWithString:phoneNumber]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"phoneNumber must be specified."];
        return YES;
    }
    
    // 電話をかける内部的な準備が整っているかのチェック
    // （電波の強さ等外部的な要因はチェックする範疇じゃない）
    CTTelephonyNetworkInfo *netInfo = [CTTelephonyNetworkInfo new];
    CTCarrier *carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
        // 移動体通信事業者の情報取得で不備あり；電話をかける事ができない。
        [response setErrorToIllegalDeviceStateWithMessage:
            @"Mobile Network Code is invalid; "
            "check your SIM card or signal reception."];
        return YES;
    }
    
    NSArray *telSchemeArr = @[@"telprompt", @"tel"];
    for (NSString *telScheme in telSchemeArr) {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", telScheme, phoneNumber]];
        UIApplication *app = [UIApplication sharedApplication];
        if ([app canOpenURL:url] && [app openURL:url]) {
            _callingNumber = phoneNumber;
            [response setResult:DConnectMessageResultTypeOk];
            return YES;
        }
    }
    
    [response setErrorToUnknownWithMessage:@"Failed to make a phone call."];
    return YES;
}


#pragma mark - Put Methods
#pragma mark Event Registration

- (BOOL)              profile:(DConnectPhoneProfile *)profile
didReceivePutOnConnectRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                   sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr addEventForRequest:request]) {
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
}

#pragma mark - Delete Methods
#pragma mark Event Unregistration

- (BOOL)                 profile:(DConnectPhoneProfile *)profile
didReceiveDeleteOnConnectRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
                      sessionKey:(NSString *)sessionKey
{
    switch ([_eventMgr removeEventForRequest:request]) {
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
}


@end
