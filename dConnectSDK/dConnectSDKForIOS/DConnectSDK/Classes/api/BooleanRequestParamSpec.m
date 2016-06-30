//
//  BooleanRequestParamSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanRequestParamSpec.h"

NSString *const BooleanRequestParamSpecJsonKeyName = @"name";
NSString *const BooleanRequestParamSpecJsonKeyIsMandatory = @"isMandatory";

NSString *const BooleanRequestParamSpecJsonValTrue = @"true";
NSString *const BooleanRequestParamSpecJsonValFalse = @"false";

@implementation BooleanRequestParamSpec

- (instancetype)init
{
    self = [super initWithType: BOOLEAN];
    if (self) {
        // 初期値設定
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
    // Stringの"TRUE","FALSE"ならYESを返す
    if ([obj isMemberOfClass: [NSString class]]) {
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
    if ([obj isMemberOfClass: [NSNumber class]]) {
        NSNumber *num = (NSNumber *)obj;
        if ([num boolValue] == TRUE || [num boolValue] == FALSE) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - BooleanRequestParamSpec Getter Method

- (NSString *) name {
    return self.name;
}

- (BOOL) isMandatory {
    return self.isMandatory;
}

#pragma mark - BooleanRequestParamSpec Getter Method


- (void) setName: (NSString *) name {
    self.name = name;
}

- (void) setIsMandatory: (BOOL) isMandatory {
    self.isMandatory = isMandatory;
}

@end
