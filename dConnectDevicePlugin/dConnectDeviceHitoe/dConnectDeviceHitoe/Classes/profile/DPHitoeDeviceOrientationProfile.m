//
//  DPHitoeDeviceOrientationProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHitoeDeviceOrientationProfile.h"

#import "DPHitoeConsts.h"
#import "DPHitoeDeviceOrientationProfile.h"
#import "DPHitoeDevicePlugin.h"
#import "DPHitoeManager.h"
#import "DPHitoeAccelerationData.h"
#import "DPHitoeDevice.h"
#import "DPHitoeEventDispatcher.h"
#import "DPHitoeEventDispatcherFactory.h"
#import "DPHitoeEventDispatcherManager.h"

@interface DPHitoeDeviceOrientationProfile()
@property DConnectEventManager *eventMgr;
@property DPHitoeEventDispatcherManager *dispatcherManager;
@property (nonatomic, copy) void (^accelReceived)(DPHitoeDevice *device, DPHitoeAccelerationData *accel);

@end
@implementation DPHitoeDeviceOrientationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        self.dispatcherManager = [DPHitoeEventDispatcherManager new];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.accelReceived = ^(DPHitoeDevice *device, DPHitoeAccelerationData *accel) {
            [weakSelf notifyReceiveDataForDevice:device data:accel];
        };
        NSString *didReceiveGetOnDeviceOrientationRequest = [self apiPath: nil
                                                            attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addGetPath:didReceiveGetOnDeviceOrientationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveGetOnDeviceOrientationRequest:request response:response serviceId:[request serviceId]];
        }];
        NSString *didReceivePutOnDeviceOrientationRequest = [self apiPath: nil
                                                            attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addPutPath:didReceivePutOnDeviceOrientationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutOnDeviceOrientationRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];
        NSString *didReceiveDeleteOnDeviceOrientationRequest = [self apiPath: nil
                                                               attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addDeletePath:didReceiveDeleteOnDeviceOrientationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeleteOnDeviceOrientationRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];

    }
    return self;
}


- (BOOL)didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
        DPHitoeAccelerationData *data = [mgr getAccelerationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            [DConnectDeviceOrientationProfile setOrientation:[data toDConnectMessage] target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}


- (BOOL)didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
        DPHitoeAccelerationData *data = [mgr getAccelerationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                {
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.accelReceived = self.accelReceived;
                    // interval値の設定
                    NSString *intervalString = [request stringForKey:@"interval"];
                    long long interval = DPHitoeACCSamplingInterval;
                    if ([intervalString longLongValue] > 0) {
                        interval = [intervalString longLongValue];
                    }
                    ((DPHitoeAccelerationData *) [mgr getAccelerationDataForServiceId:serviceId]).interval = interval;
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

- (BOOL)didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
        DPHitoeAccelerationData *data = [mgr getAccelerationDataForServiceId:serviceId];
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

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoeAccelerationData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DConnectDeviceOrientationProfileName
                                           attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectDeviceOrientationProfile setOrientation:[data toDConnectMessage] target:eventMsg];
        [_dispatcherManager sendEventForServiceId:device.serviceId message:eventMsg];
    }
}

@end
