//
//  DPHitoePoseEstimationProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoePoseEstimationProfile.h"

#import "DPHitoeConsts.h"
#import "DPHitoeDevicePlugin.h"
#import "DPHitoeManager.h"
#import "DPHitoePoseEstimationProfile.h"
#import "DPHitoeDevice.h"

@interface DPHitoePoseEstimationProfile()
@property DConnectEventManager *eventMgr;
@property (nonatomic, copy) void (^poseReceived)(DPHitoeDevice *device, DPHitoePoseEstimationData *pose);

@end
@implementation DPHitoePoseEstimationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.poseReceived = ^(DPHitoeDevice *device, DPHitoePoseEstimationData *pose) {
            [weakSelf notifyReceiveDataForDevice:device data:pose];
        };
    }
    return self;
}


- (BOOL)          profile:(DCMPoseEstimationProfile *)profile
didReceiveGetOnPoseEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoePoseEstimationData *data = [mgr getPoseEstimationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            [DCMPoseEstimationProfile setPose:[data toDConnectMessage] target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}


- (BOOL)           profile:(DCMPoseEstimationProfile *)profile
didReceivePutOnPoseEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoePoseEstimationData *data = [mgr getPoseEstimationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.poseEstimationReceived = self.poseReceived;
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

- (BOOL)                           profile:(DCMPoseEstimationProfile *)profile
didReceiveDeleteOnPoseEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoePoseEstimationData *data = [mgr getPoseEstimationDataForServiceId:serviceId];
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

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoePoseEstimationData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DCMPoseEstimationProfileName
                                           attribute:DCMPoseEstimationProfileAttrOnPoseEstimation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DCMPoseEstimationProfile setPose:[data toDConnectMessage] target:eventMsg];
        [((DPHitoeDevicePlugin *)self.provider) sendEvent:eventMsg];
    }
}


@end
