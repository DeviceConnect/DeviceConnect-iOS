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

//LEDは色を変えられる
NSString *const SpheroLED = @"1";
NSString *const SpheroLEDName = @"Sphero LED";
//Calibrationは色を変えられない
NSString *const SpheroCalibration = @"2";
NSString *const SpheroCalibrationName = @"Sphero CalibrationLED";

@implementation DPSpheroLightProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
    
}

// デバイスのライトのステータスを取得する
- (BOOL) profile:(DCMLightProfile *)profile didReceiveGetLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    // 接続確認
    CONNECT_CHECK();
    
    DConnectArray *lights = [DConnectArray array];
    DConnectMessage *led = [DConnectMessage new];
    DConnectMessage *calibration = [DConnectMessage new];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    //全体の色を変えるためのID
    [led setString:SpheroLED forKey:DCMLightProfileParamLightId];
    [led setString:SpheroLEDName forKey:DCMLightProfileParamName];
    
    [led setBool:[DPSpheroManager sharedManager].isLEDOn forKey:DCMLightProfileParamOn];
    [led setString:@"" forKey:DCMLightProfileParamConfig];
    [lights addMessage:led];
    //CalibrationのライトをつけるためのID(ON/OFFのみ)
    [calibration setString:SpheroCalibration forKey:DCMLightProfileParamLightId];
    [calibration setString:SpheroCalibrationName forKey:DCMLightProfileParamName];
    [calibration setBool:[DPSpheroManager sharedManager].calibrationLightBright>0 forKey:DCMLightProfileParamOn];
    [calibration setString:@"" forKey:DCMLightProfileParamConfig];
    [lights addMessage:calibration];
    
    [response setArray:lights forKey:DCMLightProfileParamLights];
    
    return YES;
}


// デバイスのライトを点灯する
- (BOOL)               profile:(DCMLightProfile *)profile
    didReceivePostLightRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                       lightId:(NSString*)lightId
                    brightness:(double)brightness
                         color:(NSString*)color
                      flashing:(NSArray*)flashing
{
    // 接続確認
    CONNECT_CHECK();
    
    // lightId確認
    if (![lightId isEqualToString:SpheroCalibration] &&
        ![lightId isEqualToString:SpheroLED]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"lightId is Invalid."];
        return YES;
    }
    NSString *brightnessString = [request stringForKey:DCMLightProfileParamBrightness];
    if (brightnessString &&
        (![[DPSpheroManager sharedManager] existDecimalWithString:brightnessString]
         || brightness < 0 || brightness > 1.0)) {
        [response setErrorToInvalidRequestParameterWithMessage:@"invalid brightness value."];
        return YES;
    }
    
    if ([lightId isEqualToString:SpheroCalibration]) {
        // キャリブレーションライト点灯。 colorは変えられない。点灯、消灯のみ
        if (flashing.count>0) {
            // 点滅
            [[DPSpheroManager sharedManager] flashLightWithBrightness:brightness flashData:flashing];
        } else {
            // 点灯
            [DPSpheroManager sharedManager].calibrationLightBright = brightness;
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
            
            ledColor = [UIColor colorWithRed:redValue/255. green:greenValue/255. blue:blueValue/255. alpha:brightness];
        } else {
            ledColor = [UIColor colorWithRed:255. green:255. blue:255. alpha:brightness];
        }
        if (flashing.count>0) {
            // 点滅
            [[DPSpheroManager sharedManager] flashLightWithColor:ledColor flashData:flashing];
        } else {
            // 点灯
            [DPSpheroManager sharedManager].LEDLightColor = ledColor;
        }
    }
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

// デバイスのライトのステータスを変更する
- (BOOL)              profile:(DCMLightProfile *)profile
    didReceivePutLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
                      lightId:(NSString*)lightId
                         name:(NSString *)name
                   brightness:(double)brightness
                        color:(NSString*)color
                     flashing:(NSArray*)flashing
{
    [response setErrorToNotSupportAction];
    return YES;
}

// デバイスのライトを消灯させる
- (BOOL) profile:(DCMLightProfile *)profile didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
         lightId:(NSString*) lightId
{
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
}

@end
