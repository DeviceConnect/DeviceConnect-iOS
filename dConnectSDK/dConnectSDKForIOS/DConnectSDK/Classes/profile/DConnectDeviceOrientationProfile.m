//
//  DConnectDeviceOrientationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDeviceOrientationProfile.h"

NSString *const DConnectDeviceOrientationProfileName = @"deviceOrientation";
NSString *const DConnectDeviceOrientationProfileAttrOnDeviceOrientation = @"ondeviceorientation";
NSString *const DConnectDeviceOrientationProfileParamOrientation = @"orientation";
NSString *const DConnectDeviceOrientationProfileParamAcceleration = @"acceleration";
NSString *const DConnectDeviceOrientationProfileParamX = @"x";
NSString *const DConnectDeviceOrientationProfileParamY = @"y";
NSString *const DConnectDeviceOrientationProfileParamZ = @"z";
NSString *const DConnectDeviceOrientationProfileParamRotationRate = @"rotationRate";
NSString *const DConnectDeviceOrientationProfileParamAlpha = @"alpha";
NSString *const DConnectDeviceOrientationProfileParamBeta = @"beta";
NSString *const DConnectDeviceOrientationProfileParamGamma = @"gamma";
NSString *const DConnectDeviceOrientationProfileParamInterval = @"interval";
NSString *const DConnectDeviceOrientationProfileParamAccelerationIncludingGravity = @"accelerationIncludingGravity";

@interface DConnectDeviceOrientationProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectDeviceOrientationProfile

- (NSString *) profileName {
    return DConnectDeviceOrientationProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectDeviceOrientationProfileAttrOnDeviceOrientation]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnDeviceOrientationRequest:response:serviceId:)
                   response:response]) {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnDeviceOrientationRequest:request
                             response:response serviceId:serviceId];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectDeviceOrientationProfileAttrOnDeviceOrientation]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnDeviceOrientationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnDeviceOrientationRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {

    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }

    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectDeviceOrientationProfileAttrOnDeviceOrientation]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnDeviceOrientationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnDeviceOrientationRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }

    return send;
}

#pragma mark - Setter
+ (void) setInterval:(long long)interval target:(DConnectMessage *)message {
    [message setLongLong:interval forKey:DConnectDeviceOrientationProfileParamInterval];
}

+ (void) setOrientation:(DConnectMessage *)orientation target:(DConnectMessage *)message {
    [message setMessage:orientation forKey:DConnectDeviceOrientationProfileParamOrientation];
}

+ (void) setAcceleration:(DConnectMessage *)acceleration target:(DConnectMessage *)message {
    [message setMessage:acceleration forKey:DConnectDeviceOrientationProfileParamAcceleration];
}

+ (void) setAccelerationIncludingGravity:(DConnectMessage *)accelerationIncludingGravity target:(DConnectMessage *)message
{
    [message setMessage:accelerationIncludingGravity forKey:DConnectDeviceOrientationProfileParamAccelerationIncludingGravity];
}

+ (void) setRotationRate:(DConnectMessage *)rotationRate target:(DConnectMessage *)message {
    [message setMessage:rotationRate forKey:DConnectDeviceOrientationProfileParamRotationRate];
}

+ (void) setX:(double)x target:(DConnectMessage *)message {
    [message setDouble:x forKey:DConnectDeviceOrientationProfileParamX];
}

+ (void) setY:(double)y target:(DConnectMessage *)message {
    [message setDouble:y forKey:DConnectDeviceOrientationProfileParamY];
}

+ (void) setZ:(double)z target:(DConnectMessage *)message {
    [message setDouble:z forKey:DConnectDeviceOrientationProfileParamZ];
}

+ (void) setAlpha:(double)alpha target:(DConnectMessage *)message {
    [message setDouble:alpha forKey:DConnectDeviceOrientationProfileParamAlpha];
}

+ (void) setBeta:(double)beta target:(DConnectMessage *)message {
    [message setDouble:beta forKey:DConnectDeviceOrientationProfileParamBeta];
}

+ (void) setGamma:(double)gamma target:(DConnectMessage *)message {
    [message setDouble:gamma forKey:DConnectDeviceOrientationProfileParamGamma];
}

#pragma mark - Private Methods
- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
