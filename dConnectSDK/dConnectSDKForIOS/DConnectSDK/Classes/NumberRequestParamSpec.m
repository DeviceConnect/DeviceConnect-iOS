//
//  NumberRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberRequestParamSpec.h"

NSString *const NumberRequestParamSpecJsonKeyFormat = @"format";
NSString *const NumberRequestParamSpecJsonKeyMaxValue = @"maxValue";
NSString *const NumberRequestParamSpecJsonKeyMinValue = @"minValue";
NSString *const NumberRequestParamSpecJsonKeyExclusiveMaxValue = @"exclusiveMaxValue";
NSString *const NumberRequestParamSpecJsonKeyExclusiveMinValue = @"exclusiveMinValue";

static NSString *const NUMBER_FORMAT_FLOAT = @"float";
static NSString *const NUMBER_FORMAT_DOUBLE = @"double";

@interface NumberRequestParamSpec()

@property NumberRequestParamSpecFormat mFormat;
@property NSNumber *mMaxValue;          // double値を格納
@property NSNumber *mMinValue;          // double値を格納
@property NSNumber *mExclusiveMaxValue; // double値を格納
@property NSNumber *mExclusiveMinValue; // double値を格納

@end

@implementation NumberRequestParamSpec

- (instancetype)initWithFormat:(NumberRequestParamSpecFormat) format
{
    self = [super initWithType: NUMBER];
    if (self) {
        // 初期値設定
        self.mFormat = format;
        self.mMaxValue = nil;
        self.mMinValue = nil;
        self.mExclusiveMaxValue = nil;
        self.mExclusiveMinValue = nil;
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
        case FLOAT:
            return [self validateDouble: obj];
        case DOUBLE:
            return [self validateDouble: obj];
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception : %d", (int)self.mFormat];
    }
    return NO;
}

#pragma mark - NumberRequestParamSpec Getter Method

- (NumberRequestParamSpecFormat) format {
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

#pragma mark - NumberRequestParamSpec Getter Method

- (void)setFormat : (NumberRequestParamSpecFormat) format {
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



#pragma mark - NumberRequestParamSpec Private Method

- (BOOL)validateDouble: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if ([self isDouble: strParam]) {
            double d = [strParam doubleValue];
            return [self validateRange: d];
        }
        return NO;
    } else {
        return NO;
    }
}

- (BOOL) validateRange: (double) value {
    
    if (self.mMaxValue && [self.mMaxValue doubleValue] < value) {
        return NO;
    }
    if (self.mExclusiveMaxValue && [self.mExclusiveMaxValue doubleValue] <= value) {
        return NO;
    }
    if (self.mMinValue && [self.mMinValue doubleValue] > value) {
        return NO;
    }
    if (self.mExclusiveMinValue && [self.mExclusiveMinValue doubleValue] >= value) {
        return NO;
    }
    return YES;
}

- (BOOL)isDouble:(NSString *)text {
    NSCharacterSet *digitCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    
    NSScanner *aScanner = [NSScanner localizedScannerWithString:text];
    [aScanner setCharactersToBeSkipped:nil];
    
    [aScanner scanCharactersFromSet:digitCharSet intoString:NULL];
    return [aScanner isAtEnd];
}


#pragma mark - NumberRequestParamSpec Static Method

// enum Format#getName()相当
+ (NSString *) convertFormatToString: (NumberRequestParamSpecFormat) format {
    if (format == FLOAT) {
        return NUMBER_FORMAT_FLOAT;
    }
    if (format == DOUBLE) {
        return NUMBER_FORMAT_DOUBLE;
    }
    @throw [NSString stringWithFormat: @"format is invalid : type: %d", (int)format];
}

// enum Format#parse()相当
+ (NumberRequestParamSpecFormat) parseFormat: (NSString *) strFormat {
    
    if (!strFormat) {
        @throw [NSString stringWithFormat: @"strFormat is nil"];
    }
    
    NSString *strFormatLow = [strFormat lowercaseString];
    
    if ([strFormatLow isEqualToString: [NUMBER_FORMAT_FLOAT lowercaseString]]) {
        return FLOAT;
    }
    if ([strFormatLow isEqualToString: [NUMBER_FORMAT_DOUBLE lowercaseString]]) {
        return DOUBLE;
    }
    @throw [NSString stringWithFormat: @"strFormat is invalid : %@", strFormat];
}

@end
