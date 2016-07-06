//
//  DCMECGProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DCMECGProfile.h"

NSString *const DCMECGProfileName = @"ecg";
NSString *const DCMECGProfileAttrOnECG = @"onECG";
NSString *const DCMECGProfileParamECG = @"ECG";
NSString *const DCMECGProfileParamValue = @"value";
NSString *const DCMECGProfileParamMDERFloat = @"mderFloat";
NSString *const DCMECGProfileParamType = @"type";
NSString *const DCMECGProfileParamTypeCode = @"typeCode";
NSString *const DCMECGProfileParamUnit = @"unit";
NSString *const DCMECGProfileParamUnitCode = @"unitCode";
NSString *const DCMECGProfileParamTimeStamp = @"timeStamp";
NSString *const DCMECGProfileParamTimeStampString = @"timeStampString";

@interface DCMECGProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end
@implementation DCMECGProfile

- (NSString *) profileName {
    return DCMECGProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DCMECGProfileAttrOnECG]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnECGRequest:response:serviceId:)
                   response:response]) {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnECGRequest:request
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
    
    if ([attribute isEqualToString:DCMECGProfileAttrOnECG]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnECGRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnECGRequest:request
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
    
    if ([attribute isEqualToString:DCMECGProfileAttrOnECG]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnECGRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnECGRequest:request response:response
                            serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}


#pragma mark - Setter
+ (void) setECG:(DConnectMessage *)ecg target:(DConnectMessage *)message {
    [message setMessage:ecg forKey:DCMECGProfileParamECG];
}
+ (void) setValue:(double)value target:(DConnectMessage *)message {
    [message setDouble:value forKey:DCMECGProfileParamValue];
}
+ (void) setMDERFloat:(NSString*)mderFloat target:(DConnectMessage *)message {
    [message setString:mderFloat forKey:DCMECGProfileParamMDERFloat];
}
+ (void) setType:(NSString*)type target:(DConnectMessage *)message {
    [message setString:type forKey:DCMECGProfileParamType];
}
+ (void) setTypeCode:(NSString*)typeCode target:(DConnectMessage *)message {
    [message setString:typeCode forKey:DCMECGProfileParamTypeCode];
}
+ (void) setUnit:(NSString*)unit target:(DConnectMessage *)message {
    [message setString:unit forKey:DCMECGProfileParamUnit];
}
+ (void) setUnitCode:(NSString*)unitCode target:(DConnectMessage *)message {
    [message setString:unitCode forKey:DCMECGProfileParamUnitCode];
}
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMECGProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMECGProfileParamTimeStampString];
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
