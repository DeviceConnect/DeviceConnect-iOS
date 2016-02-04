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

@interface DPIRKitLightProfile()
@property (nonatomic, weak) DPIRKitDevicePlugin *plugin;


@end

@implementation DPIRKitLightProfile
// 初期化
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin
{
    self = [super init];
    if (self) {
        self.plugin = plugin;
        self.delegate = self;
    }
    return self;
    
}


- (BOOL)              profile:(DConnectLightProfile *)profile
    didReceiveGetLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
{
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
    [virtualLight setString:@"1" forKey:DConnectLightProfileParamLightId];
    [virtualLight setString:@"照明" forKey:DConnectLightProfileParamName];
    
    [virtualLight setBool:NO forKey:DConnectLightProfileParamOn];
    [virtualLight setString:@"" forKey:DConnectLightProfileParamConfig];
    [lights addMessage:virtualLight];
    
    [response setArray:lights forKey:DConnectLightProfileParamLights];
    return YES;
}



- (BOOL)            profile:(DConnectLightProfile *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                 brightness:(NSNumber*)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing
{
    int myBlightness;
    NSString *uicolor;
    unsigned int redValue, greenValue, blueValue;
    [self checkColor:[brightness doubleValue] blueValue:blueValue greenValue:greenValue
            redValue:redValue color:color myBlightnessPointer:&myBlightness uicolorPointer:&uicolor];
    
    if (!uicolor && color) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Invalid Color String"];
        return YES;
    }
    return [self sendLightIRRequestWithServiceId:serviceId
                                         lightId:lightId
                                          method:@"POST"
                                         request:request
                                        response:response];

}


- (BOOL)                 profile:(DConnectLightProfile *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                         lightId:(NSString*)lightId
{
    return [self sendLightIRRequestWithServiceId:serviceId
                                         lightId:lightId
                                          method:@"DELETE"
                                         request:request
                                        response:response];
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
            send = [_plugin sendIRWithServiceId:serviceId message:req.ir response:response];
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
