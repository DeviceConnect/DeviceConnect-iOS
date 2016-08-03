//
//  NumberDataSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "NumberDataSpecBuilder.h"
#import "NumberDataSpec.h"

@implementation NumberDataSpecBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDataFormat: FLOAT];
    }
    return self;
}

- (NumberDataSpec *) build {
    
    NumberDataSpec *spec = [NumberDataSpec initWithDataFormat: [self dataFormat]];
    [spec setMaximum: [self maximum]];
    [spec setExclusiveMaximum: [self exclusiveMaximum]];
    [spec setMinimum: [self minimum]];
    [self setExclusiveMinimum: [self exclusiveMinimum]];

    return spec;
}

@end
