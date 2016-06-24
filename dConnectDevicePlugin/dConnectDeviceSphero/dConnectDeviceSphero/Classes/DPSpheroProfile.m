//
//  DPSpheroProfile.m
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroProfile.h"
#import <DConnectSDK/DConnectUtil.h>


/*
 Profileの名前
 */
NSString *const DPSpheroProfileName = @"sphero";

/*
 インタフェース: sphero
 */
NSString *const DPSpheroProfileInterfaceQuaternion = @"quaternion";
NSString *const DPSpheroProfileInterfaceLocator = @"locator";
NSString *const DPSpheroProfileInterfaceCollision = @"collision";


/*
 アトリビュート: sphero
 */

NSString *const DPSpheroProfileAttrOnQuaternion = @"onquaternion";
NSString *const DPSpheroProfileAttrOnLocator = @"onlocator";
NSString *const DPSpheroProfileAttrOnCollision = @"oncollision";

/*
 パラメータ: sphero
 */
NSString *const DPSpheroProfileParamQuaternion = @"quaternion";
NSString *const DPSpheroProfileParamQ0 = @"q0";
NSString *const DPSpheroProfileParamQ1 = @"q1";
NSString *const DPSpheroProfileParamQ2 = @"q2";
NSString *const DPSpheroProfileParamQ3 = @"q3";
NSString *const DPSpheroProfileParamInterval = @"interval";
NSString *const DPSpheroProfileParamFlag = @"flag";
NSString *const DPSpheroProfileParamNewX = @"newX";
NSString *const DPSpheroProfileParamNewY = @"newY";
NSString *const DPSpheroProfileParamNewCalibration = @"newCalibration";
NSString *const DPSpheroProfileParamLocator = @"locator";
NSString *const DPSpheroProfileParamPositionX = @"positionX";
NSString *const DPSpheroProfileParamPositionY = @"positionY";
NSString *const DPSpheroProfileParamVelocityX = @"velocityX";
NSString *const DPSpheroProfileParamVelocityY = @"velocityY";
NSString *const DPSpheroProfileParamXThreshold = @"xThreshold";
NSString *const DPSpheroProfileParamYThreshold = @"yThreshold";
NSString *const DPSpheroProfileParamXSpeedThreshold = @"xSpeedThreshold";
NSString *const DPSpheroProfileParamYSpeedThreshold = @"ySpeedThreshold";
NSString *const DPSpheroProfileParamDeadZone = @"deadZone";
NSString *const DPSpheroProfileParamCollision = @"collision";
NSString *const DPSpheroProfileParamImpactAcceleration = @"impactAcceleration";
NSString *const DPSpheroProfileParamX = @"x";
NSString *const DPSpheroProfileParamY = @"y";
NSString *const DPSpheroProfileParamZ = @"z";
NSString *const DPSpheroProfileParamImpactAxis = @"impactAxis";
NSString *const DPSpheroProfileParamImpactPower = @"impactPower";
NSString *const DPSpheroProfileParamImpactSpeed = @"impactSpeed";
NSString *const DPSpheroProfileParamImpactTimestamp = @"impactTimestamp";


@interface DPSpheroProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end


@implementation DPSpheroProfile

/*
 このプロファイルの名前を返す。
 */
- (NSString *) profileName {
    return DPSpheroProfileName;
}

#pragma mark - DConnectProfile Method

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
    
    if (profile && interface && attribute) {
        //Quaternion
        if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceQuaternion]
            && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnQuaternion]
            && [self hasMethod:
                @selector(profile:
                          didReceiveGetOnQuaternionRequest:
                          response:serviceId:)
                      response:response])
        {
            send = [_delegate                    profile:self
                        didReceiveGetOnQuaternionRequest:request
                                                response:response
                                               serviceId:serviceId];
            //Locator
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceLocator]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnLocator]
                   && [self hasMethod:
                       @selector(profile:
                                 didReceiveGetOnLocatorRequest:
                                 response:serviceId:)
                             response:response])
        {
            send = [_delegate             profile:self
                    didReceiveGetOnLocatorRequest:request
                                         response:response
                                        serviceId:serviceId];
            //Collision
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceCollision]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnCollision]
                   && [self hasMethod:
                       @selector(profile:
                                 didReceiveGetOnCollisionRequest:
                                 response:
                                 serviceId:)
                             response:response])
        {
            send = [_delegate               profile:self
                    didReceiveGetOnCollisionRequest:request
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
    NSString *sessionKey = [request sessionKey];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile && interface && attribute) {
        //Quaternion
        if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceQuaternion]
            && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnQuaternion]
            && [self hasMethod:
                @selector(profile:
                          didReceivePutOnQuaternionRequest:
                          response:serviceId:
                          sessionKey:)
                      response:response])
        {
            send = [_delegate                    profile:self
                        didReceivePutOnQuaternionRequest:request
                                                response:response
                                               serviceId:serviceId
                                              sessionKey:sessionKey];
        //Locator
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceLocator]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnLocator]
                   && [self hasMethod:
                                @selector(profile:
                                          didReceivePutOnLocatorRequest:
                                          response:serviceId:
                                          sessionKey:)
                             response:response])
        {
            send = [_delegate             profile:self
                    didReceivePutOnLocatorRequest:request
                                         response:response
                                        serviceId:serviceId
                                       sessionKey:sessionKey ];
        //Collision
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceCollision]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnCollision]
                   && [self hasMethod:
                            @selector(profile:
                                      didReceivePutOnCollisionRequest:
                                      response:
                                      serviceId:
                                      sessionKey:)
                             response:response])
        {
            send = [_delegate               profile:self
                    didReceivePutOnCollisionRequest:request
                                           response:response
                                          serviceId:serviceId
                                         sessionKey:sessionKey];
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
    NSString *sessionKey = [request sessionKey];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile && interface && attribute) {
        // Quaternion
        if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceQuaternion]
            && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnQuaternion]
            && [self hasMethod:
                        @selector(profile:
                                didReceiveDeleteOnQuaternionRequest:
                                  response:
                                  serviceId:
                                  sessionKey:)
                      response:response])
        {
            send = [_delegate                   profile:self
                    didReceiveDeleteOnQuaternionRequest:request
                                               response:response
                                              serviceId:serviceId
                                             sessionKey:sessionKey];
        //Locator
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceLocator]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnLocator]
                   && [self hasMethod:
                                @selector(profile:
                                          didReceiveDeleteOnLocatorRequest:
                                          response:
                                          serviceId:
                                          sessionKey:)
                             response:response])
        {
            send = [_delegate                profile:self
                    didReceiveDeleteOnLocatorRequest:request
                                            response:response
                                           serviceId:serviceId
                                          sessionKey:sessionKey];
        //Collision
        } else if ([self isEqualToInterface: interface cmp:DPSpheroProfileInterfaceCollision]
                   && [self isEqualToAttribute: attribute cmp:DPSpheroProfileAttrOnCollision]
                   && [self hasMethod:
                            @selector(profile:
                                      didReceiveDeleteOnCollisionRequest:
                                      response:
                                      serviceId:
                                      sessionKey:)
                             response:response])
        {
            send = [_delegate                  profile:self
                    didReceiveDeleteOnCollisionRequest:request
                                              response:response
                                             serviceId:serviceId
                                            sessionKey:sessionKey];
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
