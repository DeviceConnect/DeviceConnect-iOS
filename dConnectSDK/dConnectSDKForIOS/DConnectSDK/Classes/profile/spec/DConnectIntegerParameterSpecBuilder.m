//
//  DConnectIntegerParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectIntegerParameterSpecBuilder.h"

@implementation DConnectIntegerParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setDataFormat: INT32];
    }
    return self;
}

- (DConnectIntegerParameterSpec *) build {
    
    DConnectIntegerParameterSpec *spec = [[DConnectIntegerParameterSpec alloc] initWithDataFormat: [self dataFormat]];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    [spec setEnumList: [self enumList]];
    if ([self maximum]) {
        [spec setMaximum: [[self maximum] longValue]];
    }
    [spec setExclusiveMaximum: [self exclusiveMaximum]];
    if ([self minimum]) {
        [spec setMinimum: [[self minimum] longValue]];
    }
    [spec setExclusiveMinimum: [self exclusiveMinimum]];
    return spec;
}

@end
