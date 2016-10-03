//
//  DConnectStringDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringDataSpec.h"

static int RGB_PATTERN_LENGTH = 6;
static NSString * RGB_PATTERN = @"[0-9a-zA-Z]{%d}";

@implementation DConnectStringDataSpec

- (instancetype)initWitDataFormat: (DConnectSpecDataFormat) dataFormat {
    
    self = [super initWithDataType: STRING];
    if (self) {
        // 初期値設定
        [self setDataFormat: dataFormat];
        [self setMaxLength: nil];
        [self setMinLength: nil];
        [self setEnums: nil];
    }
    return self;
}

#pragma mark - DConnectDataSpec Abstruct Method Implement.

- (BOOL) validate: (id) obj {
    
    if (!obj) {
        return YES;
    }
    if (![obj isKindOfClass: [NSString class]]) {
        return NO;
    }
    NSString *param = (NSString *) obj;
    switch([self dataFormat]) {
        case TEXT:
            return [self validateLength: param];
        case BYTE:
        case BINARY:
            return YES; // TODO バイナリのサイズ確認(現状、プラグインにはURL形式で通知される)
        case DATE:
            return YES; // TODO RFC3339形式であることの確認
        case DATE_TIME:
            return YES; // TODO RFC3339形式であることの確認
        case RGB:
            if ([self matchPattern: [NSString stringWithFormat: RGB_PATTERN, RGB_PATTERN_LENGTH]
                     patternLength: RGB_PATTERN_LENGTH
                            string: param]) {
                return YES;
            } else {
                return NO;
            }
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception. format: %d", (int)[self dataFormat]];
    }
    return NO;
}

#pragma mark - StringDataSpec Private Method

- (BOOL) validateLength: (NSString *) param {
    if ([self maxLength] && [param length] > [[self maxLength] intValue]) {
        return NO;
    }
    if ([self minLength] && [param length] < [[self minLength] intValue]) {
        return NO;
    }
    return YES;
}

- (BOOL) matchPattern: (NSString *)pattern patternLength: (int) patternLength string: (NSString *) string {
    
    // 正規表現オブジェクト作成
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 比較
    NSTextCheckingResult *match = [regex firstMatchInString:string
                                                    options:0
                                                      range:NSMakeRange(0, string.length)];
    if (match) {
        NSRange matchRange = [match range];
        if (matchRange.location == 0
            &&  matchRange.length == patternLength) {
            if ([string length] == patternLength) {
                // パターン一致
                return YES;
            }
        }
    }
    
    // パターン不一致
    return NO;
}

@end
