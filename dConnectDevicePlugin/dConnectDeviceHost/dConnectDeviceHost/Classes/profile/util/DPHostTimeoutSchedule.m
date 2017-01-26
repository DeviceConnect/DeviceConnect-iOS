//
//  DPHostTimeoutSchedule.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostTimeoutSchedule.h"
#import "DPHostUtil.h"

@implementation DPHostTimeoutSchedule {
    DPHostUtilTimerCancelBlock _cancelBlock;
}

- (instancetype) initWithTimeout:(float)timeout
{
    self = [super init];
    if (self) {
        [self setTimeout:timeout];
    }
    return self;
}

- (void) onCleanup
{
}

- (void) onTimeout
{
}

- (void) cleanup
{
    if (_cleanupFlag) {
        return;
    }
    _cleanupFlag = YES;
    
    _cancelBlock();
    
    [self onCleanup];
}

- (void) setTimeout:(float)time
{
    __block typeof(self) _self = self;
    _cancelBlock = [DPHostUtil asyncAfterDelay:time block:^{
        [_self timeout];
    }];
}

- (void) timeout
{
    if (_cleanupFlag) {
        return;
    }
    
    [self onTimeout];
    [self cleanup];
}

@end
