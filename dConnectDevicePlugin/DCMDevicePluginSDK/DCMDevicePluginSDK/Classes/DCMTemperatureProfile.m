//
//  DCMTemperatureProfileName.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMTemperatureProfile.h"
#import <DConnectSDK/DConnectUtil.h>

NSString *const DCMTemperatureProfileName = @"temperature";
NSString *const DCMTemperatureProfileParamTemperature = @"temperature";
NSString *const DCMTemperatureProfileParamType = @"type";

@implementation DCMTemperatureProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMTemperatureProfileName;
}

@end