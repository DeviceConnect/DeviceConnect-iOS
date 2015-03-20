//
//  DPSpheroDriveControllerProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPSpheroDriveControllerProfile.h"
#import "DPSpheroDevicePlugin.h"
#import "DPSpheroManager.h"


@implementation DPSpheroDriveControllerProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;

    }
    return self;
}

// デバイスの操作
- (BOOL)                             profile:(DCMDriveControllerProfile *)profile
    didReceivePostDriveControllerMoveRequest:(DConnectRequestMessage *)request
                                    response:(DConnectResponseMessage *)response
                                   serviceId:(NSString *)serviceId
                                       angle:(double)angle
                                       speed:(double)speed
{
    // 接続確認
    CONNECT_CHECK();
    
    
    // パラメータチェック
    NSString *angleString = [request stringForKey:DCMDriveControllerProfileParamAngle];
    NSString *speedString = [request stringForKey:DCMDriveControllerProfileParamSpeed];
    if (!angleString) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid angle value."];
        return YES;
    }
    if (![[DPSpheroManager sharedManager] existDigitWithString:angleString] || angle < 0 || angle > 360 ) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid angle value."];
        return YES;
    }
    if (!speedString) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid speed value."];
        return YES;
    }
    if (![[DPSpheroManager sharedManager] existDecimalWithString:speedString]
                || speed < 0 || speed > 1.0) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid speed value."];
        return YES;
    }

    // 移動
    [[DPSpheroManager sharedManager] move:angle velocity:speed];

    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}


// デバイスの回転
- (BOOL)                              profile:(DCMDriveControllerProfile *)profile
    didReceivePutDriveControllerRotateRequest:(DConnectRequestMessage *)request
                                     response:(DConnectResponseMessage *)response
                                    serviceId:(NSString *)serviceId
                                        angle:(double)angle
{
    // 接続確認
    CONNECT_CHECK();

    // パラメータチェック
    NSString *angleString = [request stringForKey:DCMDriveControllerProfileParamAngle];
    if (!angleString) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid angle value."];
        return YES;
    }
    if(![[DPSpheroManager sharedManager] existDigitWithString:angleString]
        || angle < 0 || angle > 360) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid angle value."];
        return YES;
    }
    
    // 回転
    [[DPSpheroManager sharedManager] rotate:angle];
    
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
    
}

// デバイスの停止
- (BOOL)                               profile:(DCMDriveControllerProfile *)profile
    didReceiveDeleteDriveControllerStopRequest:(DConnectRequestMessage *)request
                                      response:(DConnectResponseMessage *)response
                                     serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();

    // 停止
    [[DPSpheroManager sharedManager] stop];
    
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

@end
