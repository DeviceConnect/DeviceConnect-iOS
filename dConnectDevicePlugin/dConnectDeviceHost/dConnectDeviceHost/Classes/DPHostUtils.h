//
//  DPHostUtils.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define SELF_PLUGIN ((DPHostDevicePlugin *)self.plugin)
#define WEAKSELF_PLUGIN ((DPHostDevicePlugin *)weakSelf.plugin)
#define SUPER_PLUGIN ((DPHostDevicePlugin *)super.plugin)

@interface DPHostUtils : NSObject

+ (NSString *) randomStringWithLength:(NSUInteger)len;
+ (NSString *) percentEncodeString:(NSString *)string withEncoding:(NSStringEncoding)encoding;
+ (BOOL)existFloatWithString:(NSString *)numberString;
+ (BOOL)existDigitWithString:(NSString*)digit;
+ (BOOL)existDecimalWithString:(NSString*)decimal;
+ (BOOL)existCSVWithString:(NSString *)csv;

//NSErrorを生成
+ (NSError*)throwsErrorCode:(NSInteger)code message:(NSString*)message;
// TOPにあるViewControllerを返す
+ (UIViewController*)topViewController;
+ (UIViewController*)topViewController:(UIViewController*)rootViewController;

@end
