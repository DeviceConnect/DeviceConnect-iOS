//
//  DCMDriveControllerProfileName.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMDriveControllerProfile.h"
#import <DConnectSDK/DConnectUtil.h>

NSString *const DCMDriveControllerProfileName = @"driveController";

NSString *const DCMDriveControllerProfileAttrMove = @"move";
NSString *const DCMDriveControllerProfileAttrStop = @"stop";
NSString *const DCMDriveControllerProfileAttrRotate = @"rotate";
NSString *const DCMDriveControllerProfileParamAngle = @"angle";
NSString *const DCMDriveControllerProfileParamSpeed = @"speed";

@interface DCMDriveControllerProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end


@implementation DCMDriveControllerProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMDriveControllerProfileName;
}

#pragma mark - DConnectProfile Method

/*
 POSTリクエストを振り分ける。
 */
- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([self isEqualToProfile:profile cmp:DCMDriveControllerProfileName]
            && attribute != nil
            && [self isEqualToAttribute:attribute cmp:DCMDriveControllerProfileAttrMove]
            && [self hasMethod:@selector(profile:
                                         didReceivePostDriveControllerMoveRequest:
                                         response:
                                         serviceId:
                                         angle:
                                         speed:)
                      response:response])
        {
            double angle = [request doubleForKey:DCMDriveControllerProfileParamAngle];
            double speed = [request doubleForKey:DCMDriveControllerProfileParamSpeed];
            send = [_delegate                profile:self
            didReceivePostDriveControllerMoveRequest:request
                                            response:response
                                           serviceId:serviceId
                                               angle:angle
                                               speed:speed];

        } else {
            [response setErrorToNotSupportAttribute];
        }

    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 PUTリクエストを振り分ける
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
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([self isEqualToProfile:profile cmp: DCMDriveControllerProfileName]
            && attribute != nil
            && [self isEqualToAttribute:attribute cmp:DCMDriveControllerProfileAttrRotate]
            && [self hasMethod:@selector(profile:
                                         didReceivePutDriveControllerRotateRequest:
                                         response:
                                         serviceId:
                                         angle:)
                      response:response])
        {
            double angle = [request doubleForKey:DCMDriveControllerProfileParamAngle];
            send = [_delegate                 profile:self
            didReceivePutDriveControllerRotateRequest:request
                                             response:response
                                            serviceId:serviceId
                                                angle:angle];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 DELETEリクエストを振り分ける。
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
    NSString *attribute = [request attribute];

    if (profile) {
        if ([self isEqualToProfile:profile cmp:DCMDriveControllerProfileName]
            && attribute != nil
            && [self isEqualToAttribute: attribute cmp:DCMDriveControllerProfileAttrStop]
            && [self hasMethod:@selector(profile:
                                         didReceiveDeleteDriveControllerStopRequest:
                                         response:
                                         serviceId:)
                      response:response])
        {
            
            send = [_delegate             profile:self
       didReceiveDeleteDriveControllerStopRequest:request
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

#pragma mark - Private Methods


/*
 メソッドが存在するかを確認する。
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
