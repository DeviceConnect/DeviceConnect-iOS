//
//  DCMStressEstimationProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMStressEstimationProfile.h"

NSString *const DCMStressEstimationProfileName = @"stressEstimation";
NSString *const DCMStressEstimationProfileAttrOnStressEstimation = @"onStressEstimation";
NSString *const DCMStressEstimationProfileParamStress = @"stress";
NSString *const DCMStressEstimationProfileParamLFHF = @"lfhf";
NSString *const DCMStressEstimationProfileParamTimeStamp = @"timeStamp";
NSString *const DCMStressEstimationProfileParamTimeStampString = @"timeStampString";
@interface DCMStressEstimationProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end
@implementation DCMStressEstimationProfile

- (NSString *) profileName {
    return DCMStressEstimationProfileName;
}
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DCMStressEstimationProfileAttrOnStressEstimation]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnStressEstimationRequest:response:serviceId:)
                   response:response]) {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnStressEstimationRequest:request
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
    
    if ([attribute isEqualToString:DCMStressEstimationProfileAttrOnStressEstimation]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnStressEstimationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnStressEstimationRequest:request
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
    
    if ([attribute isEqualToString:DCMStressEstimationProfileAttrOnStressEstimation]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnStressEstimationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnStressEstimationRequest:request response:response
                            serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setStress:(DConnectMessage *)stress target:(DConnectMessage *)message {
    [message setMessage:stress forKey:DCMStressEstimationProfileParamStress];
}
+ (void) setLFHF:(double)lfhf target:(DConnectMessage *)message  {
    [message setDouble:lfhf forKey:DCMStressEstimationProfileParamLFHF];
}

+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMStressEstimationProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMStressEstimationProfileParamTimeStampString];
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
