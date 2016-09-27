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
#import "DPHitoeEventDispatcher.h"
#import "DPHitoeEventDispatcherFactory.h"
#import "DPHitoeEventDispatcherManager.h"

@interface DPHitoeHealthProfile()
@property DConnectEventManager *eventMgr;
@property DPHitoeEventDispatcherManager *dispatcherManager;
@property (nonatomic, copy) void (^heartRateReceived)(DPHitoeDevice *device, DPHitoeHeartRateData *heartRate);

@end
@implementation DPHitoeHealthProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        self.dispatcherManager = [DPHitoeEventDispatcherManager new];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.heartRateReceived = ^(DPHitoeDevice *device, DPHitoeHeartRateData *heartRate) {
            [weakSelf notifyReceiveDataForDevice:device data:heartRate];
        };
        
        NSString *didReceiveGetHeartRequestApiPath = [self apiPath: nil
                                                     attributeName: DCMHealthProfileAttrHeart];
        [self addGetPath:didReceiveGetHeartRequestApiPath api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveGetHeartRequest:request response:response serviceId:[request serviceId]];
        }];
        NSString *didReceivePutHeartRequest = [self apiPath: nil
                                              attributeName: DCMHealthProfileAttrHeart];
        [self addPutPath:didReceivePutHeartRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutHeartRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];
        NSString *didReceiveDeleteHeartRequest = [self apiPath: nil
                                                 attributeName: DCMHealthProfileAttrHeart];
        [self addDeletePath:didReceiveDeleteHeartRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeleteHeartRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];
        
    }
    return self;
}


- (BOOL) didReceiveGetHeartRequest:(DConnectRequestMessage *)request
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


- (BOOL) didReceivePutHeartRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                    origin:(NSString *)origin {
    if (!serviceId) {
        [response setErrorToNotFoundServiceWithMessage:@"Not found serviceID"];
    } else if (!origin) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Not found origin"];
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
                {
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.heartRateReceived = self.heartRateReceived;
                    DPHitoeEventDispatcher *dispatcher = [DPHitoeEventDispatcherFactory createEventDispatcherForDevicePlugin:self.plugin
                                                                                                                     request:request];
                    [_dispatcherManager addEventDispatcherForServiceId:serviceId dispatcher:dispatcher];

                }
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

- (BOOL)didReceiveDeleteHeartRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                              origin:(NSString *)origin {
    if (!serviceId) {
        [response setErrorToNotFoundServiceWithMessage:@"Not found serviceID"];
    } else if (!origin) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Not found origin"];
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
            [_dispatcherManager removeEventDispacherForServiceId:serviceId];
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
        [_dispatcherManager sendEventForServiceId:device.serviceId message:eventMsg];
    }
}

@end
