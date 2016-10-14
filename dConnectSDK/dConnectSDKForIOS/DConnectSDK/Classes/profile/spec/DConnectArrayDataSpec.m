//
//  DConnectArrayDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectArrayDataSpec.h"


@implementation DConnectArrayDataSpec

- (instancetype) initWithItemsSpec: (DConnectDataSpec *) itemsSpec {
    
    self = [super initWithDataType: ARRAY];
    if (self) {
        [self setItemsSpec: itemsSpec];
    }
    return self;
}

#pragma mark - Abstruct Methods Implement.

- (BOOL) validate: (id) obj {
    if (!obj) {
        return YES;
    }
    
    NSString *arrayParam = nil;
    if ([obj isKindOfClass: [NSString class]]) {
        arrayParam = (NSString *)obj;
    } else {
        return YES;
    }
    
    if ([arrayParam isEqualToString: @""]) { // TODO allowEmptyValueに対応
        return YES;
    }
    
    NSArray *items = [arrayParam componentsSeparatedByString:@","]; // TODO csv以外の形式に対応
    for (NSString *item in items) {
        if (![[self itemsSpec] validate: item]) {
            return NO;
        }
    }
    return YES;
}

@end
