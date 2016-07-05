//
//  NumberRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectRequestParamSpec.h"

extern NSString *const NumberRequestParamSpecJsonKeyFormat;
extern NSString *const NumberRequestParamSpecJsonKeyMaxValue;
extern NSString *const NumberRequestParamSpecJsonKeyMinValue;
extern NSString *const NumberRequestParamSpecJsonKeyExclusiveMaxValue;
extern NSString *const NumberRequestParamSpecJsonKeyExclusiveMinValue;

typedef enum {
    FLOAT = 0,
    DOUBLE,
} NumberRequestParamSpecFormat;


@interface NumberRequestParamSpec : DConnectRequestParamSpec<DConnectRequestParamSpecDelegate>

- (instancetype)init;

- (instancetype)initWithFormat:(NumberRequestParamSpecFormat) format;

- (BOOL) validate: (id) obj;

- (NumberRequestParamSpecFormat) format;

- (NSNumber *) maxValue;

- (NSNumber *) minValue;

- (NSNumber *) exclusiveMaxValue;

- (NSNumber *) exclusiveMinValue;

- (void)setFormat : (NumberRequestParamSpecFormat) type;

- (void) setMaxValue: (NSNumber *) maxValue;

- (void) setMinValue: (NSNumber *) minValue;

- (void) setExclusiveMaxValue: (NSNumber *) exclusiveMaxValue;

- (void) setExclusiveMinValue: (NSNumber *) exclusiveMinValue;

+ (NSString *) convertFormatToString: (NumberRequestParamSpecFormat) format;

+ (NumberRequestParamSpecFormat) parseFormat: (NSString *) strFormat;

@end
