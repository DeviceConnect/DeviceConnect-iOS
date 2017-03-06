//
//  DPHueTimeoutSchedule.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHueTimeoutSchedule : NSObject

@property (nonatomic) BOOL cleanupFlag;

- (instancetype) initWithTimeout:(float)timeout;

- (void) cleanup;

- (void) onCleanup;
- (void) onTimeout;

@end
