//
//  DConnectBatteryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBatteryProfile.h"

// Profile Name
NSString *const DConnectBatteryProfileName = @"battery";

// Atttribute
NSString *const DConnectBatteryProfileAttrCharging         = @"charging";
NSString *const DConnectBatteryProfileAttrChargingTime     = @"chargingTime";
NSString *const DConnectBatteryProfileAttrDischargingTime  = @"dischargingTime";
NSString *const DConnectBatteryProfileAttrLevel            = @"level";
NSString *const DConnectBatteryProfileAttrOnChargingChange = @"onchargingchange";
NSString *const DConnectBatteryProfileAttrOnBatteryChange  = @"onbatterychange";

// Parameter
NSString *const DConnectBatteryProfileParamCharging        = @"charging";
NSString *const DConnectBatteryProfileParamChargingTime    = @"chargingTime";
NSString *const DConnectBatteryProfileParamDischargingTime = @"dischargingTime";
NSString *const DConnectBatteryProfileParamLevel           = @"level";
NSString *const DConnectBatteryProfileParamBattery         = @"battery";


@implementation DConnectBatteryProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectBatteryProfileName;
}

#pragma mark - Setter

+ (void) setLevel:(double)level target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Response must not be nil.";
    } else if (level < 0 || level > 1.0f) {
        @throw @"Level must be between 0 and 1.0.";
    } else {
        [message setFloat:level forKey:DConnectBatteryProfileParamLevel];
    }
    
}

+ (void) setCharging:(BOOL)charging target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Response must not be nil.";
    } else {
        [message setBool:charging forKey:DConnectBatteryProfileParamCharging];
    }
}

+ (void) setChargingTime:(double)chargingTime target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Response must not be nil.";
    } else {
        [message setInteger:chargingTime forKey:DConnectBatteryProfileParamChargingTime];
    }
}

+ (void) setDischargingTime:(double)dischargingTime target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Response must not be nil.";
    } else {
        [message setInteger:dischargingTime forKey:DConnectBatteryProfileParamDischargingTime];
    }
}

+ (void) setBattery:(DConnectMessage *)battery target:(DConnectMessage *)message {
    if (!message) {
        @throw @"Message must not be nil.";
    } else if (!battery) {
        @throw @"Battery must not be nil.";
    } else {
        [message setMessage:battery forKey:DConnectBatteryProfileParamBattery];
    }
}

@end
