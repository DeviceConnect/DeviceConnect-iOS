//
//  DPHueUtil.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPHueUtilTimerBlock)(void);
typedef void (^DPHueUtilTimerCancelBlock)(void);

@interface DPHueUtil : NSObject

+ (DPHueUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHueUtilTimerBlock)block;
+ (DPHueUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHueUtilTimerBlock)block queue:(dispatch_queue_t)queue;

+ (int) byteToShort:(const char *)d;

+ (int) floatToInt:(float)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;
+ (float) intToFloat:(int)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;

+ (NSString *) timeStampToString:(long)timeStamp;

@end
