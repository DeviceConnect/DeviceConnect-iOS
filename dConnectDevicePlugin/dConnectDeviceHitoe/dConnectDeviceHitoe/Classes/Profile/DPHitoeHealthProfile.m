//
//  DPHitoeHealthProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeConsts.h"
#import "DPHitoeHealthProfile.h"
#import "DPHitoeDevicePlugin.h"
#import "DPHitoeManager.h"
#import "DPHitoeHeartRateData.h"
#import "DPHitoeHeartData.h"
#import "DPHitoeDevice.h"

@interface DPHitoeHealthProfile()
@property DConnectEventManager *eventMgr;
@property (nonatomic, copy) void (^heartRateReceived)(DPHitoeDevice *device, DPHitoeHeartRateData *heartRate);

@end
@implementation DPHitoeHealthProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;

        self.heartRateReceived = ^(DPHitoeDevice *device, DPHitoeHeartRateData *heartRate) {
            [weakSelf notifyReceiveDataForDevice:device data:heartRate];
        };
    }
    return self;
}


- (BOOL)          profile:(DCMHealthProfile *)profile
didReceiveGetHeartRequest:(DConnectRequestMessage *)request
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
        DPHitoeHeartRateData *data = [mgr getHeartRateDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            [DCMHealthProfile setHeart:[self getHeartRateMessageForHeartRateData:data] target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}


- (BOOL)           profile:(DCMHealthProfile *)profile
 didReceivePutHeartRequest:(DConnectRequestMessage *)request
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
        DPHitoeHeartRateData *data = [mgr getHeartRateDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.heartRateReceived = self.heartRateReceived;
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

- (BOOL)                           profile:(DCMHealthProfile *)profile
              didReceiveDeleteHeartRequest:(DConnectRequestMessage *)request
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
        DPHitoeHeartRateData *data = [mgr getHeartRateDataForServiceId:serviceId];
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

- (DConnectMessage *)getHeartRateMessageForHeartRateData:(DPHitoeHeartRateData*)data {
    DConnectMessage *heart = [DConnectMessage new];
    [DCMHealthProfile setRate:[data.heartRate toDConnectMessage] target:heart];
    if (data.rrinterval) {
        [DCMHealthProfile setRRI:[data.rrinterval toDConnectMessage] target:heart];
    }
    if (data.energyExpended) {
        [DCMHealthProfile setEnergyExtended:[data.energyExpended toDConnectMessage] target:heart];
    }
    if (data.target) {
        [DCMHealthProfile setDevice:[data.target toDConnectMessage] target:heart];
    }
    return heart;
}

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoeHeartRateData *)data {

    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DCMHealthProfileName
                                           attribute:DCMHealthProfileAttrHeart];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DCMHealthProfile setHeart:[self getHeartRateMessageForHeartRateData:data] target:eventMsg];
        [((DPHitoeDevicePlugin *)self.provider) sendEvent:eventMsg];
    }
}

@end