//
//  DConnectArrayDataSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectArrayDataSpecBuilder.h"
#import "DConnectArrayDataSpec.h"

@implementation DConnectArrayDataSpecBuilder

- (instancetype) init {
    self = [super init];
    if (self) {
        [self setItemsSpec: nil];
        [self setMaxLength: nil];
        [self setMinLength: nil];
    }
    return self;
}

- (DConnectArrayDataSpec *) build {
    DConnectArrayDataSpec *spec = [[DConnectArrayDataSpec alloc] initWithItemsSpec: [self itemsSpec]];
    [spec setMaxLength: [self maxLength]];
    [spec setMinLength: [self minLength]];
    return spec;
}

@end
