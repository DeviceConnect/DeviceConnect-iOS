//
//  DConnectGeolocationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2017 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectGeolocationProfile.h"

// 属性
NSString *const DConnectGeolocationProfileName = @"geolocation";
NSString *const DConnectGeolocationProfileAttrCurrentPosition = @"currentposition";
NSString *const DConnectGeolocationProfileAttrOnWatchPosition = @"onwatchposition";

// パラメータ
NSString *const DConnectGeolocationProfileParamHighAccuracy = @"highAccuracy";
NSString *const DConnectGeolocationProfileParamMaximumAge = @"maximumAge";
NSString *const DConnectGeolocationProfileParamInterval = @"interval";
NSString *const DConnectGeolocationProfileParamPosition = @"position";
NSString *const DConnectGeolocationProfileParamCoordinates = @"coordinates";
NSString *const DConnectGeolocationProfileParamLatitude = @"latitude";
NSString *const DConnectGeolocationProfileParamLongitude = @"longitude";
NSString *const DConnectGeolocationProfileParamAltitude = @"altitude";
NSString *const DConnectGeolocationProfileParamAccuracy = @"accuracy";
NSString *const DConnectGeolocationProfileParamAltitudeAccuracy = @"altitudeAccuracy";
NSString *const DConnectGeolocationProfileParamHeading = @"heading";
NSString *const DConnectGeolocationProfileParamSpeed = @"speed";
NSString *const DConnectGeolocationProfileParamTimeStamp = @"timeStamp";
NSString *const DConnectGeolocationProfileParamTimeStampString = @"timeStampString";

@implementation DConnectGeolocationProfile

- (NSString *) profileName {
    return DConnectGeolocationProfileName;
}

#pragma mark - Getter
+ (BOOL) highAccuracyFromRequest:(DConnectMessage *)request {
    return [request boolForKey:DConnectGeolocationProfileParamHighAccuracy];
}

+ (NSNumber *) maximumAgeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectGeolocationProfileParamMaximumAge];
}

+ (NSNumber *) intervalFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectGeolocationProfileParamInterval];
}

#pragma mark - Setter
+ (void) setPosition:(DConnectMessage *)position target:(DConnectMessage *)message {
    [message setMessage:position forKey:DConnectGeolocationProfileParamPosition];
}

+ (void) setCoordinates:(DConnectMessage *)coordinates target:(DConnectMessage *)message {
    [message setMessage:coordinates forKey:DConnectGeolocationProfileParamCoordinates];
}

+ (void) setLatitude:(double)latitude target:(DConnectMessage *)message {
    [message setDouble:latitude forKey:DConnectGeolocationProfileParamLatitude];
}

+ (void) setLongitude:(double)longitude target:(DConnectMessage *)message {
    [message setDouble:longitude forKey:DConnectGeolocationProfileParamLongitude];
}

+ (void) setAltitude:(double)altitude target:(DConnectMessage *)message {
    [message setDouble:altitude forKey:DConnectGeolocationProfileParamAltitude];
}

+ (void) setAltitudeAccuracy:(double)altitudeAccuracy target:(DConnectMessage *)message {
    [message setDouble:altitudeAccuracy forKey:DConnectGeolocationProfileParamAltitudeAccuracy];
}

+ (void) setAccuracy:(double)accuracy target:(DConnectMessage *)message {
    [message setDouble:accuracy forKey:DConnectGeolocationProfileParamAccuracy];
}

+ (void) setHeading:(double)heading target:(DConnectMessage *)message {
    [message setDouble:heading forKey:DConnectGeolocationProfileParamHeading];
}

+ (void) setSpeed:(double)speed target:(DConnectMessage *)message {
    [message setDouble:speed forKey:DConnectGeolocationProfileParamSpeed];
}

+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message {
	[message setLongLong:timeStamp forKey:DConnectGeolocationProfileParamTimeStamp];
}

+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message {
    [message setString:timeStampString forKey:DConnectGeolocationProfileParamTimeStampString];
}

@end
