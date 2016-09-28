//
//  DConnectVibrationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectVibrationProfile.h"

NSString *const DConnectVibrationProfileName = @"vibration";
NSString *const DConnectVibrationProfileAttrVibrate = @"vibrate";
NSString *const DConnectVibrationProfileParamPattern = @"pattern";

NSString *const DConnectVibrationProfileVibrationDurationDelim = @",";
const long long DConnectVibrationProfileDefaultMaxVibrationTime = 500;

@interface DConnectVibrationProfile()

- (BOOL) isNumberString:(NSString *)str;

@end

@implementation DConnectVibrationProfile

#pragma mark - init Methods
- (id) init {
    self = [super init];
    if (self) {
        self.maxVibrationTime = DConnectVibrationProfileDefaultMaxVibrationTime;
    }
    return self;
}

#pragma mark - DConnect Profile Methods
- (NSString *) profileName {
    return DConnectVibrationProfileName;
}

#pragma mark - Getter

+ (NSString *) patternFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectVibrationProfileParamPattern];
}

#pragma mark - Utility

- (NSArray *) parsePattern:(NSString *)pattern {

    NSMutableArray *result = [NSMutableArray array];
    if (!pattern || pattern.length == 0) {
        [result addObject:[NSNumber numberWithLongLong:self.maxVibrationTime]];
        return result;
    }
    
    NSRange range = [pattern rangeOfString:DConnectVibrationProfileVibrationDurationDelim];
    if (range.location != NSNotFound) {
        NSArray *times = [pattern componentsSeparatedByString:DConnectVibrationProfileVibrationDurationDelim];
        for (NSString *time in times) {
            NSString *valueStr = [time stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (valueStr.length == 0) {
                if (result.count != times.count - 1) {
                    // 数値の間にスペースがある場合はフォーマットエラー
                    // ex. 100, , 100
                    [result removeAllObjects];
                }
                break;
            } else if (![self isNumberString:valueStr]) {
                [result removeAllObjects];
                break;
            }
            
            long long value = [valueStr longLongValue];
            [result addObject:[NSNumber numberWithLongLong:value]];
        }
        
        // 解析に失敗した場合には、nilを返却する
        if (result.count == 0) {
            result = nil;
        }
    } else if ([self isNumberString:pattern]) {
        NSNumber *time = [NSNumber numberWithLongLong:[pattern longLongValue]];
        [result addObject:time];
    }
    
    if (result.count == 0) {
        return nil;
    }
    
    return result;
}

#pragma mark - Private Methods

- (BOOL) isNumberString:(NSString *)str {
    if (!str || str.length == 0) {
        return NO;
    }
    
    NSString *expression = @"^[-+]?([0-9]*)?$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        return NO;
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:str
                                                        options:0
                                                          range:NSMakeRange(0, [str length])];
    return (numberOfMatches != 0);
}

@end
