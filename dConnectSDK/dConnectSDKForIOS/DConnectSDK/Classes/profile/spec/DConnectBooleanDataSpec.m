//
//  DConnectBooleanDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBooleanDataSpec.h"
#import "DConnectSpecConstants.h"

@implementation DConnectBooleanDataSpec

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
            if ([str localizedCaseInsensitiveCompare: DConnectSpecBoolTrue] == NSOrderedSame ||
                [str localizedCaseInsensitiveCompare: DConnectSpecBoolFalse] == NSOrderedSame) {
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
