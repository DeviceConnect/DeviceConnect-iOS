//
//  DConnectApiSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpecBuilder.h"

@implementation DConnectApiSpecBuilder

- (id) init {
    
    self = [super init];
    
    if (self) {
        [self setType: ONESHOT];
        [self setMethod: GET];
        [self setParams: [NSArray array]];        // List<DConnectParameterSpec>
    }
    
    return self;
}

- (DConnectApiSpec *) build {

    NSArray *deepCopyParamList =[[NSArray alloc] initWithArray: [self params] copyItems: YES];
    
    DConnectApiSpec *spec = [[DConnectApiSpec alloc] init];
    [spec setType: [self type]];
    [spec setMethod: [self method]];
    [spec setRequestParamSpecList: deepCopyParamList];
    
    return spec;
}

@end
