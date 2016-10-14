//
//  DCMTemperatureProfileName.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMTemperatureProfile.h"
#import "DCMUtil.h"

NSString *const DCMTemperatureProfileName = @"temperature";
NSString *const DCMTemperatureProfileParamTemperature = @"temperature";
NSString *const DCMTemperatureProfileParamType = @"type";
NSString *const DCMTemperatureProfileParamTimeStamp = @"timeStamp";
NSString *const DCMTemperatureProfileParamTimeStampString = @"timeStampString";

@implementation DCMTemperatureProfile

- (NSString *) profileName {
    return DCMTemperatureProfileName;
}

+ (void) setTemperature:(float)temperature target:(DConnectMessage *)message {
    [message setFloat:temperature forKey:DCMTemperatureProfileParamTemperature];
}

+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message {
    [message setLong:timeStamp forKey:DCMTemperatureProfileParamTimeStamp];
    [message setString:[DCMUtil timeStampToString:timeStamp] forKey:DCMTemperatureProfileParamTimeStampString];
}

+ (void) setType:(DCMTemperatureType)type target:(DConnectMessage *)message {
    [message setInteger:type forKey:DCMTemperatureProfileParamType];
}

@end