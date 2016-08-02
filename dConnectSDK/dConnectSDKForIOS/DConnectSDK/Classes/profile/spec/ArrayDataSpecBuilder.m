//
//  ArrayDataSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "ArrayDataSpecBuilder.h"
#import "ArrayDataSpec.h"

@implementation ArrayDataSpecBuilder

- (instancetype) init {
    self = [super init];
    if (self) {
        [spec setItemSpec: nil];
        [spec setMaxLength: nil];
        [spec setMinLength: nil];
    }
    return self;
}

- (ArrayDataSpec *) build {
    ArrayDataSpec *spec = [[ArrayDataSpec alloc] initWithDataSpec: [self itemsSpec]];
    [spec setMaxLength: [self maxLength]];
    [spec setMinLength: [self minLength]];
    return spec;
}

@end
