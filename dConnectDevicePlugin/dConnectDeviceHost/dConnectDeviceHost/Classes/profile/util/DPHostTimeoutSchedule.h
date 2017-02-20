//
//  DPHostTimeoutSchedule.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@interface DPHostTimeoutSchedule : NSObject

@property (nonatomic) BOOL cleanupFlag;

- (instancetype) initWithTimeout:(float)timeout;

- (void) cleanup;

- (void) onCleanup;
- (void) onTimeout;

@end
