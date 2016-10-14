//
//  DConnectFileParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectFileParameterSpecBuilder.h"
#import "DConnectFileParameterSpec.h"

@implementation DConnectFileParameterSpecBuilder

- (DConnectFileParameterSpec *) build {
    DConnectFileParameterSpec *spec = [[DConnectFileParameterSpec alloc] init];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    return spec;
}

@end
