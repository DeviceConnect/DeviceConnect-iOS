//
//  DPHitoeMDERFloatConvertUtil.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPHitoeMDERFloatConvertUtil.h"

@implementation DPHitoeMDERFloatConvertUtil

+ (NSString*)converMDERFloatToFloat:(float)target {
    NSNumber *targetNumber = [NSNumber numberWithFloat:target];
    int exponent = [self getExponent:[targetNumber stringValue]];
    NSDecimalNumber *dec = [NSDecimalNumber decimalNumberWithString:[targetNumber stringValue]];
    dec = [dec decimalNumberByMultiplyingByPowerOf10:(exponent * -1)];
    return [NSString stringWithFormat:@"%02X%06X", (exponent & 0xFF), ([dec intValue] & 0xFFFFFF) ];
}

+ (int)getExponent:(NSString *)value {
    NSRange index = [value rangeOfString:@"."];
    if (index.location != NSNotFound) {
        return (int) ((value.length - 1) - index.location) * -1;
    } else {
        return [self countZero:value];
    }
}

+ (int)countZero:(NSString*)value {
    int count = 0;
    if ([value characterAtIndex:value.length - 1] != '0') {
        return 0;
    }
    for (int i = 0; i < value.length; i++) {
        if ([value characterAtIndex:i] == '0') {
            count++;
        }
    }
    return count;
}
@end
