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

+ (BOOL)isFloatWithString:(NSString *)numberString
{
    NSRange matchInteger = [numberString rangeOfString:@"^([0-9]*)?$"
                                               options:NSRegularExpressionSearch];
    NSRange matchFloat = [numberString rangeOfString:@"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$"
                                             options:NSRegularExpressionSearch];
    //数値の場合
    return (matchFloat.location != NSNotFound && matchInteger.location == NSNotFound);
}


@end
