//
//  DConnectProximityProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProximityProfile.h"

NSString *const DConnectProximityProfileName = @"proximity";
NSString *const DConnectProximityProfileAttrOnDeviceProximity = @"ondeviceproximity";
NSString *const DConnectProximityProfileAttrOnUserProximity = @"onuserproximity";
NSString *const DConnectProximityProfileParamValue = @"value";
NSString *const DConnectProximityProfileParamMin = @"min";
NSString *const DConnectProximityProfileParamMax = @"max";
NSString *const DConnectProximityProfileParamThreshold = @"threshold";
NSString *const DConnectProximityProfileParamProximity = @"proximity";
NSString *const DConnectProximityProfileParamNear = @"near";

@interface DConnectProximityProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectProximityProfile

- (NSString *) profileName {
    return DConnectProximityProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnDeviceProximity]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnDeviceProximityRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveGetOnDeviceProximityRequest:request response:response
                            serviceId:serviceId];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnUserProximity]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnUserProximityRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveGetOnUserProximityRequest:request response:response
                            serviceId:serviceId];
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
    NSString *serviceId = [request serviceId];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnDeviceProximity]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnDeviceProximityRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnDeviceProximityRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnUserProximity]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnUserProximityRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnUserProximityRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
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
    NSString *serviceId = [request serviceId];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnDeviceProximity]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnDeviceProximityRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnDeviceProximityRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectProximityProfileAttrOnUserProximity]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnUserProximityRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnUserProximityRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    
    return send;
}

#pragma mark - Setter

+ (void) setValue:(double)value target:(DConnectMessage *)message {
    [message setDouble:value forKey:DConnectProximityProfileParamValue];
}

+ (void) setMin:(double)min target:(DConnectMessage *)message {
    [message setDouble:min forKey:DConnectProximityProfileParamMin];
}

+ (void) setMax:(double)max target:(DConnectMessage *)message {
    [message setDouble:max forKey:DConnectProximityProfileParamMax];
}

+ (void) setThreshold:(double)threshold target:(DConnectMessage *)message {
    [message setDouble:threshold forKey:DConnectProximityProfileParamThreshold];
}

+ (void) setProximity:(DConnectMessage *)proximity target:(DConnectMessage *)message {
    [message setMessage:proximity forKey:DConnectProximityProfileParamProximity];
}

+ (void) setNear:(BOOL)near target:(DConnectMessage *)message {
    [message setBool:near forKey:DConnectProximityProfileParamNear];
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
