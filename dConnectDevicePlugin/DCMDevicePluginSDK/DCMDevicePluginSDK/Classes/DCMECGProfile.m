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
NSString *const DCMECGProfileParamECG = @"ecg";
NSString *const DCMECGProfileParamValue = @"value";
NSString *const DCMECGProfileParamMDERFloat = @"mderFloat";
NSString *const DCMECGProfileParamType = @"type";
NSString *const DCMECGProfileParamTypeCode = @"typeCode";
NSString *const DCMECGProfileParamUnit = @"unit";
NSString *const DCMECGProfileParamUnitCode = @"unitCode";
NSString *const DCMECGProfileParamTimeStamp = @"timeStamp";
NSString *const DCMECGProfileParamTimeStampString = @"timeStampString";

@implementation DCMECGProfile

- (NSString *) profileName {
    return DCMECGProfileName;
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
+ (void) setTypeCode:(int)typeCode target:(DConnectMessage *)message {
    [message setInteger:typeCode forKey:DCMECGProfileParamTypeCode];
}
+ (void) setUnit:(NSString*)unit target:(DConnectMessage *)message {
    [message setString:unit forKey:DCMECGProfileParamUnit];
}
+ (void) setUnitCode:(int)unitCode target:(DConnectMessage *)message {
    [message setInteger:unitCode forKey:DCMECGProfileParamUnitCode];
}
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
    [message setLongLong:timeStamp forKey:DCMECGProfileParamTimeStamp];
}
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DCMECGProfileParamTimeStampString];
}


@end
