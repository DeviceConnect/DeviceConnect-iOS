//
//  DConnectParameterSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/07/31.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
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
    return [dataSpec dataType];
}

#pragma marker - Absolute Methods Implement.

- (BOOL) validate: (id) param {
    if (!param) {
        return ![self isRequired];
    }
    return [[self dataSpec] validate: param];
}

@end
