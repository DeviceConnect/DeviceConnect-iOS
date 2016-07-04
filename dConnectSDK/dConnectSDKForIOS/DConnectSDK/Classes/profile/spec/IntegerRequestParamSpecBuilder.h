//
//  IntegerRequestParamSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "IntegerRequestParamSpec.h"

@interface IntegerRequestParamSpecBuilder : NSObject

- (id)init;

- (id)name: (NSString *) name;

- (id)isMandatory: (BOOL)isMandatory;

- (id)format:(IntegerRequestParamSpecFormat)format;

- (id)maxValue:(long)maxValue;

- (id)minValue:(long)minValue;

- (id)exclusiveMaxValue:(long)exclusiveMaxValue;

- (id)exclusiveMinValue:(long)exclusiveMinValue;

- (id)enumList:(NSArray *)enumList;

- (IntegerRequestParamSpec *)build;

@end
