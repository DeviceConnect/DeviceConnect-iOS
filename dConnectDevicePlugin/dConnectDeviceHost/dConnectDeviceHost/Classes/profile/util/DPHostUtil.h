//
//  DPHostUtil.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPHostUtilTimerBlock)();
typedef void (^DPHostUtilTimerCancelBlock)();

@interface DPHostUtil : NSObject

+ (DPHostUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHostUtilTimerBlock)block;
+ (DPHostUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHostUtilTimerBlock)block queue:(dispatch_queue_t)queue;

+ (int) byteToShort:(const char *)d;

+ (int) floatToInt:(float)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;
+ (float) intToFloat:(int)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;

+ (NSString *) timeStampToString:(long)timeStamp;

@end
