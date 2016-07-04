//
//  NumberRequestParamSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "NumberRequestParamSpec.h"

@interface NumberRequestParamSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;

- (id)isMandatory:(BOOL)isMandatory;

- (id)format:(NumberRequestParamSpecFormat)format;

- (id)maxValue:(double)maxValue;

- (id)minValue:(double)minValue;

- (id)exclusiveMaxValue:(double)exclusiveMaxValue;

- (id)exclusiveMinValue:(double)exclusiveMinValue;

- (NumberRequestParamSpec *)build;

@end
