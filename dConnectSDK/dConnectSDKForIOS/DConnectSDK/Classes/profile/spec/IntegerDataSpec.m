//
//  IntegerRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "IntegerDataSpec.h"

@implementation IntegerDataSpec

- (instancetype)initWithFormat: (IntegerRequestParamSpecFormat) format
{
    self = [super initWithType: INTEGER];
    if (self) {
        // 初期値設定
        [self setFormat: format];
        [self setMaximum: nil];
        [self setMinimum: nil];
        [self setExclusiveMaximum: NO];
        [self setExclusiveMinimum: NO];
        [self setEnumList: nil];
    }
    return self;
}

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj {
    
    if (![super validate: obj]) {
        return NO;
    }
    if (obj == nil) {
        return YES;
    }
    switch ([self format]) {
        case INT32:
            return [self validateInt32: obj];
        case INT64:
            return [self validateInt64: obj];
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception : %d", (int)[self format]];
    }
    return NO;
}


#pragma mark - IntegerRequestParamSpec Private Method

- (BOOL)validateInt32: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if (![DConnectSpecConstants isDigit: strParam]) {
            return NO;
        }
        long long l = [strParam longLongValue];
        if (!(INT32_MIN <= l && l <= INT32_MAX)) {
            return NO;
        }
        return [self validateRange: l];
    } if ([param isKindOfClass: [NSNumber class]]) {
        NSNumber *numParam = (NSString *)param;
        long long l = [numParam longLongValue];
        if (!(INT32_MIN <= l && l <= INT32_MAX)) {
            return NO;
        }
        return [self validateRange: l];
    } else {
        return NO;
    }
}

- (BOOL)validateInt64: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if (![DConnectSpecConstants isDigit: strParam]) {
            return NO;
        }
        long long l = [strParam longLongValue];
        if (!(INT64_MIN <= l && l <= INT64_MAX)) {
            return NO;
        }
        return [self validateRange: l];
    } if ([param isKindOfClass: [NSNumber class]]) {
        NSNumber *numParam = (NSString *)param;
        long long l = [numParam longLongValue];
        if (!(INT64_MIN <= l && l <= INT64_MAX)) {
            return NO;
        }
        return [self validateRange: l];
    } else {
        return NO;
    }
}

- (BOOL) validateRange: (long) value {
    
    if ([self enumList]) {
        
        for (NSNumber *numEnum in [self enumList]) {
            if ([numEnum longLongValue] == (long long)value) {
                return YES;
            }
        }
        return NO;

    } else {
        BOOL isValid = YES;
        if ([self maximum]) {
            isValid &=  [self exclusiveMaximum] ? ([self maximum] > value) : ([self maximum] >= value);
        }
        if ([self minimum]) {
            isValid &= [self exclusiveMinimum] ? ([self minimum] < value) : ([self minimum] <= value);
        }
        return isValid;
    }
}

@end
