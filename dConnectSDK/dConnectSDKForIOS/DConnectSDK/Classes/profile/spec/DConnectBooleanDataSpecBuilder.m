//
//  DConnectBooleanDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBooleanDataSpecBuilder.h"

@implementation DConnectBooleanDataSpecBuilder

- (id) init {
    self = [super init];
    return self;
}

#pragma mark - BooleanDataSpecBuilder Builder Method

- (DConnectBooleanDataSpec *) build {
    DConnectBooleanDataSpec *paramSpec = [[DConnectBooleanDataSpec alloc] init];
    return paramSpec;
}

@end
