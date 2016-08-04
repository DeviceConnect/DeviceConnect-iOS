//
//  NumberParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "NumberParameterSpecBuilder.h"
#import "NumberParameterSpec.h"

@implementation NumberParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setFormat: FLOAT];
    }
    return self;
}

- (NumberParameterSpec *) build {
    
    NumberParameterSpec *spec = [[NumberParameterSpec alloc] initWithDataFormat: [self format]];
    
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    if ([self maximum]) {
        [spec setMaximum: [[self maximum] doubleValue]];
    }
    [spec setExclusiveMaximum: [self exclusiveMaximum]];
    if ([self minimum]) {
        [spec setMinimum: [[self minimum] doubleValue]];
    }
    [spec setExclusiveMinimum: [self exclusiveMinimum]];

    return spec;
}

@end
