//
//  FileParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "FileParameterSpecBuilder.h"
#import "FileParameterSpec.h"

@implementation FileParameterSpecBuilder

- (FileParameterSpec *) build {
    FileParameterSpec *spec = [[FileParameterSpec alloc] init];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    return spec;
}

@end
