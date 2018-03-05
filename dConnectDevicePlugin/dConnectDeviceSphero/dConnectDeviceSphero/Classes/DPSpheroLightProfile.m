//
//  DPSpheroLightProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroLightProfile.h"
#import "DPSpheroDevicePlugin.h"
#import "DPSpheroManager.h"
#import "DPSpheroDeviceRepeatExecutor.h"


@implementation DPSpheroLightProfile {
    DPSpheroDeviceRepeatExecutor *_flashingExecutor;
}


// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        __weak DPSpheroLightProfile *weakSelf = self;

        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addGetPath: getLightRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         NSArray *arr = [serviceId componentsSeparatedByString:@"_"];
                         NSString *lightId = nil;
                         if (arr.count == 2) {
                             lightId = arr[1];
                             serviceId = arr[0];
                         }
                         // 接続確認
                         CONNECT_CHECK();
                         
                         DConnectArray *lights = [DConnectArray array];
                         DConnectMessage *led = [DConnectMessage new];
                         DConnectMessage *calibration = [DConnectMessage new];
                         
                         [response setResult:DConnectMessageResultTypeOk];
                         if (!lightId || (lightId && [lightId isEqualToString:kDPSpheroLED])) {
                             // 全体の色を変えるためのID
                             [DConnectLightProfile setLightId:kDPSpheroLED target:led];
                             [DConnectLightProfile setLightName:kDPSpheroLEDName target:led];
                             [DConnectLightProfile setLightOn:[DPSpheroManager sharedManager].isLEDOn target:led];
                             [DConnectLightProfile setLightConfig:@"" target:led];
                             [lights addMessage:led];
                         }
                         if (!lightId || (lightId && [lightId isEqualToString:kDPSpheroCalibration])) {
                             // CalibrationのライトをつけるためのID(ON/OFFのみ)
                             [DConnectLightProfile setLightId:kDPSpheroCalibration target:calibration];
                             [DConnectLightProfile setLightName:kDPSpheroCalibrationName target:calibration];
                             [DConnectLightProfile setLightOn:[DPSpheroManager sharedManager].calibrationLightBright>0 target:calibration];
                             [DConnectLightProfile setLightConfig:@"" target:calibration];
                             [lights addMessage:calibration];
                         }
                         
                         [DConnectLightProfile setLights:lights target:response];
                         
                         return YES;
                     }];
        
        // API登録(didReceivePostLightRequest相当)
        NSString *postLightRequestApiPath = [self apiPath: nil
                                            attributeName: nil];
        [self addPostPath: postLightRequestApiPath
                      api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                          NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                          NSString *color = [DConnectLightProfile colorFromRequest: request];
                          NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];
                          NSArray *arr = [serviceId componentsSeparatedByString:@"_"];
                          if (arr.count == 2) {
                              lightId = arr[1];
                              serviceId = arr[0];
                          }
                          return [weakSelf postLightRequest:request response:response serviceId:serviceId lightId:lightId brightness:brightness color:color flashing:flashing];
                      }];
        
        // API登録(didReceivePutLightRequest相当)
        NSString *putLightRequestApiPath = [self apiPath: nil
                                           attributeName: nil];
        [self addPutPath: putLightRequestApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                         NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
                         if (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0)) {
                             [response setErrorToInvalidRequestParameterWithMessage:
                              @"Parameter 'brightness' must be a value between 0 and 1.0."];
                             return YES;
                         }
                         NSString *name = [request stringForKey:DConnectLightProfileParamName];
                         NSString *color = [request stringForKey:DConnectLightProfileParamColor];
                         NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];
                         if (flashing && ![weakSelf checkFlash:response flashing:flashing]) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }

                         if (name == nil || [name isEqualToString:@""]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"name is invalid."];
                             return YES;
                         }
                         NSArray *arr = [serviceId componentsSeparatedByString:@"_"];
                         if (arr.count == 2) {
                             serviceId = arr[0];
                             lightId = arr[1];
                         }
                         return [weakSelf postLightRequest:request response:response serviceId:serviceId lightId:lightId brightness:brightness color:color flashing:flashing];
                     }];
        
        // API登録(didReceiveDeleteLightRequest相当)
        NSString *deleteLightRequestApiPath = [self apiPath: nil
                                              attributeName: nil];
        [self addDeletePath: deleteLightRequestApiPath
                        api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
                            
                            if (!serviceId) {
                                [response setErrorToEmptyServiceId];
                                return YES;
                            }
                            NSArray *arr = [serviceId componentsSeparatedByString:@"_"];
                            if (arr.count == 2) {
                                serviceId = arr[0];
                                lightId = arr[1];
                            }
                            
                            // lightIdが省略された場合には、SpherorLEBを使用する
                            if (!lightId) {
                                lightId = kDPSpheroLED;
                            }
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            if ([lightId isEqualToString:kDPSpheroCalibration]) {
                                // キャリブレーションライト消灯。
                                [[DPSpheroManager sharedManager] setCalibrationLightBright:0 serviceId:serviceId];
                            } else if ([lightId isEqualToString:kDPSpheroLED]) {
                                // LED消灯
                                [[DPSpheroManager sharedManager] setLEDLightColor:[UIColor blackColor] serviceId:serviceId];
                            } else {
                                // lightIdエラー
                                [response setErrorToInvalidRequestParameterWithMessage:@"lightId is Invalid."];
                                return YES;
                            }
                            [response setResult:DConnectMessageResultTypeOk];
                            
                            return YES;
                        }];
    }
    return self;
    
}

