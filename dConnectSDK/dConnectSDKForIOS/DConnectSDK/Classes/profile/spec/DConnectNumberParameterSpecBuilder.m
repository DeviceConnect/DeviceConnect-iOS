//
//  DConnectNumberParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNumberParameterSpecBuilder.h"
#import "DConnectNumberParameterSpec.h"

@implementation DConnectNumberParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setDataFormat: FLOAT];
    }
    return self;
}

- (DConnectNumberParameterSpec *) build {
    
    DConnectNumberParameterSpec *spec = [[DConnectNumberParameterSpec alloc] initWithDataFormat: [self dataFormat]];
    
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
