//
//  BooleanParameterSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "BooleanParameterSpecBuilder.h"

@implementation BooleanParameterSpecBuilder

- (BooleanParameterSpec *) build {
    BooleanParameterSpec *spec = [[BooleanParameterSpec alloc] init];
    [spec setName: [self name];
    [spec setRequired: [self isRequired]];
    return spec;
}

@end
