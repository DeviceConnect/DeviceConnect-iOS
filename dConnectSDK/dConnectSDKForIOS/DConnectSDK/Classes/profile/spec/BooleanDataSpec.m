//
//  BooleanDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanDataSpec.h"

@implementation BooleanDataSpec

- (instancetype)init
{
    self = [super initWithDataType: BOOLEAN];
    return self;
}

- (BOOL) validate: (id) obj {
    if (!obj) {
        return YES;
    }
    // Stringの"TRUE","FALSE"ならYESを返す
    if ([obj isKindOfClass: [NSString class]]) {
        NSString *str = (NSString *) obj;
        if (str) {
            if ([str localizedCaseInsensitiveCompare: BooleanRequestParamSpecJsonValTrue] == NSOrderedSame ||
                [str localizedCaseInsensitiveCompare: BooleanRequestParamSpecJsonValFalse] == NSOrderedSame) {
                return YES;
            }
        }
        return NO;
    }
    // NSNumberのBOOL値のTRUE,FALSEならYESを返す
    if ([obj isKindOfClass: [NSNumber class]]) {
        NSNumber *num = (NSNumber *)obj;
        if ([num boolValue] == TRUE || [num boolValue] == FALSE) {
            return YES;
        }
    }
    return NO;
}

@end
