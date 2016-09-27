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

@implementation DCMWalkStateProfile
- (NSString *) profileName {
    return DCMWalkStateProfileName;
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


@end
