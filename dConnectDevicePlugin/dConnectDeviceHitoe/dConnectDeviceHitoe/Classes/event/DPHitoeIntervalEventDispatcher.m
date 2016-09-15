//
//  DPHitoeInternalEventDispatcher.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeIntervalEventDispatcher.h"
#import <DConnectSDK/DConnectSDK.h>

@interface DPHitoeIntervalEventDispatcher() {
    NSObject *lockObj;
}
@property (nonatomic, assign) int firstPeriodTime;
@property (nonatomic, assign) int periodTime;
@property (nonatomic, strong) DConnectMessage *message;
@property (nonatomic) NSTimer *timer;
@end
@implementation DPHitoeIntervalEventDispatcher

- (instancetype)initWithDevicePlugin:(DConnectDevicePlugin *)devicePlugin
                     firstPeriodTime:(int)firstPeriodTime
                          periodTime:(int)periodTime {
    self = [super initWithDevicePlugin:devicePlugin];
    if (self) {
        lockObj = [NSObject new];
        if (firstPeriodTime < 0) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"firstPeriodTime is negative."];
        }
        if (periodTime <= 0) {
            [NSException raise:NSInternalInconsistencyException
                        format:@"periodTime is zero or negative."];
        }
        _firstPeriodTime = firstPeriodTime;
        _periodTime = periodTime;
    }
    return self;
}

- (void)sendEventForMessge:(DConnectMessage *)message {
    @synchronized(lockObj) {
        _message = message;
    }
}

- (void)start {
    if (_timer.isValid) {
        return;
    }
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSTimeInterval interval = _periodTime / 1000;
        _timer = [NSTimer
                  scheduledTimerWithTimeInterval:interval
                  target:_self
                  selector:@selector(onTimer:)
                  userInfo:nil
                  repeats:YES];
    });
}
- (void)stop {
    if (_timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)onTimer:(NSTimer*)timer {
    @synchronized(lockObj) {
        if (_message) {
            [self sendEventInternalForMessage:_message];
        }
        _message = nil;
    }

}

@end
