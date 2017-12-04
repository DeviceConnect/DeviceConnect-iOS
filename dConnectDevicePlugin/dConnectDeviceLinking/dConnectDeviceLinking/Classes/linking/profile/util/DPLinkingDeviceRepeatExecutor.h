//
//  DPLinkingDeviceRepeatExecutor.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

typedef void (^DPLRepeateBlock)(void);

@interface DPLinkingDeviceRepeatExecutor : NSObject

- (instancetype)initWithPattern:(NSArray *)pattern on:(DPLRepeateBlock)onBlock off:(DPLRepeateBlock)offBlock;

- (void) cancel;

@end
