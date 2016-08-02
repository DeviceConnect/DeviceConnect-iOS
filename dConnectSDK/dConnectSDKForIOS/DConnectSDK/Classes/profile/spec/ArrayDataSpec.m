//
//  ArrayDataSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/30.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "ArrayDataSpec.h"


@interface ArrayDataSpec()

@property(nonatomic, strong) DConnectDataSpec *itemsSpec;

@end

@implementation ArrayDataSpec

- (instancetype) initWithDataSpec: (DConnectDataSpec *) itemsSpec {
    
    self = [super initWithType: DConnectSpecDataTypeArray];
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
    NSString *arrayParam = [obj.toString();
    if (arrayParam.equals("")) { // TODO allowEmptyValueに対応
        return true;
    }
    String[] items = arrayParam.split(","); // TODO csv以外の形式に対応
    for (String item : items) {
        if (!mItemsSpec.validate(item)) {
            return false;
        }
    }
    return YES;

    /*-----*/
    if (obj == null) {
        return true;
    }
    String arrayParam = obj.toString();
    if (arrayParam.equals("")) { // TODO allowEmptyValueに対応
        return true;
    }
    String[] items = arrayParam.split(","); // TODO csv以外の形式に対応
    for (String item : items) {
        if (!mItemsSpec.validate(item)) {
            return false;
        }
    }
    return true;
}

@end
