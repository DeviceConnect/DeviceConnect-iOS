//
//  DConnectBooleanParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectBooleanParameterSpecBuilder.h"

@implementation DConnectBooleanParameterSpecBuilder

- (DConnectBooleanParameterSpec *) build {
    DConnectBooleanParameterSpec *spec = [[DConnectBooleanParameterSpec alloc] init];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    return spec;
}

@end
