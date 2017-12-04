//
//  DPHostLightProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AVFoundation/AVFoundation.h>
#import "DPHostDevicePlugin.h"
#import "DPHostLightProfile.h"
#import "DPHostDeviceRepeatExecutor.h"
#import "DPHostRecorderUtils.h"

@implementation DPHostLightProfile {
    DPHostDeviceRepeatExecutor *_flashingExecutor;
}

// 初期化
- (instancetype)init {
    self = [super init];
    __weak DPHostLightProfile *weakSelf = self;

    // GET /gotapi/light/
    [self addGetPath:@"/" api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        NSString *serviceId = [request serviceId];
        if (!serviceId) {
            [response setErrorToEmptyServiceId];
            return YES;
        }
        
        DConnectArray *lights = [DConnectArray array];
        DConnectMessage *light = [DConnectMessage new];
        [response setResult:DConnectMessageResultTypeOk];

        // ライト情報取得
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [captureDevice lockForConfiguration:NULL];
        if (captureDevice.torchMode == AVCaptureTorchModeOn) {
            [DConnectLightProfile setLightOn:YES target:light];
            
        } else {
            [DConnectLightProfile setLightOn:NO target:light];
        }
        [captureDevice unlockForConfiguration];

        [DConnectLightProfile setLightId:@"1" target:light];
        [DConnectLightProfile setLightName:@"Host Light" target:light];
        [DConnectLightProfile setLightConfig:@"" target:light];

        [lights addMessage:light];
        [DConnectLightProfile setLights:lights target:response];
        return YES;
    }];

    // POST /gotapi/light/
    [self addPostPath:@"/" api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        NSString *serviceId = [request serviceId];
        NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];
        NSNumber *brightness = [DConnectLightProfile brightnessFromRequest: request];
        NSString *color = [DConnectLightProfile colorFromRequest: request];
        NSArray *flashing = [DConnectLightProfile parsePattern: [DConnectLightProfile flashingFromRequest: request] isId:NO];

        if (!flashing) {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"Parameter 'flashing' invalid."];
            return YES;
        }

        if (![weakSelf checkFlash:response flashing:flashing]) {
            return YES;
        }

        if (!serviceId) {
            [response setErrorToEmptyServiceId];
            return YES;
        }

        if (lightId && ![lightId isEqualToString:@"1"]) {
            [response setErrorToInvalidRequestParameterWithMessage:@"Invalid lightId"];
            return YES;
        }

        int myBlightness;
        NSString *uicolor;
        unsigned int redValue = 0, greenValue = 0, blueValue = 0;
        [weakSelf checkColor:[brightness doubleValue] blueValue:blueValue greenValue:greenValue
                    redValue:redValue color:color myBlightnessPointer:&myBlightness uicolorPointer:&uicolor];

        if (!uicolor && color) {
            [response setErrorToInvalidRequestParameterWithMessage:@"Invalid Color String"];
            return YES;
        }

        if (flashing.count > 0) {
            // 点滅処理
            _flashingExecutor = [[DPHostDeviceRepeatExecutor alloc] initWithPattern:flashing on:^{
                [DPHostRecorderUtils setLightOnOff:YES];
            } off:^{
                [DPHostRecorderUtils setLightOnOff:NO];
            }];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            // 点灯処理
            [DPHostRecorderUtils setLightOnOff:YES];
            [response setResult:DConnectMessageResultTypeOk];
        }

        return YES;
    }];

    // DELETE /gotapi/light/
    [self addDeletePath:@"/" api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        NSString *serviceId = [request serviceId];
        NSString *lightId = [DConnectLightProfile lightIdFromRequest: request];

        if (!serviceId) {
            [response setErrorToEmptyServiceId];
            return YES;
        }

        if (lightId && ![lightId isEqualToString:@"1"]) {
            [response setErrorToInvalidRequestParameterWithMessage:@"Invalid lightId"];
            return YES;
        }

        // 消灯処理
        [DPHostRecorderUtils setLightOnOff:NO];
        [response setResult:DConnectMessageResultTypeOk];

        return YES;
    }];

    return self;
}

#pragma mark - private method

- (void)checkColor:(double)dBlightness blueValue:(unsigned int)blueValue greenValue:(unsigned int)greenValue redValue:(unsigned int)redValue color:(NSString *)color myBlightnessPointer:(int *)myBlightnessPointer uicolorPointer:(NSString **)uicolorPointer
{
    NSScanner *scan;
    NSString *blueString;
    NSString *greenString;
    NSString *redString;
    if (color) {
        if (color.length != 6) {
            return;
        }

        redString = [color substringWithRange:NSMakeRange(0, 2)];
        greenString = [color substringWithRange:NSMakeRange(2, 2)];
        blueString = [color substringWithRange:NSMakeRange(4, 2)];
        scan = [NSScanner scannerWithString:redString];
        if (![scan scanHexInt:&redValue]) {
            return;
        }
        scan = [NSScanner scannerWithString:greenString];
        if (![scan scanHexInt:&greenValue]) {
            return;
        }
        scan = [NSScanner scannerWithString:blueString];
        if (![scan scanHexInt:&blueValue]) {
            return;
        }

        redValue = (unsigned int)round(redValue * dBlightness);
        greenValue = (unsigned int)round(greenValue * dBlightness);
        blueValue = (unsigned int)round(blueValue * dBlightness);
    }else{
        redValue = (unsigned int)round(255 * dBlightness);
        greenValue = (unsigned int)round(255 * dBlightness);
        blueValue = (unsigned int)round(255 * dBlightness);
    }

    *myBlightnessPointer = MAX(redValue, greenValue);
    *myBlightnessPointer = MAX(*myBlightnessPointer, blueValue);
    *uicolorPointer = [NSString stringWithFormat:@"%02X%02X%02X",redValue, greenValue, blueValue];
}
@end
