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
#import "DPHitoeEventDispatcher.h"
#import "DPHitoeEventDispatcherFactory.h"
#import "DPHitoeEventDispatcherManager.h"

@interface DPHitoePoseEstimationProfile()
@property DConnectEventManager *eventMgr;
@property DPHitoeEventDispatcherManager *dispatcherManager;
@property (nonatomic, copy) void (^poseReceived)(DPHitoeDevice *device, DPHitoePoseEstimationData *pose);

@end
@implementation DPHitoePoseEstimationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHitoeDevicePlugin class]];
        self.dispatcherManager = [DPHitoeEventDispatcherManager new];
        __unsafe_unretained typeof(self) weakSelf = self;
        self.poseReceived = ^(DPHitoeDevice *device, DPHitoePoseEstimationData *pose) {
            [weakSelf notifyReceiveDataForDevice:device data:pose];
        };
        NSString *didReceiveGetOnPoseEstimationRequest = [self apiPath: nil
                                                         attributeName: DCMPoseEstimationProfileAttrOnPoseEstimation];
        [self addGetPath:didReceiveGetOnPoseEstimationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveGetOnPoseEstimationRequest:request response:response serviceId:[request serviceId]];
        }];
        NSString *didReceivePutOnPoseEstimationRequest = [self apiPath: nil
                                                         attributeName: DCMPoseEstimationProfileAttrOnPoseEstimation];
        [self addPutPath:didReceivePutOnPoseEstimationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutOnPoseEstimationRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];
        NSString *didReceiveDeleteOnPoseEstimationRequest = [self apiPath: nil
                                                            attributeName: DCMPoseEstimationProfileAttrOnPoseEstimation];
        [self addDeletePath:didReceiveDeleteOnPoseEstimationRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeleteOnPoseEstimationRequest:request response:response serviceId:[request serviceId] origin:[request origin]];
        }];

    }
    return self;
}


- (BOOL)didReceiveGetOnPoseEstimationRequest:(DConnectRequestMessage *)request
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


- (BOOL)didReceivePutOnPoseEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoePoseEstimationData *data = [mgr getPoseEstimationDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        } else {
            switch ([_eventMgr addEventForRequest:request]) {
                case DConnectEventErrorNone:             // エラー無し.
                {
                    [response setResult:DConnectMessageResultTypeOk];
                    mgr.poseEstimationReceived = self.poseReceived;
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

- (BOOL)didReceiveDeleteOnPoseEstimationRequest:(DConnectRequestMessage *)request
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
        DPHitoePoseEstimationData *data = [mgr getPoseEstimationDataForServiceId:serviceId];
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

- (void)notifyReceiveDataForDevice:(DPHitoeDevice*)device data:(DPHitoePoseEstimationData *)data {
    
    
    NSArray *evts = [_eventMgr eventListForServiceId:device.serviceId
                                             profile:DCMPoseEstimationProfileName
                                           attribute:DCMPoseEstimationProfileAttrOnPoseEstimation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DCMPoseEstimationProfile setPose:[data toDConnectMessage] target:eventMsg];
        [_dispatcherManager sendEventForServiceId:device.serviceId message:eventMsg];
    }
}


@end
