//
//  DPAWSIoTP2PUtil.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTP2PUtil.h"

@implementation DPAWSIoTP2PUtil

+ (AWSIoTUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(AWSIoTUtilTimerBlock)block {
    return [self asyncAfterDate:[NSDate dateWithTimeIntervalSinceNow:delay] block:block queue:dispatch_get_main_queue()];
}

+ (AWSIoTUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(AWSIoTUtilTimerBlock)block queue:(dispatch_queue_t)queue {
    return [self asyncAfterDate:[NSDate dateWithTimeIntervalSinceNow:delay] block:block queue:queue];
}

+ (AWSIoTUtilTimerCancelBlock) asyncAfterDate:(NSDate *)date block:(AWSIoTUtilTimerBlock)block queue:(dispatch_queue_t)queue {
    __block dispatch_source_t _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_event_handler(_source, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
            if (_source) {
                dispatch_source_cancel(_source);
            }
        });
    });
    
    dispatch_source_set_cancel_handler(_source, ^{
        _source = NULL;
    });
    
    void(^cancel_block)(void) = ^{
        if (_source) {
            dispatch_source_cancel(_source);
        }
    };
    
    dispatch_time_t delta = getDispatchTimeByDate(date);
    
    dispatch_source_set_timer(_source, delta, NSEC_PER_SEC, 0);
    dispatch_resume(_source);
    
    return cancel_block;
}

static dispatch_time_t getDispatchTimeByDate(NSDate *date) {
    NSTimeInterval interval;
    double second, subsecond;
    struct timespec time;
    dispatch_time_t milestone;
    interval = [date timeIntervalSince1970];
    subsecond = modf(interval, &second);
    time.tv_sec = second;
    time.tv_nsec = subsecond * NSEC_PER_SEC;
    milestone = dispatch_walltime(&time, 0);
    return milestone;
}

@end
