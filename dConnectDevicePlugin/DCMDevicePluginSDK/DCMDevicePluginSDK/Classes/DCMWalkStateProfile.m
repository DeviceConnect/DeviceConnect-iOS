//
//  DCMWalkStateProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMWalkStateProfile.h"

NSString *const DCMWalkStateProfileName = @"walkState";
NSString *const DCMWalkStateProfileAttrOnWalkState = @"onWalkState";
NSString *const DCMWalkStateProfileParamWalk = @"walk";
NSString *const DCMWalkStateProfileParamStep = @"step";
NSString *const DCMWalkStateProfileParamState = @"state";
NSString *const DCMWalkStateProfileParamSpeed = @"speed";
NSString *const DCMWalkStateProfileParamDistance = @"distance";
NSString *const DCMWalkStateProfileParamBalance = @"balance";
NSString *const DCMWalkStateProfileParamTimeStamp = @"timeStamp";
NSString *const DCMWalkStateProfileParamTimeStampString = @"timeStampString";
NSString *const DCMWalkStateProfileStateStop = @"Stop";
NSString *const DCMWalkStateProfileStateWalking = @"Walking";
NSString *const DCMWalkStateProfileStateRunning = @"Running";

@interface DCMWalkStateProfile()
- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;
@end
@implementation DCMWalkStateProfile
- (NSString *) profileName {
    return DCMWalkStateProfileName;
}
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DCMWalkStateProfileAttrOnWalkState]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnWalkStateRequest:response:serviceId:)
                   response:response]) {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnWalkStateRequest:request
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
    
    if ([attribute isEqualToString:DCMWalkStateProfileAttrOnWalkState]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnWalkStateRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnWalkStateRequest:request
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
    
    if ([attribute isEqualToString:DCMWalkStateProfileAttrOnWalkState]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnWalkStateRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnWalkStateRequest:request response:response
                            serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setWalk:(DConnectMessage *)walk target:(DConnectMessage *)message {
    [message setMessage:walk forKey:DCMWalkStateProfileParamWalk];
}
+ (void) setStep:(int)step target:(DConnectMessage *)message {
    [message setInteger:step forKey:DCMWalkStateProfileParamStep];
}
+ (void) setState:(NSString*)state target:(DConnectMessage *)message {
    [message setString:state forKey:DCMWalkStateProfileParamState];
}
+ (void) setSpeed:(double)speed target:(DConnectMessage *)message {
    [message setDouble:speed forKey:DCMWalkStateProfileParamSpeed];
}
+ (void) setDistance:(double)distance target:(DConnectMessage *)message {
    [message setDouble:distance forKey:DCMWalkStateProfileParamDistance];
}
+ (void) setBalance:(double)balance target:(DConnectMessage *)message {
    [message setDouble:balance forKey:DCMWalkStateProfileParamBalance];
}
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMWalkStateProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMWalkStateProfileParamTimeStampString];
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
