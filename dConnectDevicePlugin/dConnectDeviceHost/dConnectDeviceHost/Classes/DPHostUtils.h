//
//  DPHostUtils.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#define SELF_PLUGIN ((DPHostDevicePlugin *)self.provider)
#define WEAKSELF_PLUGIN ((DPHostDevicePlugin *)weakSelf.provider)

@interface DPHostUtils : NSObject

+ (NSString *) randomStringWithLength:(NSUInteger)len;
+ (NSString *) percentEncodeString:(NSString *)string withEncoding:(NSStringEncoding)encoding;
+ (BOOL)existFloatWithString:(NSString *)numberString;
+ (BOOL)existDigitWithString:(NSString*)digit;
+ (BOOL)existDecimalWithString:(NSString*)decimal;
+ (BOOL)existCSVWithString:(NSString *)csv;

@end
