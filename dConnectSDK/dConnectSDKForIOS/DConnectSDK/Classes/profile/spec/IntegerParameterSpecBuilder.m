//
//  IntegerParameterSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "IntegerParameterSpecBuilder.h"

@implementation IntegerParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setFormat: INT32];
    }
    return self;
}

- (IntegerParameterSpec *) build {
    
    IntegerParameterSpec *spec = [[IntegerParameterSpec alloc] initWithDataFormat: [self format]];
    [spec setName: [self name]];
    [spec setRequired: [self isRequired]];
    [spec setEnumList: [self enumList]];
    [spec setMaximum: [self maximum]];
    [spec setExclusiveMaximum: [self exclusiveMaximum]];
    [spec setMinimum: [self minimum]];
    [spec setExclusiveMinimum: [self exclusiveMinimum]];
    return spec;
}

@end
