//
//  IntegerDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "IntegerDataSpecBuilder.h"

@implementation IntegerDataSpecBuilder


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


- (IntegerDataSpec *) build {
    IntegerDataSpec *paramSpec = [[IntegerRequestParamSpec alloc] initWithFormat: [self format]];
    [paramSpec setEnumList: [self enumList]];
    [paramSpec setMaximum: [self maximum]];
    [paramSpec setMinimum: [self minimum]];
    [paramSpec setExclusiveMaximum: [self exclusiveMaximum]];
    [paramSpec setExclusiveMinimum: [self exclusiveMinimum]];
    return paramSpec;
}

@end
