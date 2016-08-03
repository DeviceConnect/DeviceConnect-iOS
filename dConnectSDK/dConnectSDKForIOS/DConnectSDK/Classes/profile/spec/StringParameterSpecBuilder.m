//
//  StringParameterSpecBuilder.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/03.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "StringParameterSpecBuilder.h"
#import "StringParameterSpec.h"

@implementation StringParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setFormat: TEXT];
    }
    return self;
}

- (StringParameterSpec *) build {
    
    StringParameterSpec *spec = [[StringParameterSpec alloc] initWithDataFormat: [self format]];
    [spec setName: [self name]];
    [spec setRequired: [self isRequired]];
    if ([self enumList]) {
        [spec setEnumList: [self enumList]];
    } else {
        [spec setMaxLength:[self maxLength]];
        [spec setMinLength:[self minLength]];
    }
    return spec;
}

@end
