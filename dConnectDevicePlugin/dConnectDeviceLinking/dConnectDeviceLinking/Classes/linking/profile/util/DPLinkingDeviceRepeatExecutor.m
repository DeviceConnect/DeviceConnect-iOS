//
//  DPLinkingDeviceRepeatExecutor.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceRepeatExecutor.h"
#import "DPLinkingUtil.h"

@implementation DPLinkingDeviceRepeatExecutor {
    DPLinkingUtilTimerCancelBlock _cancelBlock;
    DPLRepeateBlock _onBlock;
    DPLRepeateBlock _offBlock;
    NSArray *_pattern;
    int _index;
}

- (instancetype)initWithPattern:(NSArray *)pattern on:(DPLRepeateBlock)onBlock off:(DPLRepeateBlock)offBlock
{
    self = [super init];
    if (self) {
        _pattern = pattern;
        _index = 0;
        _onBlock = [onBlock copy];
        _offBlock = [offBlock copy];
        [self nextStep];
    }
    return self;
}

- (void) cancel
{
    _cancelBlock();
}

- (void) nextStep
{
    if (_index % 2 == 0) {
        _onBlock();
    } else {
        _offBlock();
    }
    _index++;

    if (_index >= _pattern.count) {
        return;
    }
    
    int time = [[_pattern objectAtIndex:_index] integerValue];

    __block typeof(self) _self = self;
    _cancelBlock = [DPLinkingUtil asyncAfterDelay:time block:^{
        [_self nextStep];
    }];
}

@end