-(BOOL) postLightRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
                 lightId:(NSString *)lightId
              brightness:(NSNumber *)brightness
                   color:(NSString *)color
                flashing:(NSArray *)flashing {
    
    if (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0)) {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"Parameter 'brightness' must be a value between 0 and 1.0."];
        return YES;
    }
    
    if (flashing && ![self checkFlash:response flashing:flashing]) {
        [response setErrorToInvalidRequestParameter];
        return YES;
    }
    
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    // lightIdが省略された場合には、SpherorLEDを使用する
    if (!lightId) {
        lightId = kDPSpheroLED;
    }
    
    // 接続確認
    CONNECT_CHECK();
    
    // lightId確認
    if (![lightId isEqualToString:kDPSpheroCalibration] &&
        ![lightId isEqualToString:kDPSpheroLED]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"lightId is Invalid."];
        return YES;
    }

    NSString *brightnessString = [request stringForKey:DConnectLightProfileParamBrightness];
    if (brightnessString &&
        (![[DPSpheroManager sharedManager] existDecimalWithString:brightnessString]
         || [brightness doubleValue] < 0 || [brightness doubleValue] > 1.0)) {
            [response setErrorToInvalidRequestParameterWithMessage:@"invalid brightness value."];
            return YES;
        }
    
    if ([lightId isEqualToString:kDPSpheroCalibration]) {
        // キャリブレーションライト点灯。 colorは変えられない。点灯、消灯のみ
        if (flashing.count > 0) {
            // 点滅
            _flashingExecutor = [[DPSpheroDeviceRepeatExecutor alloc] initWithPattern:flashing on:^{
                [[DPSpheroManager sharedManager] setCalibrationLightBright:[brightness doubleValue] serviceId:serviceId];
            } off:^{
                [[DPSpheroManager sharedManager] setCalibrationLightBright:0 serviceId:serviceId];
            }];
        } else {
            // 点灯
            [[DPSpheroManager sharedManager] setCalibrationLightBright:[brightness doubleValue] serviceId:serviceId];
        }
    } else if ([lightId isEqualToString:kDPSpheroLED]) {
        // LED点灯
        UIColor *ledColor;
        if (color) {
            if (color.length != 6) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
            unsigned int redValue, greenValue, blueValue;
            NSString *redString = [color substringWithRange:NSMakeRange(0, 2)];
            NSString *greenString = [color substringWithRange:NSMakeRange(2, 2)];
            NSString *blueString = [color substringWithRange:NSMakeRange(4, 2)];
            NSScanner *scan = [NSScanner scannerWithString:redString];
            
            if (![scan scanHexInt:&redValue]) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
            scan = [NSScanner scannerWithString:greenString];
            if (![scan scanHexInt:&greenValue]) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
            scan = [NSScanner scannerWithString:blueString];
            if (![scan scanHexInt:&blueValue]) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
            
            ledColor = [UIColor colorWithRed:redValue/255. green:greenValue/255. blue:blueValue/255. alpha:[brightness doubleValue]];
        } else {
            ledColor = [UIColor colorWithRed:255. green:255. blue:255. alpha:[brightness doubleValue]];
        }
        if (flashing.count>0) {
            // 点滅
            _flashingExecutor = [[DPSpheroDeviceRepeatExecutor alloc] initWithPattern:flashing on:^{
                [[DPSpheroManager sharedManager] setLEDLightColor:ledColor serviceId:serviceId];
            } off:^{
                [[DPSpheroManager sharedManager] setLEDLightColor: [UIColor blackColor] serviceId:serviceId];
            }];

        } else {
            // 点灯
            [[DPSpheroManager sharedManager] setLEDLightColor:ledColor serviceId:serviceId];
        }
    }
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

@end
