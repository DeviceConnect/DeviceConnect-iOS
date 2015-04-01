//
//  DPHostUtils.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <stdlib.h>
#import "DPHostUtils.h"



static NSString * const kDPHostRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const kDPHostRegexDigit = @"^([0-9]*)?$";
static NSString * const kDPHostRegexCSV = @"^([^,]*,)+";

@implementation DPHostUtils

+ (NSString *) randomStringWithLength:(NSUInteger)len {
    static const NSString *const letters = @"ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; ++i) {
        [randomString appendFormat:@"%C",
            [letters characterAtIndex:
             arc4random_uniform(UINT32_MAX) % [letters length]]];
    }
    
    return randomString;
}

+ (NSString *) percentEncodeString:(NSString *)string withEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet *allowedCharSet
        = [[NSCharacterSet characterSetWithCharactersInString:@";/?:@&=$+{}<>., "] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharSet];
}

+ (BOOL)existFloatWithString:(NSString *)numberString
{
    NSRange matchInteger = [numberString rangeOfString:@"^([0-9]*)?$"
                                               options:NSRegularExpressionSearch];
    NSRange matchFloat = [numberString rangeOfString:@"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$"
                                             options:NSRegularExpressionSearch];
    //数値の場合
    return (matchFloat.location != NSNotFound && matchInteger.location == NSNotFound);
}

+ (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}

+ (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:kDPHostRegexDigit];
}

+ (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:kDPHostRegexDecimalPoint];
}

+ (BOOL)existCSVWithString:(NSString *)csv {
    return [self existNumberWithString:csv Regex:kDPHostRegexCSV];
}

@end
