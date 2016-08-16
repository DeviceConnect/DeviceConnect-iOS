//
//  StringDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringDataSpecBuilder.h"

@implementation StringDataSpecBuilder

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setFormat: TEXT];
    }
    return self;
}

- (StringDataSpec *) build {
    
    StringDataSpec *paramSpec = [[StringDataSpec alloc] initWitDataFormat:[self format]];
    
    if ([self enums]) {
        [paramSpec setEnums: [self enums]];
    } else {
        [paramSpec setMaxLength: [self maxLength]];
        [paramSpec setMinLength: [self minLength]];
    }
    
    return paramSpec;
}

@end
