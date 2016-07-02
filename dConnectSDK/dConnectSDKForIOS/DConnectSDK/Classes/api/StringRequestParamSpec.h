//
//  StringRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectRequestParamSpec.h"

extern NSString *const StringRequestParamSpecJsonKeyFormat;
extern NSString *const StringRequestParamSpecJsonKeyMaxLength;
extern NSString *const StringRequestParamSpecJsonKeyMinLength;
extern NSString *const StringRequestParamSpecJsonKeyEnum;
extern NSString *const StringRequestParamSpecJsonKeyValue;

typedef enum {
    TEXT = 0,
    BYTE,
    BINARY,
    DATE,
} StringRequestParamSpecFormat;

@interface StringRequestParamSpec : DConnectRequestParamSpec

- (instancetype)initWitFormat: (StringRequestParamSpecFormat) format;

- (BOOL) validate: (id) obj;

- (StringRequestParamSpecFormat) format;

- (NSNumber *) maxLength;

- (NSNumber *) minLength;

- (NSArray *) enumList;

- (void)setFormat : (StringRequestParamSpecFormat) type;

- (void) setMaxLength: (NSNumber *) maxLength;

- (void) setMinLength: (NSNumber *) minLength;

- (void) setEnumList: (NSArray *) enumList ;

+ (NSString *) convertFormatToString: (StringRequestParamSpecFormat) format;

+ (StringRequestParamSpecFormat) parseFormat: (NSString *) strFormat;

@end
