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

@implementation DCMPoseEstimationProfile

- (NSString *) profileName {
    return DCMPoseEstimationProfileName;
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


@end
