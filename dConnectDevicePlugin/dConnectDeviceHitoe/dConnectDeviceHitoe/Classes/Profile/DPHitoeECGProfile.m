//
//  DPHitoeECGProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeConsts.h"
#import "DPHitoeECGProfile.h"
#import "DPHitoeDevicePlugin.h"
#import "DPHitoeManager.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeHeartData.h"
#import "DPHitoeDevice.h"

@interface DPHitoeECGProfile()
@property DConnectEventManager *eventMgr;
@property (nonatomic, copy) void (^ecgReceived)(DPHitoeDevice *device, DPHitoeHeartRateData *ecg);

@end
@implementation DPHitoeECGProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;
        
        self.ecgReceived = ^(DPHitoeDevice *device, DPHitoeHeartRateData *ecg) {
            [weakSelf notifyReceiveDataForDevice:device data:ecg];
        };
        NSString *didReceiveGetOnECGRequest = [self apiPathWithProfile: self.profileName
                                                                interfaceName: nil
                                                                attributeName: DCMECGProfileAttrOnECG];
        [self addGetPath:didReceiveGetOnECGRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveGetOnECGRequest:request response:response serviceId:[request serviceId]];
        }];
        NSString *didReceivePutOnECGRequest = [self apiPathWithProfile: self.profileName
                                                         interfaceName: nil
                                                         attributeName: DCMECGProfileAttrOnECG];
        [self addPutPath:didReceivePutOnECGRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutOnECGRequest:request response:response serviceId:[request serviceId] sessionKey:[request sessionKey]];
        }];
        NSString *didReceiveDeleteOnECGRequest = [self apiPathWithProfile: self.profileName
                                                            interfaceName: nil
                                                            attributeName: DCMECGProfileAttrOnECG];
        [self addDeletePath:didReceiveDeleteOnECGRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeleteOnECGRequest:request response:response serviceId:[request serviceId] sessionKey:[request sessionKey]];
        }];

    }
    return self;
}


- (BOOL)didReceiveGetOnECGRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId {
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    } else {
        DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
        if (!mgr) {
            [response setErrorToNotFoundService];
            return YES;
        }
        DPHitoeHeartRateData *data = [mgr getECGDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            [DCMECGProfile setECG:[data.ecg toDConnectMessage] target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}


- (BOOL)didReceivePutOnECGRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                sessionKey:(NSString *)sessionKey {
    if (!serviceId) {
        [response setErrorToNotFoundServiceWithMessage:@"Not found serviceID"];
    } else if (!sessionKey) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Not found sessionKey"];
    } else {
        DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
        if (!mgr) {
            [response setErrorToNotFoundService];
            return YES;
        }
        DPHitoeHeartRateData *data = [mgr getECGDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.ecgReceived = self.ecgReceived;
                    break;
                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                    [response setErrorToInvalidRequestParameter];
                    break;
                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                case DConnectEventErrorFailed:           // 処理失敗.
                    [response setErrorToUnknown];
                    break;
            }
        }
        
    }
    return YES;
}

- (BOOL)didReceiveDeleteOnECGRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                 serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey {
    if (!serviceId) {
        [response setErrorToNotFoundServiceWithMessage:@"Not found serviceID"];
    } else if (!sessionKey) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Not found sessionKey"];
    } else {
        DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
        if (!mgr) {
            [response setErrorToNotFoundService];
            return YES;
        }
        DPHitoeHeartRateData *data = [mgr getECGDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            
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
        }
    }
    
    return YES;
}

#pragma mark - Private Method

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoeHeartRateData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DCMECGProfileName
                                           attribute:DCMECGProfileAttrOnECG];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DCMECGProfile setECG:[data.ecg toDConnectMessage] target:eventMsg];
        [((DPHitoeDevicePlugin *)self.provider) sendEvent:eventMsg];
    }
}


@end
