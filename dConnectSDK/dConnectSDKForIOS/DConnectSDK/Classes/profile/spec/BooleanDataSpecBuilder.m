//
//  BooleanDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanDataSpecBuilder.h"

@implementation BooleanDataSpecBuilder

- (id) init {
    self = [super init];
    return self;
}

#pragma mark - BooleanDataSpecBuilder Builder Method

- (BooleanDataSpec *) build {
    BooleanDataSpec *paramSpec = [[BooleanDataSpec alloc] init];
    return paramSpec;
}

@end
