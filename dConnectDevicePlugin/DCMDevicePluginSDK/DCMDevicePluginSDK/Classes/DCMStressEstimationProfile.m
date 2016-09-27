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

@implementation DCMStressEstimationProfile

- (NSString *) profileName {
    return DCMStressEstimationProfileName;
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

@end
