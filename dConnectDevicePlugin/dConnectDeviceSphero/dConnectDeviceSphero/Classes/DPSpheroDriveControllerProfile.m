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
        
        // API登録(didReceivePostDriveControllerMoveRequest相当)
        NSString *postDriveControllerMoveRequestApiPath = [self apiPath: nil
                                                          attributeName: DCMDriveControllerProfileAttrMove];
        [self addPostPath: postDriveControllerMoveRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          double angle = [request doubleForKey:DCMDriveControllerProfileParamAngle];
                          double speed = [request doubleForKey:DCMDriveControllerProfileParamSpeed];
                          
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
                      }];
        
        // API登録(didReceivePutDriveControllerRotateRequest相当)
        NSString *putDriveControllerRotateRequestApiPath = [self apiPath: nil
                                                           attributeName: DCMDriveControllerProfileAttrRotate];
        [self addPutPath: putDriveControllerRotateRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          double angle = [request doubleForKey:DCMDriveControllerProfileParamAngle];
                          
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
                      }];
        
        // API登録(didReceiveDeleteDriveControllerStopRequest相当)
        NSString *deleteDriveControllerStopRequestApiPath = [self apiPath: nil
                                                            attributeName: DCMDriveControllerProfileAttrStop];
        [self addDeletePath: deleteDriveControllerStopRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          
                          // 接続確認
                          CONNECT_CHECK();
                          
                          // 停止
                          [[DPSpheroManager sharedManager] stop];
                          
                          [response setResult:DConnectMessageResultTypeOk];
                          return YES;
                      }];
    }
    return self;
}

@end
