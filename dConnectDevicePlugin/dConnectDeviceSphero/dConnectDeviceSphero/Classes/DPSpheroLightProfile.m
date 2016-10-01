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

//LEDは色を変えられる
static NSString *const SpheroLED = @"1";
static NSString *const SpheroLEDName = @"Sphero LED";
//Calibrationは色を変えられない
static NSString *const SpheroCalibration = @"2";
static NSString *const SpheroCalibrationName = @"Sphero CalibrationLED";

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
                         
                         // 接続確認
                         CONNECT_CHECK();
                         
                         DConnectArray *lights = [DConnectArray array];
                         DConnectMessage *led = [DConnectMessage new];
                         DConnectMessage *calibration = [DConnectMessage new];
                         
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         //全体の色を変えるためのID
                         [DConnectLightProfile setLightId:SpheroLED target:led];
                         [DConnectLightProfile setLightName:SpheroLEDName target:led];
                         [DConnectLightProfile setLightOn:[DPSpheroManager sharedManager].isLEDOn target:led];
                         [DConnectLightProfile setLightConfig:@"" target:led];
                         [lights addMessage:led];
                         //CalibrationのライトをつけるためのID(ON/OFFのみ)
                         [DConnectLightProfile setLightId:SpheroCalibration target:calibration];
                         [DConnectLightProfile setLightName:SpheroCalibrationName target:calibration];
                         [DConnectLightProfile setLightOn:[DPSpheroManager sharedManager].calibrationLightBright>0 target:calibration];
                         [DConnectLightProfile setLightConfig:@"" target:calibration];
                         [lights addMessage:calibration];
                         
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
                         
                         if (!serviceId) {
                             [response setErrorToEmptyServiceId];
                             return YES;
                         }
                         
                         if (name == nil || [name isEqualToString:@""]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"name is invalid."];
                             return YES;
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
                            
                            // 接続確認
                            CONNECT_CHECK();
                            
                            if ([lightId isEqualToString:SpheroCalibration]) {
                                // キャリブレーションライト消灯。
                                [DPSpheroManager sharedManager].calibrationLightBright = 0;
                            } else if ([lightId isEqualToString:SpheroLED]) {
                                // LED消灯
                                [DPSpheroManager sharedManager].LEDLightColor = [UIColor blackColor];
                            } else {
                                // lightId確認
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
    
    // 接続確認
    CONNECT_CHECK();
    
    // lightId確認
    if (![lightId isEqualToString:SpheroCalibration] &&
        ![lightId isEqualToString:SpheroLED]) {
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
    
    if ([lightId isEqualToString:SpheroCalibration]) {
        // キャリブレーションライト点灯。 colorは変えられない。点灯、消灯のみ
        if (flashing.count>0) {
            // 点滅
            _flashingExecutor = [[DPSpheroDeviceRepeatExecutor alloc] initWithPattern:flashing on:^{
                [DPSpheroManager sharedManager].calibrationLightBright = [brightness doubleValue];
            } off:^{
                [DPSpheroManager sharedManager].calibrationLightBright = 0;
            }];

        } else {
            // 点灯
            [DPSpheroManager sharedManager].calibrationLightBright = [brightness doubleValue];
        }
    } else if ([lightId isEqualToString:SpheroLED]) {
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
                [DPSpheroManager sharedManager].LEDLightColor = ledColor;
            } off:^{
                [DPSpheroManager sharedManager].LEDLightColor = [UIColor blackColor];
            }];

        } else {
            // 点灯
            [DPSpheroManager sharedManager].LEDLightColor = ledColor;
        }
    }
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

@end
