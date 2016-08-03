//
//  DConnectParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectParameterSpec.h"

@implementation DConnectParameterSpec

- (instancetype) initWithDataSpec: (DConnectDataSpec *) dataSpec {
    
    self = [super init];
    if (self) {
        [self setDataSpec: dataSpec];
    }
    return self;
}

- (DConnectSpecDataType) dataType {
    return [[self dataSpec] dataType];
}

#pragma marker - Absolute Methods Implement.

- (BOOL) validate: (id) param {
    if (!param) {
        return ![self isRequired];
    }
    return [[self dataSpec] validate: param];
}

@end
