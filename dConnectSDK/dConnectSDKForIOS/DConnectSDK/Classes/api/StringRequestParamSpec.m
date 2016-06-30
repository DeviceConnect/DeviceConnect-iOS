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
NSString *const StringRequestParamSpecJsonKeyValue = @"value";

@interface StringRequestParamSpec()

@property StringRequestParamSpecFormat mFormat;
@property NSInteger *mMaxLength;
@property NSInteger *mMinLength;
@property NSArray *mEnumList; // NSStringの配列

@end


@implementation StringRequestParamSpec

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
    if (![obj isMemberOfClass: [NSString class]]) {
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

          
          
#pragma mark - StringRequestParamSpec Getter Method

- (StringRequestParamSpecFormat) format {
    return self.mFormat;
}

- (NSInteger *) maxLength {
    return self.mMaxLength;
}

- (NSInteger *) minLength {
    return self.mMinLength;
}

- (NSArray *) enumList {
    return self.mEnumList;
}


#pragma mark - StringRequestParamSpec Getter Method

- (void)setFormat : (StringRequestParamSpecFormat) format {
    self.mFormat = format;
}
- (void) setMaxLength: (NSInteger *) maxLength {
    self.mMaxLength = maxLength;
}

- (void) setMinLength: (NSInteger *) minLength {
    self.mMinLength = minLength;
}

- (void) setEnumList: (NSArray *) enumList {
    self.mEnumList = enumList;
}

          
#pragma mark - StringRequestParamSpec Private Method

- (BOOL)validateLength: (NSString *) param {
    if (self.mMaxLength != nil && [param length] > *(self.mMaxLength)) {
        return NO;
    }
    if (self.mMinLength != nil && [param length] < *(self.mMinLength)) {
        return NO;
    }
    return YES;
}
          
@end
