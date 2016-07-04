//
//  StringRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringRequestParamSpec.h"

NSString *const StringRequestParamSpecJsonKeyFormat = @"format";
NSString *const StringRequestParamSpecJsonKeyMaxLength = @"maxLength";
NSString *const StringRequestParamSpecJsonKeyMinLength = @"minLength";
NSString *const StringRequestParamSpecJsonKeyEnum = @"enum";
//NSString *const StringRequestParamSpecJsonKeyValue = @"value";

static NSString *const STRING_FORMAT_TEXT = @"text";
static NSString *const STRING_FORMAT_BYTE = @"byte";
static NSString *const STRING_FORMAT_BINARY = @"binary";
static NSString *const STRING_FORMAT_DATE = @"date";


@interface StringRequestParamSpec()

@property StringRequestParamSpecFormat mFormat;
@property NSNumber *mMaxLength; // int値を格納。nilなら省略。
@property NSNumber *mMinLength; // int値を格納。nilなら省略。
@property NSArray *mEnumList; // NSStringの配列

@end


@implementation StringRequestParamSpec

- (instancetype)init {

    self = [super initWithType: STRING];
    if (self) {
        // 初期値設定
        self.mFormat = TEXT;
        self.mMaxLength = nil;
        self.mMinLength = nil;
        self.mEnumList = nil;
    }
    return self;
}

- (instancetype)initWitFormat: (StringRequestParamSpecFormat) format {
    
    self = [super initWithType: STRING];
    if (self) {
        // 初期値設定
        self.mFormat = format;
        self.mMaxLength = nil;
        self.mMinLength = nil;
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
    if (![obj isKindOfClass: [NSString class]]) {
        return NO;
    }
    NSString *param = (NSString *) obj;
    switch(self.mFormat) {
        case TEXT:
            return [self validateLength: param];
        case BYTE:
        case BINARY:
            return YES; // TODO バイナリのサイズ確認(現状、プラグインにはURL形式で通知される)
        case DATE:
            return YES; // TODO RFC3339形式であることの確認
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception. mFormat: %d", (int)self.mFormat];
    }
    return NO;
}



#pragma mark - DConnectRequestParamSpecDelegate Implement

- (NSDictionary *) toDictionary {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[DConnectRequestParamSpecJsonKeyName] = self.name;
    dict[DConnectRequestParamSpecJsonKeyType] = [DConnectRequestParamSpec convertTypeToString: self.type];
    dict[DConnectRequestParamSpecJsonKeyMandatory] = [NSNumber numberWithBool: self.isMandatory];
    
    dict[StringRequestParamSpecJsonKeyFormat] = [StringRequestParamSpec convertFormatToString: self.mFormat];
    dict[StringRequestParamSpecJsonKeyMaxLength] = self.mMaxLength;
    dict[StringRequestParamSpecJsonKeyMinLength] = self.mMinLength;
    dict[StringRequestParamSpecJsonKeyEnum] = self.enumList;
    
    return dict;
}


#pragma mark - StringRequestParamSpec Getter Method

- (StringRequestParamSpecFormat) format {
    return self.mFormat;
}

- (NSNumber *) maxLength {
    return self.mMaxLength;
}

- (NSNumber *) minLength {
    return self.mMinLength;
}

- (NSArray *) enumList {
    return self.mEnumList;
}


#pragma mark - StringRequestParamSpec Getter Method

- (void)setFormat : (StringRequestParamSpecFormat) format {
    self.mFormat = format;
}
- (void) setMaxLength: (NSNumber *) maxLength {
    self.mMaxLength = maxLength;
}

- (void) setMinLength: (NSNumber *) minLength {
    self.mMinLength = minLength;
}

- (void) setEnumList: (NSArray *) enumList {
    self.mEnumList = enumList;
}

          
#pragma mark - StringRequestParamSpec Private Method

- (BOOL)validateLength: (NSString *) param {
    if (self.mMaxLength != nil && [param length] > [self.mMaxLength intValue]) {
        return NO;
    }
    if (self.mMinLength != nil && [param length] < [self.mMinLength intValue]) {
        return NO;
    }
    return YES;
}


#pragma mark - StringRequestParamSpec Static Method

// enum Format#getName()相当
+ (NSString *) convertFormatToString: (StringRequestParamSpecFormat) format {
    if (format == TEXT) {
        return STRING_FORMAT_TEXT;
    }
    if (format == BYTE) {
        return STRING_FORMAT_BYTE;
    }
    if (format == BINARY) {
        return STRING_FORMAT_BINARY;
    }
    if (format == DATE) {
        return STRING_FORMAT_DATE;
    }
    @throw [NSString stringWithFormat: @"format is invalid : type: %d", (int)format];
}

// enum Format#parse()相当
+ (StringRequestParamSpecFormat) parseFormat: (NSString *) strFormat {
    
    if (!strFormat) {
        @throw [NSString stringWithFormat: @"strFormat is nil"];
    }
    
    NSString *strFormatLow = [strFormat lowercaseString];
    
    if ([strFormatLow isEqualToString: [STRING_FORMAT_TEXT lowercaseString]]) {
        return TEXT;
    }
    if ([strFormatLow isEqualToString: [STRING_FORMAT_BYTE lowercaseString]]) {
        return BYTE;
    }
    if ([strFormatLow isEqualToString: [STRING_FORMAT_BINARY lowercaseString]]) {
        return BINARY;
    }
    if ([strFormatLow isEqualToString: [STRING_FORMAT_DATE lowercaseString]]) {
        return DATE;
    }
    @throw [NSString stringWithFormat: @"strFormat is invalid : %@", strFormat];
}

@end
