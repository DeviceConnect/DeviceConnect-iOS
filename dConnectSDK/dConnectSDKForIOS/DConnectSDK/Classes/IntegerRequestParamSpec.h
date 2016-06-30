//
//  IntegerRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectRequestParamSpec.h"

extern NSString *const IntegerRequestParamSpecJsonKeyFormat;
extern NSString *const IntegerRequestParamSpecJsonKeyMaxValue;
extern NSString *const IntegerRequestParamSpecJsonKeyMinValue;
extern NSString *const IntegerRequestParamSpecJsonKeyExclusiveMaxValue;
extern NSString *const IntegerRequestParamSpecJsonKeyExclusiveMinValue;
extern NSString *const IntegerRequestParamSpecJsonKeyEnum;
extern NSString *const IntegerRequestParamSpecJsonKeyValue;

typedef enum {
    INT32 = 0,
    INT64,
} IntegerRequestParamSpecFormat;

@interface IntegerRequestParamSpec : DConnectRequestParamSpec

- (instancetype)initWithFormat: (IntegerRequestParamSpecFormat) format;

- (BOOL) validate: (id) obj;

- (IntegerRequestParamSpecFormat) format;

- (NSNumber *) maxValue;

- (NSNumber *) minValue;

- (NSNumber *) exclusiveMaxValue;

- (NSNumber *) exclusiveMinValue;

- (NSArray *) enumList;

- (void)setFormat : (IntegerRequestParamSpecFormat) type;

- (void) setMaxValue: (NSNumber *) maxValue;

- (void) setMinValue: (NSNumber *) minValue;

- (void) setExclusiveMaxValue: (NSNumber *) exclusiveMaxValue;

- (void) setExclusiveMinValue: (NSNumber *) exclusiveMinValue;

- (void) setEnumList: (NSArray *) enumList ;

@end
