//
//  DCMPoseEstimationProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMPoseEstimationProfile.h"

NSString *const DCMPoseEstimationProfileName = @"poseEstimation";
NSString *const DCMPoseEstimationProfileAttrOnPoseEstimation = @"onPoseEstimation";
NSString *const DCMPoseEstimationProfileParamPose = @"pose";
NSString *const DCMPoseEstimationProfileParamState = @"state";
NSString *const DCMPoseEstimationProfileParamTimeStamp = @"timeStamp";
NSString *const DCMPoseEstimationProfileParamTimeStampString = @"timeStampString";
NSString *const DCMPoseEstimationProfileStateForward = @"Forward";
NSString *const DCMPoseEstimationProfileStateBackward = @"Backward";
NSString *const DCMPoseEstimationProfileStateRightside = @"Rightside";
NSString *const DCMPoseEstimationProfileStateLeftside = @"Leftside";
NSString *const DCMPoseEstimationProfileStateFaceUp = @"FaceUp";
NSString *const DCMPoseEstimationProfileStateFaceLeft = @"FaceLeft";
NSString *const DCMPoseEstimationProfileStateFaceDown = @"FaceDown";
NSString *const DCMPoseEstimationProfileStateFaceRight = @"FaceRight";
NSString *const DCMPoseEstimationProfileStateStanding = @"Standing";
@interface DCMPoseEstimationProfile()
- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;
@end

@implementation DCMPoseEstimationProfile

- (NSString *) profileName {
    return DCMPoseEstimationProfileName;
}
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([attribute isEqualToString:DCMPoseEstimationProfileAttrOnPoseEstimation]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnPoseEstimationRequest:response:serviceId:)
                   response:response]) {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnPoseEstimationRequest:request
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
    
    if ([attribute isEqualToString:DCMPoseEstimationProfileAttrOnPoseEstimation]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnPoseEstimationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnPoseEstimationRequest:request
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
    
    if ([attribute isEqualToString:DCMPoseEstimationProfileAttrOnPoseEstimation]) {
        
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnPoseEstimationRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnPoseEstimationRequest:request response:response
                            serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setPose:(DConnectMessage *)pose target:(DConnectMessage *)message {
    [message setMessage:pose forKey:DCMPoseEstimationProfileParamPose];
}
+ (void) setState:(NSString*)state target:(DConnectMessage *)message  {
    [message setString:state forKey:DCMPoseEstimationProfileParamState];
}

+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMPoseEstimationProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMPoseEstimationProfileParamTimeStampString];
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
