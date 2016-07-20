//
//  DPLinkingTimeoutSchedule.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingTimeoutSchedule.h"
#import "DPLinkingUtil.h"

@implementation DPLinkingTimeoutSchedule {
    DPLinkingUtilTimerCancelBlock _cancelBlock;
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
    _cancelBlock = [DPLinkingUtil asyncAfterDelay:time block:^{
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
