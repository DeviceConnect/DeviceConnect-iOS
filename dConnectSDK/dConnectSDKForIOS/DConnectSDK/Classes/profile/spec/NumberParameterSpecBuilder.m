//
//  NumberRequestParamSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberParameterSpecBuilder.h"

@implementation NumberParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setFormat: NUMBER];
    }
    return self;
}

- (NumberDataSpec *) build {
    NumberParameterSpec *spec = [[NumberParameterSpec alloc] initWithDataFormat: [self format]];
    
    [paramSpec setName: [self name]];
    [paramSpec setRequired: [self isRequired]];
    [paramSpec setMaximum: [self maximum]];
    [paramSpec setExclusiveMaximum: [self exclusiveMaximum]];
    [paramSpec setMinimum: [self minimum]];
    [paramSpec setExclusiveMinimum: [self exclusiveMinimum]];

    return paramSpec;
}

@end
