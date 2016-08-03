//
//  NumberRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberDataSpec.h"

@implementation NumberDataSpec

- (instancetype)initWithDataFormat:(DConnectSpecDataFormat) format
{
    self = [super initWithDataType: NUMBER];
    if (self) {
        // 初期値設定
        [self setFormat: format];
    }
    return self;
}

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj {
    
    if (!obj) {
        return YES;
    }
    switch ([self format]) {
        case FLOAT:
            return [self validateFloat: obj];
        case DOUBLE:
            return [self validateFloat: obj];
        default:
            @throw [NSString stringWithFormat: @"Illegal state exception : %d", (int)[self format]];
    }
    return NO;
}

#pragma mark - NumberDataSpec Private Method

- (BOOL)validateFloat: (id) param {
    if ([param isKindOfClass: [NSString class]]) {
        NSString *strParam = (NSString *)param;
        if ([self isDouble: strParam]) {
            double d = [strParam doubleValue];
            return [self validateRange: d];
        }
        return NO;
    } else if ([param isKindOfClass: [NSNumber class]]) {
        NSNumber *numParam = (NSNumber *)param;
        double d = [numParam doubleValue];
        return [self validateRange: d];
    } else {
        return NO;
    }
}

- (BOOL) validateRange: (double) value {

    BOOL isValid = YES;
    if ([self maximum]) {
        isValid &= [self isExclusiveMaximum] ? ([self maximum] > value) : ([self maximum] >= value);
    }
    if ([self minimum]) {
        isValid &= [self isExclusiveMinimum] ? ([self minimum] < value) : ([self minimum] <= value);
    }
    return isValid;
}

@end
