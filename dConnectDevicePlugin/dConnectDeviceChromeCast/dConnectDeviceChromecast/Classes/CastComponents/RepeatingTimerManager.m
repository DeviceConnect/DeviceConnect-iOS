// Copyright 2015 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "RepeatingTimerManager.h"

@interface RepeatingTimerManager ()

@property (weak,nonatomic) NSObject *target;
@property (nonatomic) SEL selectorToRun;
@property (nonatomic) NSTimer *timer;

@end

@implementation RepeatingTimerManager

# pragma mark - Interface

- (instancetype)initWithTarget:(NSObject*)target
                      selector:(SEL)selector
                     frequency:(NSTimeInterval)frequency {
  self = [super init];
  if(self) {
    self.target = target;
    self.selectorToRun = selector;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:frequency
                                                  target:self
                                                selector:@selector(runTimerSelector)
                                                userInfo:nil
                                                 repeats:YES];
  }
  return self;
}

- (void)invalidateTimer {
  [_timer invalidate];
  self.timer = nil;
  self.target = nil;
  self.selectorToRun = nil;
}

#pragma mark - Internals

- (void)runTimerSelector {
  [_target performSelector:_selectorToRun];
}

@end
