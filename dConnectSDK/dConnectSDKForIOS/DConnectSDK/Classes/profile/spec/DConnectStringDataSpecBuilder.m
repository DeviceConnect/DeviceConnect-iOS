//
//  DConnectStringDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringDataSpecBuilder.h"

@implementation DConnectStringDataSpecBuilder

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setFormat: TEXT];
    }
    return self;
}

- (DConnectStringDataSpec *) build {
    
    DConnectStringDataSpec *paramSpec = [[DConnectStringDataSpec alloc] initWitDataFormat:[self format]];
    
    if ([self enums]) {
        [paramSpec setEnums: [self enums]];
    } else {
        [paramSpec setMaxLength: [self maxLength]];
        [paramSpec setMinLength: [self minLength]];
    }
    
    return paramSpec;
}

@end
