//
//  DConnectStringParameterSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringParameterSpecBuilder.h"
#import "DConnectStringParameterSpec.h"

@implementation DConnectStringParameterSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        [self setDataFormat: TEXT];
    }
    return self;
}

- (DConnectStringParameterSpec *) build {
    
    DConnectStringParameterSpec *spec = [[DConnectStringParameterSpec alloc] initWithDataFormat: [self dataFormat]];
    [spec setName: [self name]];
    [spec setIsRequired: [self isRequired]];
    if ([self enums]) {
        [spec setEnums: [self enums]];
    } else {
        [spec setMaxLength:[self maxLength]];
        [spec setMinLength:[self minLength]];
    }
    return spec;
}

@end
