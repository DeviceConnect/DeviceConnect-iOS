//
//  DConnectNumberDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNumberDataSpecBuilder.h"
#import "DConnectNumberDataSpec.h"

@implementation DConnectNumberDataSpecBuilder

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setDataFormat: FLOAT];
    }
    return self;
}

- (DConnectNumberDataSpec *) build {
    
    DConnectNumberDataSpec *spec = [[DConnectNumberDataSpec alloc] initWithDataFormat: [self dataFormat]];
    [spec setMaximum: [self maximum]];
    [spec setExclusiveMaximum: [self exclusiveMaximum]];
    [spec setMinimum: [self minimum]];
    [self setExclusiveMinimum: [self exclusiveMinimum]];

    return spec;
}

@end
