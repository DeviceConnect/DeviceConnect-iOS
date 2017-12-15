//
//  DCMHumidityProfile.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DCMHumidityProfile.h"

NSString *const DCMHumidityProfileName = @"humidity";

NSString *const DCMHumidityProfileParamHumidity = @"humidity";
NSString *const DCMHumidityProfileParamTimeStamp = @"timeStamp";
NSString *const DCMHumidityProfileParamTimeStampString = @"timeStampString";

@implementation DCMHumidityProfile

- (NSString *) profileName
{
    return DCMHumidityProfileName;
}

+ (void) setHumidity:(float)humidity target:(DConnectMessage *)message
{
    [message setFloat:humidity forKey:DCMHumidityProfileParamHumidity];
}

+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message
{
    [message setLong:timeStamp forKey:DCMHumidityProfileParamTimeStamp];
    [message setString:[DConnectRFC3339DateUtils stringWithTimeStamp:timeStamp] forKey:DCMHumidityProfileParamTimeStampString];
}

@end
