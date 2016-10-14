//
//  BooleanParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "BooleanParameterSpecBuilder.h"

@implementation BooleanParameterSpecBuilder

- (BooleanParameterSpec *) build {
    BooleanParameterSpec *spec = [[BooleanParameterSpec alloc] init];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    return spec;
}

@end
