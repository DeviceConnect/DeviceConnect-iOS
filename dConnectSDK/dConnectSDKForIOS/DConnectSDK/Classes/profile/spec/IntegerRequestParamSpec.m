//
//  IntegerRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "IntegerRequestParamSpec.h"

NSString *const IntegerRequestParamSpecJsonKeyFormat = @"format";
NSString *const IntegerRequestParamSpecJsonKeyMaxValue = @"maxValue";
NSString *const IntegerRequestParamSpecJsonKeyMinValue = @"minValue";
NSString *const IntegerRequestParamSpecJsonKeyExclusiveMaxValue = @"exclusiveMaxValue";
NSString *const IntegerRequestParamSpecJsonKeyExclusiveMinValue = @"exclusiveMinValue";
NSString *const IntegerRequestParamSpecJsonKeyEnum = @"enum";
//NSString *const IntegerRequestParamSpecJsonKeyValue = @"value";

static NSString *const STRING_FORMAT_INT32 = @"int32";
static NSString *const STRING_FORMAT_INT64 = @"int64";


@interface IntegerRequestParamSpec()

@property IntegerRequestParamSpecFormat mFormat;
@property NSNumber *mMaxValue;              // long値を格納
@property NSNumber *mMinValue;              // long値を格納
@property NSNumber *mExclusiveMaxValue;     // long値を格納
@property NSNumber *mExclusiveMinValue;     // long値を格納
@property NSArray *mEnumList;               // NSStringの配列

@end

@implementation IntegerRequestParamSpec

- (instancetype)initWithFormat: (IntegerRequestParamSpecFormat) format
{
    self = [super initWithType: INTEGER];
    if (self) {
        // 初期値設定
        self.mFormat = format;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
        self.mEnumList = nil;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithType: INTEGER];
    if (self) {
        // 初期値設定
        self.mFormat = INT32;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
        self.mEnumList = nil;
    }
    return self;
}

- (BOOL) validate: (id) obj {
    
    if (![super validate: obj]) {
        return NO;
    }
    if (obj == nil) {
        return YES;
    }
    switch (self.mFormat) {
        case INT32:
            return [self validateInt32: obj];
        case INT64:
            return [self validateInt64: obj];
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception : %d", (int)self.mFormat];
    }
    return NO;
}

#pragma mark - IntegerRequestParamSpec Getter Method

- (IntegerRequestParamSpecFormat) format {
    return self.mFormat;
}

- (NSNumber *) maxValue {
    return self.mMaxValue;
}

- (NSNumber *) minValue {
    return self.mMinValue;
}

- (NSNumber *) exclusiveMaxValue {
    return self.mExclusiveMaxValue;
}

- (NSNumber *) exclusiveMinValue {
    return self.mExclusiveMinValue;
}

- (NSArray *) enumList {
    return self.mEnumList;
}

#pragma mark - IntegerRequestParamSpec Getter Method

- (void)setFormat : (IntegerRequestParamSpecFormat) format {
    self.mFormat = format;
}

- (void) setMaxValue: (NSNumber *) maxValue {
    self.mMaxValue = maxValue;
}

- (void) setMinValue: (NSNumber *) minValue {
    self.mMinValue = minValue;
}

- (void) setExclusiveMaxValue: (NSNumber *) exclusiveMaxValue {
    self.mExclusiveMaxValue = exclusiveMaxValue;
}

- (void) setExclusiveMinValue: (NSNumber *) exclusiveMinValue {
    self.mExclusiveMinValue = exclusiveMinValue;
}

- (void) setEnumList: (NSArray *) enumList {
    self.mEnumList = enumList;
}


#pragma mark - DConnectRequestParamSpecDelegate Implement

- (NSDictionary *) toDictionary {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[DConnectRequestParamSpecJsonKeyName] = self.name;
    dict[DConnectRequestParamSpecJsonKeyType] = [DConnectRequestParamSpec convertTypeToString: self.type];
    dict[DConnectRequestParamSpecJsonKeyMandatory] = [NSNumber numberWithBool: self.isMandatory];
    
    dict[IntegerRequestParamSpecJsonKeyFormat] = [IntegerRequestParamSpec convertFormatToString: self.mFormat];
    dict[IntegerRequestParamSpecJsonKeyMaxValue] = self.mMaxValue;
    dict[IntegerRequestParamSpecJsonKeyMinValue] = self.mMinValue;
    dict[IntegerRequestParamSpecJsonKeyExclusiveMaxValue] = self.mExclusiveMaxValue;
    dict[IntegerRequestParamSpecJsonKeyExclusiveMinValue] = self.mExclusiveMinValue;
    dict[IntegerRequestParamSpecJsonKeyEnum] = self.enumList;
    
    return dict;
}


#pragma mark - IntegerRequestParamSpec Private Method

- (BOOL)validateInt32: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if ([DConnectRequestParamSpec isDigit: strParam]) {
            long long l = [strParam longLongValue];
            if (INT32_MIN <= l && l <= INT32_MAX) {
                return [self validateRange: l];
            }
        }
        return NO;
    } else {
        return NO;
    }
}

- (BOOL) validateInt64: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if ([DConnectRequestParamSpec  isDigit: strParam]) {
            long long l = [strParam longLongValue];
            if (INT64_MIN <= l && l <= INT64_MAX) {
                return [self validateRange: l];
            }
        }
        return NO;
    } else {
        return NO;
    }
}

- (BOOL) validateRange: (long) value {
    
    if (self.mEnumList) {
        
        for (NSString *strEnum in self.mEnumList) {
            if ([DConnectRequestParamSpec  isDigit: strEnum]) {
                if ([strEnum longLongValue] == (long long)value) {
                    return YES;
                }
            }
        }
        return NO;

    } else {
        if (self.mMaxValue && [self.mMaxValue longValue] < value) {
            return NO;
        }
        if (self.mExclusiveMaxValue && [self.mExclusiveMaxValue longValue] <= value) {
            return NO;
        }
        if (self.mMinValue && [self.mMinValue longValue] > value) {
            return NO;
        }
        if (self.mExclusiveMinValue && [self.mExclusiveMinValue longValue] >= value) {
            return NO;
        }
        return YES;
    }
}


#pragma mark - IntegerRequestParamSpec Static Method

// enum Format#getName()相当
+ (NSString *) convertFormatToString: (IntegerRequestParamSpecFormat) format {
    if (format == INT32) {
        return STRING_FORMAT_INT32;
    }
    if (format == INT64) {
        return STRING_FORMAT_INT64;
    }
    @throw [NSString stringWithFormat: @"format is invalid : %d", (int)format];
}

// enum Format#parse()相当
+ (IntegerRequestParamSpecFormat) parseFormat: (NSString *) strFormat {
    
    if (!strFormat) {
        @throw [NSString stringWithFormat: @"strFormat is nil"];
    }
    
    NSString *strFormatLow = [strFormat lowercaseString];
    
    if ([strFormatLow isEqualToString: [STRING_FORMAT_INT32 lowercaseString]]) {
        return INT32;
    }
    if ([strFormatLow isEqualToString: [STRING_FORMAT_INT64 lowercaseString]]) {
        return INT64;
    }
    @throw [NSString stringWithFormat: @"strFormat is invalid : %@", strFormat];
}
@end
