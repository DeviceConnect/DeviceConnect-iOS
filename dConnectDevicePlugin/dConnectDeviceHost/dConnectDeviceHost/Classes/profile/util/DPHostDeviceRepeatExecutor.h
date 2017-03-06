//
//  DPHostDeviceRepeatExecutor.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPHRepeateBlock)();

@interface DPHostDeviceRepeatExecutor : NSObject

- (instancetype)initWithPattern:(NSArray *)pattern on:(DPHRepeateBlock)onBlock off:(DPHRepeateBlock)offBlock;

- (void) cancel;

@end
