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
    self = [[super alloc] init];
    if (self) {
        [paramSpec setFormat: TEXT];
    }
    return self;
}

- (StringDataSpec *) build {
    
    StringDataSpec *paramSpec = [[StringDataSpec alloc] initWitDataFormat:[self format]];
    
    if ([self enumList]) {
        [paramSpec setEnumList: [self enumList]];
    } else {
        [paramSpec setMaxLength: [self maxLength]];
        [paramSpec setMinLength: [self minLength]];
    }
    
    return paramSpec;
}

@end
