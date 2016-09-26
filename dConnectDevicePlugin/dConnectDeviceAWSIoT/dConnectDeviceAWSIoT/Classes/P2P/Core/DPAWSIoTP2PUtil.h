//
//  DPAWSIoTP2PUtil.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^AWSIoTUtilTimerBlock)();
typedef void (^AWSIoTUtilTimerCancelBlock)();

@interface DPAWSIoTP2PUtil : NSObject

+ (AWSIoTUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(AWSIoTUtilTimerBlock)block;
+ (AWSIoTUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(AWSIoTUtilTimerBlock)block queue:(dispatch_queue_t)queue;

@end
