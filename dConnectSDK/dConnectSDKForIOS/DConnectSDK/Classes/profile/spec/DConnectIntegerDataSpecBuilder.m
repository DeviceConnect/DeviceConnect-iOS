//
//  DConnectIntegerDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectIntegerDataSpecBuilder.h"

@implementation DConnectIntegerDataSpecBuilder


- (id) init {
    
    self = [super init];
    
    if (self) {
        // 初期値設定
        [self setFormat: INT32];
        [self setEnumList: nil];
        [self setMaximum: nil];
        [self setMinimum: nil];
        [self setExclusiveMaximum: NO];
        [self setExclusiveMinimum: NO];
    }
    
    return self;
}

#pragma mark - IntegerDataSpecBuilder Builder Method


- (DConnectIntegerDataSpec *) build {
    DConnectIntegerDataSpec *paramSpec = [[DConnectIntegerDataSpec alloc] initWithFormat: [self format]];
    [paramSpec setEnumList: [self enumList]];
    [paramSpec setMaximum: [self maximum]];
    [paramSpec setMinimum: [self minimum]];
    [paramSpec setExclusiveMaximum: [self exclusiveMaximum]];
    [paramSpec setExclusiveMinimum: [self exclusiveMinimum]];
    return paramSpec;
}

@end
