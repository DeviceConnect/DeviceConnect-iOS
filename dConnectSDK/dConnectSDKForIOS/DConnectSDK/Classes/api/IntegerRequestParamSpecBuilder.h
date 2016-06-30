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

- (id)format:(IntegerRequestParamSpecFormat)format;

- (id)maxValue:(NSNumber *)maxValue;

- (id)minValue:(NSNumber *)minValue;

- (id)exclusiveMaxValue:(NSNumber *)exclusiveMaxValue;

- (id)exclusiveMinValue:(NSNumber *)exclusiveMinValue;

- (id)enumList:(NSArray *)enumList;

- (IntegerRequestParamSpec *)build;

@end
