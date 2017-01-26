//
//  DPHostUtil.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostUtil.h"

@implementation DPHostUtil

+ (DPHostUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHostUtilTimerBlock)block {
    return [self asyncAfterDate:[NSDate dateWithTimeIntervalSinceNow:delay] block:block queue:dispatch_get_main_queue()];
}

+ (DPHostUtilTimerCancelBlock) asyncAfterDelay:(NSTimeInterval)delay block:(DPHostUtilTimerBlock)block queue:(dispatch_queue_t)queue {
    return [self asyncAfterDate:[NSDate dateWithTimeIntervalSinceNow:delay] block:block queue:queue];
}

+ (DPHostUtilTimerCancelBlock) asyncAfterDate:(NSDate *)date block:(DPHostUtilTimerBlock)block queue:(dispatch_queue_t)queue {
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

+ (int) byteToShort:(const char *)buf {
    return (((buf[1] << 8) & 0xFF00) | (buf[0] & 0xff));
}

+ (double) pow:(int)count
{
    double t = 1;
    for (int i = 0; i < count; i++) {
        t = t / 2.0;
    }
    return t;
}

+ (int) mask:(int) value
{
    int t = 1;
    for (int i = 0; i < value - 1; i++) {
        t = t | (t << 1);
    }
    return t;
}

+ (int) getCount:(int)v exponent:(int)exponent
{
    int result = 0;
    int bit = 1;
    for (int i = 0; i < exponent; i++) {
        if ((v & bit) != 0) {
            result = i;
        }
        bit <<= 1;
    }
    return result;
}

+ (int) getDecimal:(float)value fraction:(int)fraction
{
    int v = 0;
    while (fraction > 0) {
        fraction--;
        float tmp = value * 2;
        if (tmp < 1.0f) {
            value = tmp;
        } else if (tmp > 1) {
            v |= (1 << fraction);
            value = tmp - 1.0f;
        } else {
            v |= (1 << fraction);
            break;
        }
    }
    return v;
}

+ (int) floatToInt:(float)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign
{
    float tmpValue = fabs(value);
    
    int mask = [self mask:fraction];
    int bias = (int) pow(2, exponent - 1) - 1;
    int integer = (int) floor(tmpValue);
    float decimal = tmpValue - (float) integer;
    
    int d = [self getDecimal:decimal fraction:fraction];
    int v = (integer << fraction);
    
    v |= d;
    
    int count = 0;
    if (integer > 0) {
        count = [self getCount:integer exponent:exponent];
        v = (v >> count) & mask;
    } else {
        int bit = (1 << (fraction - 1));
        for (int i = 0; i < fraction; i++) {
            v = ((v << 1) & mask);
            count--;
            if ((v & bit) != 0) {
                break;
            }
        }
        v = ((v << 1) & mask);
        count--;
    }
    
    bias += count;
    
    v = (bias << fraction) | v;
    if (sign && value < 0) {
        v = (v | (1 << (exponent + fraction)));
    }
    
    return v;
}

+ (float) intToFloat:(int)value fraction:(int)fraction exponent:(int) exponent sign:(BOOL)sign
{
    if (value == 0) {
        return 0.0f;
    }
    
    int mantissa = value & [self mask:fraction];
    int bais = (value >> fraction) & [self mask:exponent];
    bais -= pow(2, exponent - 1) - 1;
    
    int integer = 0;
    float decimal = 0;
    
    if (bais >= 0) {
        {
            int t = 1;
            int bit = 1 << (fraction - bais);
            for (int p = fraction - bais; p < fraction; p++) {
                if ((mantissa & bit) != 0) {
                    integer += t;
                }
                t <<= 1;
                bit <<= 1;
            }
            integer += t;
        }
        {
            int t = 1;
            int bit = 1 << (fraction - bais - 1);
            for (int p = fraction - bais - 1; p > 0; p--) {
                if ((mantissa & bit) != 0) {
                    decimal += [self pow:t];
                }
                t++;
                bit >>= 1;
            }
        }
    } else {
        int t = abs(bais);
        int bit = 1 << (fraction - 1);
        decimal += [self pow:t];
        for (int p = fraction; p >= 0; p--) {
            t++;
            if ((mantissa & bit) != 0) {
                decimal += [self pow:t];
            }
            bit >>= 1;
        }
    }
    
    if (sign) {
        int bit = 1 << (fraction + exponent);
        if ((value & bit) != 0) {
            return -(integer + decimal);
        }
    }
    return integer + decimal;
}

+ (NSString *) timeStampToString:(long)timeStamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:date];
}

@end
