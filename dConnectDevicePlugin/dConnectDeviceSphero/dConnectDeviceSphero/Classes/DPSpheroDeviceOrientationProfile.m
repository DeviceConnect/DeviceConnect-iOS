//
//  DPSpheroDeviceOrientationProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroDeviceOrientationProfile.h"
#import "DPSpheroDevicePlugin.h"
#import "DPSpheroManager.h"
#import "DPSpheroServiceDiscoveryProfile.h"

typedef void (^OrientationBlock)(DPAttitude attitude, DPPoint3D accel, int interval);

@interface DPSpheroDeviceOrientationProfile() <DPSpheroManagerOrientationDelegate>

@property NSMutableArray *orientationBlkArray;

/*!
 @brief Orientationイベント登録が存在するか確認をする.
 @retval YES イベント登録が存在する場合
 @retval NO イベント登録が存在しない場合
 */
- (BOOL) hasEventList;

@end

@implementation DPSpheroDeviceOrientationProfile

// 初期化
- (id)init {
    self = [super init];
    if (self) {
        self.delegate = self;
        [DPSpheroManager sharedManager].orientationDelegate = self;
        self.orientationBlkArray = [NSMutableArray new];
        
        __unsafe_unretained typeof(self) weakSelf = self;

        OrientationBlock blk = ^(DPAttitude attitude, DPPoint3D accel, int interval) {
            DConnectMessage *message = [weakSelf createOrientationWithAttitude:attitude accel:accel interval:interval];
            
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
            
            NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                                  profile:DConnectDeviceOrientationProfileName
                                                attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
            if (events == 0) {
                [[DPSpheroManager sharedManager] stopSensorOrientation];
            }
            for (DConnectEvent *msg in events) {
                DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:msg];
                [DConnectDeviceOrientationProfile setOrientation:message target:eventMsg];
                DConnectDevicePlugin *plugin = (DConnectDevicePlugin *)weakSelf.provider;
                [plugin sendEvent:eventMsg];
            }
        };
        [self.orientationBlkArray addObject:blk];
    }
    return self;
}

// 共通リクエスト処理
- (void)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             isRemove:(BOOL)isRemove
             callback:(void(^)())callback
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    DConnectEventError error;
    if (isRemove) {
        error = [mgr removeEventForRequest:request];
    } else {
        error = [mgr addEventForRequest:request];
    }
    
    if (error == DConnectEventErrorNone) {
        callback();
        [response setResult:DConnectMessageResultTypeOk];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
    } else {
        [response setErrorToUnknown];
    }
}

- (DConnectMessage *)createOrientationWithAttitude:(DPAttitude)attitude
                                             accel:(DPPoint3D)accel
                                          interval:(int)interval
{
    DConnectMessage *message = [DConnectMessage message];
    DConnectMessage *orientmsg = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setAlpha:attitude.yaw target:orientmsg];
    [DConnectDeviceOrientationProfile setBeta:attitude.roll target:orientmsg];
    [DConnectDeviceOrientationProfile setGamma:attitude.pitch target:orientmsg];
    DConnectMessage *accelmsg = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setX:accel.x * 9.81 target:accelmsg];
    [DConnectDeviceOrientationProfile setY:accel.y * 9.81 target:accelmsg];
    [DConnectDeviceOrientationProfile setZ:accel.z * 9.81 target:accelmsg];
    
    [DConnectDeviceOrientationProfile setAccelerationIncludingGravity:accelmsg target:message];
    [DConnectDeviceOrientationProfile setRotationRate:orientmsg target:message];
    [DConnectDeviceOrientationProfile setInterval:interval target:message];
    return message;
}

- (BOOL) hasEventList {
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPSpheroDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:[DPSpheroManager sharedManager].currentServiceID
                                          profile:DConnectDeviceOrientationProfileName
                                        attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    return events != nil && events.count > 0;
}

#pragma mark - DPSpheroManagerOrientationDelegate

// Orientationのイベント処理
- (void)spheroManagerStreamingOrientation:(DPAttitude)attitude
                                    accel:(DPPoint3D)accel
                                 interval:(int)interval
{
    for (OrientationBlock blk in self.orientationBlkArray) {
        blk(attitude, accel, interval);
    }
}

#pragma mark - DConnectDeviceOrientationProfileDelegate

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();

    __unsafe_unretained typeof(self) weakSelf = self;

    __block OrientationBlock blk = ^(DPAttitude attitude, DPPoint3D accel, int interval) {
        DConnectMessage *orientation = [weakSelf createOrientationWithAttitude:attitude accel:accel interval:interval];
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectDeviceOrientationProfile setOrientation:orientation target:response];

        DConnectManager *mgr = [DConnectManager sharedManager];
        [mgr sendResponse:response];

        [weakSelf.orientationBlkArray removeObject:blk];

        if (![weakSelf hasEventList]) {
            [[DPSpheroManager sharedManager] stopSensorOrientation];
        }
    };
    [self.orientationBlkArray addObject:blk];
    [[DPSpheroManager sharedManager] startSensorOrientation];
    return NO;
}

// Orientationのイベント登録
- (BOOL)                            profile:(DConnectDeviceOrientationProfile *)profile
    didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                   response:(DConnectResponseMessage *)response
                                  serviceId:(NSString *)serviceId
                                 sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:NO callback:^{
        [[DPSpheroManager sharedManager] startSensorOrientation];
    }];
    return YES;
}

// Orientationのイベント解除
- (BOOL)                               profile:(DConnectDeviceOrientationProfile *)profile
    didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                      response:(DConnectResponseMessage *)response
                                     serviceId:(NSString *)serviceId
                                    sessionKey:(NSString *)sessionKey
{
    // 接続確認
    CONNECT_CHECK();
    
    [self handleRequest:request response:response isRemove:YES callback:^{
        [[DPSpheroManager sharedManager] stopSensorOrientation];
    }];
    return YES;
}

@end
