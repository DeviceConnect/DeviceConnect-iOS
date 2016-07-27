//
//  DPHitoeInternalEventDispatcher.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeEventDispatcher.h"

@interface DPHitoeIntervalEventDispatcher : DPHitoeEventDispatcher
- (instancetype)initWithDevicePlugin:(DConnectDevicePlugin *)devicePlugin
                     firstPeriodTime:(int)firstPeriodTime
                          periodTime:(int)periodTime;
@end
