//
//  DPLinkingUtil.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPLinkingUtilTimerBlock)(void);
typedef void (^DPLinkingUtilTimerCancelBlock)(void);

@interface DPLinkingUtil : NSObject

+ (DPLinkingUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPLinkingUtilTimerBlock)block;
+ (DPLinkingUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPLinkingUtilTimerBlock)block queue:(dispatch_queue_t)queue;

+ (int) byteToShort:(const char *)d;

+ (int) floatToInt:(float)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;
+ (float) intToFloat:(int)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign;


@end
