//
//  DPHostDeviceRepeatExecutor.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostDeviceRepeatExecutor.h"
#import "DPHostUtil.h"

@implementation DPHostDeviceRepeatExecutor {
    DPHostUtilTimerCancelBlock _cancelBlock;
    DPHRepeateBlock _onBlock;
    DPHRepeateBlock _offBlock;
    NSArray *_pattern;
    int _index;
}

- (instancetype)initWithPattern:(NSArray *)pattern on:(DPHRepeateBlock)onBlock off:(DPHRepeateBlock)offBlock
{
    self = [super init];
    if (self) {
        NSMutableArray *replaceArray = [pattern mutableCopy];
        [replaceArray insertObject:[NSNumber numberWithLong:0L] atIndex:0];
        _pattern = [replaceArray copy];
        _index = 0;
        _onBlock = [onBlock copy];
        _offBlock = [offBlock copy];
        [self nextStep];
    }
    return self;
}

- (void) cancel
{
    if (_cancelBlock) {
        _cancelBlock();
        _cancelBlock = nil;
    }
}

- (void) nextStep
{
    if (_index % 2 == 0) {
        _onBlock();
    } else {
        _offBlock();
    }
    _index++;

    if (_index >= _pattern.count - 1) {
        return;
    }
    
    double time = [[_pattern objectAtIndex:_index] integerValue] / 1000.0;

    __weak typeof(self) _self = self;
    _cancelBlock = [DPHostUtil asyncAfterDelay:time block:^{
        [_self nextStep];
    }];
}

@end
