//
//  DPOmnidirectionalImageProfile.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/23.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPOmnidirectionalImageProfile.h"

NSString *const DPOmnidirectionalImageProfileName = @"omnidirectional_image";


NSString *const DPOmnidirectionalImageProfileInterfaceROI = @"roi";
NSString *const DPOmnidirectionalImageProfileAttrROI = @"roi";
NSString *const DPOmnidirectionalImageProfileAttrSettings = @"settings";
NSString *const DPOmnidirectionalImageProfileParamSource = @"source";
NSString *const DPOmnidirectionalImageProfileParamX = @"x";
NSString *const DPOmnidirectionalImageProfileParamY = @"y";
NSString *const DPOmnidirectionalImageProfileParamZ = @"z";
NSString *const DPOmnidirectionalImageProfileParamRoll = @"roll";
NSString *const DPOmnidirectionalImageProfileParamPitch = @"pitch";
NSString *const DPOmnidirectionalImageProfileParamYaw = @"yaw";
NSString *const DPOmnidirectionalImageProfileParamFOV = @"fov";
NSString *const DPOmnidirectionalImageProfileParamSphereSize = @"sphereSize";
NSString *const DPOmnidirectionalImageProfileParamWidth = @"width";
NSString *const DPOmnidirectionalImageProfileParamHeight = @"height";
NSString *const DPOmnidirectionalImageProfileParamStereo = @"stereo";
NSString *const DPOmnidirectionalImageProfileParamVR = @"vr";
NSString *const DPOmnidirectionalImageProfileParamURI = @"uri";




@implementation DPOmnidirectionalImageProfile

- (NSString *) profileName {
    return DPOmnidirectionalImageProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *source = [request stringForKey:DPOmnidirectionalImageProfileParamSource];
    
    if (profile) {
        if (!interface
            && [attribute isEqualToString:DPOmnidirectionalImageProfileAttrROI]
            && [self hasMethod:
                @selector(profile:
                          didReceiveGetRoiRequest:response:serviceId:source:)
                      response:response])
        {
            send = [_delegate           profile:self
                        didReceiveGetRoiRequest:request
                                       response:response
                                      serviceId:serviceId
                                         source:source];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 PUTリクエストを受け付ける。
 */
- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *source = [request stringForKey:DPOmnidirectionalImageProfileParamSource];
    
    if (profile) {
        if (!interface
            && [attribute isEqualToString:DPOmnidirectionalImageProfileAttrROI]
            && [self hasMethod:
                @selector(profile:
                          didReceivePutRoiRequest:response:serviceId:source:)
                      response:response])
        {
            send = [_delegate       profile:self
                    didReceivePutRoiRequest:request
                                   response:response
                                  serviceId:serviceId
                                     source:source];

        } else if ([interface isEqualToString:DPOmnidirectionalImageProfileInterfaceROI]
            && [attribute isEqualToString:DPOmnidirectionalImageProfileAttrSettings]
            && [self hasMethod:
                @selector(profile:
                          didReceivePutRoiSettingsRequest:response:serviceId:)
                      response:response])
        {
            send = [_delegate                    profile:self
                        didReceivePutRoiSettingsRequest:request
                                                response:response
                                               serviceId:serviceId];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}


/**
 DELETEリクエストを受け付ける。
 */
- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *uri = [request stringForKey:DPOmnidirectionalImageProfileParamURI];
    
    if (profile) {
        if (!interface
            && [attribute isEqualToString:DPOmnidirectionalImageProfileAttrROI]
            && [self hasMethod:
                @selector(profile:
                          didReceiveDeleteRoiRequest:response:serviceId:uri:)
                      response:response])
        {
            send = [_delegate          profile:self
                    didReceiveDeleteRoiRequest:request
                                      response:response
                                     serviceId:serviceId
                                           uri:uri];

        } else {
            [response setErrorToNotSupportAttribute];
        }
        
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}



#pragma mark - Private Methods

/*
 メソッドがあるかどうかを確認する。
 */
- (BOOL) hasMethod:(SEL)method
          response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}
@end
