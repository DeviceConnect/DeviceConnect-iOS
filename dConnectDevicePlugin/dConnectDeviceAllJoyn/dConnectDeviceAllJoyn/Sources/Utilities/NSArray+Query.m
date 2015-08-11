//
//  NSArray+Query.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NSArray+Query.h"


@implementation NSArray (Query)

- (BOOL)containsAll:(NSArray *)array
{
    if (!array) {
        return NO;
    }
    for (id element in array) {
        if (![self containsObject:element]) {
            return NO;
        }
    }
    return YES;
}

@end
