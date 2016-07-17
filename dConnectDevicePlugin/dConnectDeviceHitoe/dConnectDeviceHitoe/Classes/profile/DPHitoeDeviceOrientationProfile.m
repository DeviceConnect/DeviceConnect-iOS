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

@interface DPHitoeDeviceOrientationProfile()
@property DConnectEventManager *eventMgr;
@property (nonatomic, copy) void (^accelReceived)(DPHitoeDevice *device, DPHitoeAccelerationData *accel);

@end
@implementation DPHitoeDeviceOrientationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.accelReceived = ^(DPHitoeDevice *device, DPHitoeAccelerationData *accel) {
            [weakSelf notifyReceiveDataForDevice:device data:accel];
        };
    }
    return self;
}


- (BOOL)          profile:(DConnectDeviceOrientationProfile *)profile
  didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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


- (BOOL)           profile:(DConnectDeviceOrientationProfile *)profile
   didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
        DPHitoeAccelerationData *data = [mgr getAccelerationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.accelReceived= self.accelReceived;
                    // @todo interval取得
                    //                    NSString *intervalString = [request stringForKey:@"interval"];
                    long interval = DPHitoeACCSamplingInterval;
                    ((DPHitoeAccelerationData *) [mgr getAccelerationDataForServiceId:serviceId]).interval = interval;
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

- (BOOL)                           profile:(DConnectDeviceOrientationProfile *)profile
didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
        DPHitoeAccelerationData *data = [mgr getAccelerationDataForServiceId:serviceId];
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

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoeAccelerationData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DConnectDeviceOrientationProfileName
                                           attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectDeviceOrientationProfile setOrientation:[data toDConnectMessage] target:eventMsg];
        [((DPHitoeDevicePlugin *)self.provider) sendEvent:eventMsg];
    }
}

@end
