//
//  DPIRKitLightProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitLightProfile.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitManager.h"
#import "DPIRKitVirtualDevice.h"
#import "DPIRKitRESTfulRequest.h"

@implementation DPIRKitLightProfile
// 初期化
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin
{
    self = [super init];
    if (self) {
        self.plugin = plugin;
        
        __weak DPIRKitLightProfile *weakSelf = self;
        
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

                         NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                                       profile:@"/light"];
                         if (requests.count == 0) {
                             [response setErrorToNotSupportProfile];
                             return YES;
                         }
                         
                         DConnectArray *lights = [DConnectArray array];
                         DConnectMessage *virtualLight = [DConnectMessage new];
                         
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         //全体の色を変えるためのID
                         [DConnectLightProfile setLightId:@"1" target:virtualLight];
                         [DConnectLightProfile setLightName:@"照明" target:virtualLight];
                         [DConnectLightProfile setLightOn:NO target:virtualLight];
                         [DConnectLightProfile setLightConfig:@"" target:virtualLight];
                         
                         [lights addMessage:virtualLight];
                         
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

                          int myBlightness;
                          NSString *uicolor;
                          unsigned int redValue, greenValue, blueValue;
                          [weakSelf checkColor:[brightness doubleValue] blueValue:blueValue greenValue:greenValue
                                  redValue:redValue color:color myBlightnessPointer:&myBlightness uicolorPointer:&uicolor];
                          
                          if (!uicolor && color) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"Invalid Color String"];
                              return YES;
                          }
                          return [weakSelf sendLightIRRequestWithServiceId:serviceId
                                                                   lightId:lightId
                                                                    method:@"POST"
                                                                   request:request
                                                                  response:response];
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
                            
                            return [weakSelf sendLightIRRequestWithServiceId:serviceId
                                                                     lightId:lightId
                                                                      method:@"DELETE"
                                                                     request:request
                                                                    response:response];
                            
                        }];
    }
    return self;
    
}

#pragma mark - private method

- (BOOL)sendLightIRRequestWithServiceId:(NSString *)serviceId
                                lightId:(NSString *)lightId
                                 method:(NSString *)method
                                request:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
{
    BOOL send = YES;
    NSArray *requests = [[DPIRKitDBManager sharedInstance] queryRESTfulRequestByServiceId:serviceId
                                                                                  profile:@"/light"];
    if (requests.count == 0) {
        [response setErrorToNotSupportProfile];
        return send;
    }
    if (!lightId || (lightId && ![lightId isEqualToString:@"1"])) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Invalid lightId"];
        return send;
    }

    for (DPIRKitRESTfulRequest *req in requests) {
        NSString *uri = [NSString stringWithFormat:@"/%@",[request profile]];
        if ([req.uri isEqualToString:uri] && [req.method isEqualToString:method]
            && req.ir) {
            send = [self.plugin sendIRWithServiceId:serviceId message:req.ir response:response];
        } else {
            [response setErrorToInvalidRequestParameterWithMessage:@"IR is not registered for that request"];
        }
    }
    return send;
}

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
