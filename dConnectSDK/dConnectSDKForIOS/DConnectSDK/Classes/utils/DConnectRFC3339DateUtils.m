//
//  DConnectRFC3339DateUtils.m
//  DConnectSDK
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRFC3339DateUtils.h"

@implementation DConnectRFC3339DateUtils
static NSString *const kRFC3339Format = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

+ (NSString *) stringWithDate:(NSDate*)date locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:kRFC3339Format];
    formatter.timeZone = timeZone;
    formatter.locale = locale;
    return [formatter stringFromDate:date];
}

+ (NSString *) stringWithTimeStamp:(long)timeStamp locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    return [DConnectRFC3339DateUtils stringWithDate:date locale:locale timeZone:timeZone];
}
+ (NSDate *) dateWithString:(NSString*)timeStampString locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone
{
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:kRFC3339Format];
    formatter.timeZone = timeZone;
    formatter.locale = locale;
    return [formatter dateFromString:timeStampString];
}

+ (long) timeStampWithString:(NSString*)timeStampString locale:(NSLocale*)locale timeZone:(NSTimeZone*)timeZone
{
    return [[DConnectRFC3339DateUtils dateWithString:timeStampString locale:locale timeZone:timeZone] timeIntervalSince1970];
}

+ (NSString *) stringWithTimeStamp:(long)timeStamp
{
    return [DConnectRFC3339DateUtils stringWithTimeStamp:timeStamp locale:[NSLocale currentLocale] timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSString *) stringWithDate:(NSDate*)date
{
    return [DConnectRFC3339DateUtils stringWithDate:date locale:[NSLocale currentLocale] timeZone:[NSTimeZone defaultTimeZone]];
}

+ (long) timeStampWithString:(NSString*)timeStampString
{
    return [DConnectRFC3339DateUtils timeStampWithString:timeStampString locale:[NSLocale currentLocale] timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSDate *) dateWithString:(NSString*)timeStampString
{
    return [DConnectRFC3339DateUtils dateWithString:timeStampString locale:[NSLocale currentLocale] timeZone:[NSTimeZone defaultTimeZone]];
}

+ (NSString*)nowTimeStampString
{
    return [DConnectRFC3339DateUtils stringWithDate:[NSDate date]];
}
@end
