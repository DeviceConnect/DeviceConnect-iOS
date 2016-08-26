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
NSString *const DConnectProximityProfileParamRange = @"range";

NSString *const DConnectProximityProfileRangeImmediate = @"IMMEDIATE";
NSString *const DConnectProximityProfileRangeNear = @"NEAR";
NSString *const DConnectProximityProfileRangeFar = @"FAR";
NSString *const DConnectProximityProfileRangeUnknown = @"UNKNOWN";

@interface DConnectProximityProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectProximityProfile

- (NSString *) profileName {
    return DConnectProximityProfileName;
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

+ (void) setRange:(NSString *)range target:(DConnectMessage *)message {
    [message setString:range forKey:DConnectProximityProfileParamRange];
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
