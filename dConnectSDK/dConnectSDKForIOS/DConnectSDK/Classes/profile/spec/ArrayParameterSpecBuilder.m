//
//  ArrayParameterSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/03.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "ArrayParameterSpecBuilder.h"
#import "ArrayParameterSpec.h"

@implementation ArrayParameterSpecBuilder

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self setItemSpec: nil];
        [self setMaxLength: nil];
        [self setMinLength: nil];
    }
    
    return self;
}

- (ArrayParameterSpec *) build {
    ArrayParameterSpec *spec = [[ArrayParameterSpec alloc] initWithItemSpec: mItemsSpec];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    [spec setMaxLength: [self maxLength]];
    [spec setMinLength: [self minLength]];
    return spec;
}

@end
