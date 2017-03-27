//
//  DPHueDeviceRepeatExecutor.h
//  dConnectDeviceHue
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPSRepeateBlock)();

@interface DPHueDeviceRepeatExecutor : NSObject

- (instancetype)initWithPattern:(NSArray *)pattern on:(DPSRepeateBlock)onBlock off:(DPSRepeateBlock)offBlock;

- (void) cancel;

@end
