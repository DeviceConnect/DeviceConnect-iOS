//
//  DPHostDeviceOrientationProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <CoreMotion/CoreMotion.h>
#import <DConnectSDK/DConnectSDK.h>

#import "DPHostDevicePlugin.h"
#import "DPHostDeviceOrientationProfile.h"
#import "DPHostServiceDiscoveryProfile.h"
#import "DPHostUtils.h"

// CMDeviceMotionオブジェクトが配送されるインターバル（ミリ秒）
static const double MotionDeviceIntervalMilliSec = 100;

// 地球の重力加速度
static const double EarthGravitationalAcceleration = 9.81;

@interface DPHostDeviceOrientationProfile ()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

// 加速度センサー、ジャイロセンサーからの値受領を管理するオブジェクト
@property CMMotionManager *motionManager;
// motionManagerで使うキュー
@property NSOperationQueue *deviceOrientationOpQueue;
// キューで回す処理
@property (strong) CMDeviceMotionHandler deviceOrientationOp;
/// @brief 加速度センサーの値を一時的にキャッシュする変数
@property DConnectMessage *orientation;

- (void) sendOnDeviceOrientationEventWithMotion:(CMDeviceMotion *)motion;

// モーションデータからorientationデータを作成する.
- (DConnectMessage *) createOrientationWithMotion:(CMDeviceMotion *)motion;

// イベント登録がされているか確認を行う.
- (BOOL) isEmptyEventList:(NSString *)serviceId;

@end

@implementation DPHostDeviceOrientationProfile

- (instancetype)init
{
    CMMotionManager *motionMgr = [CMMotionManager new];
    if (!motionMgr.accelerometerAvailable && !motionMgr.gyroAvailable) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        self.delegate = self;
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        
        _orientation = nil;
        _motionManager = motionMgr;
        _motionManager.deviceMotionUpdateInterval = MotionDeviceIntervalMilliSec/1000.0;
        _deviceOrientationOpQueue = [NSOperationQueue new];
        __unsafe_unretained typeof(self) weakSelf = self;
        _deviceOrientationOp = ^(CMDeviceMotion *motion, NSError *error) {
            if (error) {
                NSLog(@"DPHostDeviceOrientationProfile Error:\n%@", error.description);
                [weakSelf.motionManager stopDeviceMotionUpdates];
            }
            [weakSelf sendOnDeviceOrientationEventWithMotion:motion];
        };
    }
    return self;
}

- (void)dealloc
{
    [_motionManager stopDeviceMotionUpdates];
}

- (DConnectMessage *) createOrientationWithMotion:(CMDeviceMotion *)motion
{
    DConnectMessage *orientation = [DConnectMessage message];
    // 加速度系
    if (_motionManager.accelerometerAvailable) {
        DConnectMessage *acceleration = [DConnectMessage message];
        [DConnectDeviceOrientationProfile
         setX:motion.userAcceleration.x*EarthGravitationalAcceleration
         target:acceleration];
        [DConnectDeviceOrientationProfile
         setY:motion.userAcceleration.y*EarthGravitationalAcceleration
         target:acceleration];
        [DConnectDeviceOrientationProfile
         setZ:motion.userAcceleration.z*EarthGravitationalAcceleration
         target:acceleration];
        [DConnectDeviceOrientationProfile setAcceleration:acceleration target:orientation];
        
        DConnectMessage *accelerationIncludingGravity = [DConnectMessage message];
        [DConnectDeviceOrientationProfile
         setX:(motion.userAcceleration.x+motion.gravity.x)*EarthGravitationalAcceleration
         target:accelerationIncludingGravity];
        [DConnectDeviceOrientationProfile
         setY:(motion.userAcceleration.y+motion.gravity.y)*EarthGravitationalAcceleration
         target:accelerationIncludingGravity];
        [DConnectDeviceOrientationProfile
         setZ:(motion.userAcceleration.z+motion.gravity.z)*EarthGravitationalAcceleration
         target:accelerationIncludingGravity];
        [DConnectDeviceOrientationProfile setAccelerationIncludingGravity:accelerationIncludingGravity
                                                                   target:orientation];
    }
    // 角速度系
    if (_motionManager.gyroAvailable) {
        DConnectMessage *rotationRate = [DConnectMessage message];
        double coef = 180 / M_PI;
        [DConnectDeviceOrientationProfile setAlpha:(coef * motion.rotationRate.x) target:rotationRate];
        [DConnectDeviceOrientationProfile setBeta:(coef * motion.rotationRate.y)  target:rotationRate];
        [DConnectDeviceOrientationProfile setGamma:(coef * motion.rotationRate.z) target:rotationRate];
        [DConnectDeviceOrientationProfile setRotationRate:rotationRate target:orientation];
    }
    // インターバル（ミリ秒）
    [DConnectDeviceOrientationProfile setInterval:MotionDeviceIntervalMilliSec target:orientation];
    return orientation;
}

- (void) sendOnDeviceOrientationEventWithMotion:(CMDeviceMotion *)motion
{
    DConnectMessage *orientation = [self createOrientationWithMotion:motion];
    _orientation = orientation;
    
    NSArray *evts = [_eventMgr eventListForServiceId:ServiceDiscoveryServiceId
                                            profile:DConnectDeviceOrientationProfileName
                                          attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectDeviceOrientationProfile setOrientation:orientation target:eventMsg];
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (BOOL) isEmptyEventList:(NSString *)serviceId {
    NSArray *evts = [_eventMgr eventListForServiceId:serviceId
                                             profile:DConnectDeviceOrientationProfileName
                                           attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    return evts == nil || [evts count] == 0;
}

#pragma mark - Get Methods

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
    __unsafe_unretained typeof(self) weakSelf = self;

    if ([self isEmptyEventList:serviceId]) {
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error) {
            DConnectMessage *orientation = [weakSelf createOrientationWithMotion:motion];
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectDeviceOrientationProfile setOrientation:orientation target:response];
            
            DConnectManager *mgr = [DConnectManager sharedManager];
            [mgr sendResponse:response];
            
            if ([weakSelf isEmptyEventList:serviceId]) {
                [_motionManager stopDeviceMotionUpdates];
            }
        };
        
        [_motionManager startDeviceMotionUpdatesToQueue:_deviceOrientationOpQueue
                                            withHandler:handler];
        return NO;
    } else {
        if (_orientation) {
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectDeviceOrientationProfile setOrientation:_orientation target:response];
        } else {
            [response setErrorToUnknownWithMessage:@"device is not ready."];
        }
        return YES;
    }
}


#pragma mark - Put Methods
#pragma mark Event Registration

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    if ([self isEmptyEventList:serviceId]) {
        // CMMotionDeviceの配送処理が開始されていないのなら、開始する。
        [_motionManager startDeviceMotionUpdatesToQueue:_deviceOrientationOpQueue
                                            withHandler:_deviceOrientationOp];
    }
    
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

- (BOOL)                           profile:(DConnectDeviceOrientationProfile *)profile
didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
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
    
    if ([self isEmptyEventList:serviceId]) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    }
    
    return YES;
}

@end
