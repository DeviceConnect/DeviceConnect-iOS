//
//  DPHitoeStressEstimationProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeStressEstimationProfile.h"
#import "DPHitoeConsts.h"
#import "DPHitoeDevicePlugin.h"
#import "DPHitoeManager.h"
#import "DPHitoeStressEstimationData.h"
#import "DPHitoeDevice.h"

@interface DPHitoeStressEstimationProfile()
@property DConnectEventManager *eventMgr;
@property (nonatomic, copy) void (^stressReceived)(DPHitoeDevice *device, DPHitoeStressEstimationData *stress);

@end
@implementation DPHitoeStressEstimationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.stressReceived = ^(DPHitoeDevice *device, DPHitoeStressEstimationData *stress) {
            [weakSelf notifyReceiveDataForDevice:device data:stress];
        };
    }
    return self;
}


- (BOOL)          profile:(DCMStressEstimationProfile *)profile
didReceiveGetOnStressEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoeStressEstimationData *data = [mgr getStressEstimationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            [DCMStressEstimationProfile setStress:[data toDConnectMessage] target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}


- (BOOL)           profile:(DCMStressEstimationProfile *)profile
didReceivePutOnStressEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoeStressEstimationData *data = [mgr getStressEstimationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.stressEstimationReceived = self.stressReceived;
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

- (BOOL)                           profile:(DCMStressEstimationProfile *)profile
   didReceiveDeleteOnStressEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoeStressEstimationData *data = [mgr getStressEstimationDataForServiceId:serviceId];
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

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoeStressEstimationData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DCMStressEstimationProfileName
                                           attribute:DCMStressEstimationProfileAttrOnStressEstimation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DCMStressEstimationProfile setStress:[data toDConnectMessage] target:eventMsg];
        [((DPHitoeDevicePlugin *)self.provider) sendEvent:eventMsg];
    }
}


@end
