//
//  ArrayDataSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "ArrayDataSpec.h"


@implementation ArrayDataSpec

- (instancetype) initWithItemsSpec: (DConnectDataSpec *) itemsSpec {
    
    self = [super initWithDataType: ARRAY];
    if (self) {
        [self setItemsSpec: itemsSpec];
    }
    return self;
}

/*!
 @brief 配列に格納できるデータの仕様を取得する.
 @return 配列に格納できるデータの仕様
 */
- (DConnectDataSpec *) itemsSpec {
    return [self itemsSpec];
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
