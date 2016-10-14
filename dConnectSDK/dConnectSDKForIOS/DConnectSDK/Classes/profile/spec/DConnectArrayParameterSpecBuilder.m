//
//  DConnectArrayParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectArrayParameterSpecBuilder.h"
#import "DConnectArrayParameterSpec.h"

@implementation DConnectArrayParameterSpecBuilder

- (instancetype) init {
    self = [super init];
    
    if (self) {
        [self setItemSpec: nil];
        [self setMaxLength: nil];
        [self setMinLength: nil];
    }
    
    return self;
}

- (DConnectArrayParameterSpec *) build {
    DConnectArrayParameterSpec *spec = [[DConnectArrayParameterSpec alloc] initWithDataSpec: [self itemSpec]];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    [spec setMaxLength: [self maxLength]];
    [spec setMinLength: [self minLength]];
    return spec;
}

@end
