//
//  DConnectAtmosphericPressureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAtmosphericPressureProfile.h"
#import "DPLinkingUtil.h"

NSString *const DConnectAtmosphericPressureProfileName = @"atmosphericPressure";
NSString *const DConnectAtmoshpericPressureProfileParamAtmosphericPressure = @"atmosphericPressure";
NSString *const DConnectAtmoshpericPressureProfileParamTimeStamp = @"timeStamp";
NSString *const DConnectAtmoshpericPressureProfileParamTimeStampString = @"timeStampString";

@implementation DConnectAtmosphericPressureProfile

- (NSString *) profileName
{
    return DConnectAtmosphericPressureProfileName;
}

+ (void) setAtmosphericPressure:(float)atmosphericPressure target:(DConnectMessage *)message
{
    [message setFloat:atmosphericPressure forKey:DConnectAtmoshpericPressureProfileParamAtmosphericPressure];
}

+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message
{
    [message setLong:timeStamp forKey:DConnectAtmoshpericPressureProfileParamTimeStamp];
    [message setString:[DPLinkingUtil timeStampToString:timeStamp] forKey:DConnectAtmoshpericPressureProfileParamTimeStampString];
}

@end
