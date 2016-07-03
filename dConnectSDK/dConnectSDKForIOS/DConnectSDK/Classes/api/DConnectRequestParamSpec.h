//
//  DConnectRequestParamSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

extern NSString *const DConnectRequestParamSpecJsonKeyName;
extern NSString *const DConnectRequestParamSpecJsonKeyMandatory;
extern NSString *const DConnectRequestParamSpecJsonKeyType;


typedef enum {
    STRING = 0,
    INTEGER,
    NUMBER,
    BOOLEAN
} DConnectRequestParamSpecType;


@interface  DConnectRequestParamSpec : NSObject

- (instancetype)initWithType: (DConnectRequestParamSpecType)type;
- (DConnectRequestParamSpecType) type;
- (void) setName: (NSString *)name;
- (NSString *) name;
- (void) setIsMandatory: (BOOL) isMandatory;
- (BOOL) isMandatory;
- (BOOL) validate: (id) param;
- (NSDictionary *) toDictionary;

+ (NSString *) convertBoolToString: (BOOL) boolValue;
+ (NSString *) convertTypeToString: (DConnectRequestParamSpecType) type;
+ (DConnectRequestParamSpecType)parseType: (NSString *)strType;
+ (BOOL)isDigit:(NSString *)text;
+ (BOOL)isNumber:(NSString *)text;

@end
