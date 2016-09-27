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

typedef void (^OrientationBlock)(DPGyroData gyroData, DPPoint3D accel, int interval);

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
        [DPSpheroManager sharedManager].orientationDelegate = self;
        self.orientationBlkArray = [NSMutableArray new];
        __weak DPSpheroDeviceOrientationProfile *weakSelf = self;

        OrientationBlock blk = ^(DPGyroData gyroData, DPPoint3D accel, int interval) {
            DConnectMessage *message = [weakSelf createOrientationWithAttitude:gyroData accel:accel interval:interval];
            
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
                DConnectDevicePlugin *plugin = (DConnectDevicePlugin *)weakSelf.plugin;
                [plugin sendEvent:eventMsg];
            }
        };
        [self.orientationBlkArray addObject:blk];
        
        // API登録(didReceiveGetOnDeviceOrientationRequest相当)
        NSString *getOnDeviceOrientationRequestApiPath = [self apiPath: nil
                                                         attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addGetPath: getOnDeviceOrientationRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         OrientationBlock blk = ^(DPGyroData gyroData, DPPoint3D accel, int interval) {
                             DConnectMessage *orientation = [weakSelf createOrientationWithAttitude:gyroData accel:accel interval:interval];
                             [response setResult:DConnectMessageResultTypeOk];
                             [DConnectDeviceOrientationProfile setOrientation:orientation target:response];
                             
                             DConnectManager *mgr = [DConnectManager sharedManager];
                             [mgr sendResponse:response];
                             [weakSelf.orientationBlkArray removeObject:blk];
                             if (![weakSelf hasEventList]) {
                                 [[DPSpheroManager sharedManager] stopSensorOrientation];
                             }
                         };
                         [[weakSelf orientationBlkArray] addObject:blk];
                         [[DPSpheroManager sharedManager] startSensorOrientation];
                         return NO;
                     }];
        
        // API登録(didReceivePutOnDeviceOrientationRequest相当)
        NSString *putOnDeviceOrientationRequestApiPath = [self apiPath: nil
                                                         attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addPutPath: putOnDeviceOrientationRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         [weakSelf handleRequest:request response:response isRemove:NO callback:^{
                             [[DPSpheroManager sharedManager] startSensorOrientation];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnDeviceOrientationRequest相当)
        NSString *deleteOnDeviceOrientationRequestApiPath = [self apiPath: nil
                                                            attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addDeletePath: deleteOnDeviceOrientationRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            NSString *serviceId = [request serviceId];
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            [weakSelf handleRequest:request response:response isRemove:YES callback:^{
                                [[DPSpheroManager sharedManager] stopSensorOrientation];
                            }];
                            return YES;
                        }];
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
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
}

- (DConnectMessage *)createOrientationWithAttitude:(DPGyroData)gyroData
                                             accel:(DPPoint3D)accel
                                          interval:(int)interval
{
    DConnectMessage *message = [DConnectMessage message];
    
    DConnectMessage *orientmsg = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setAlpha:gyroData.x target:orientmsg];
    [DConnectDeviceOrientationProfile setBeta:gyroData.y target:orientmsg];
    [DConnectDeviceOrientationProfile setGamma:gyroData.z target:orientmsg];
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
- (void)spheroManagerStreamingOrientation:(DPGyroData)gyroData
                                    accel:(DPPoint3D)accel
                                 interval:(int)interval
{
    for (OrientationBlock blk in [self.orientationBlkArray reverseObjectEnumerator]) {
        blk(gyroData, accel, interval);
    }
}

@end
