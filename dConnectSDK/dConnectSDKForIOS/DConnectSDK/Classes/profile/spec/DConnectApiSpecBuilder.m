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
        [self setName: nil];
        [self setMethod: GET];
        [self setType: ONESHOT];
        [self setPath: nil];
        [self setRequestParamSpecList: nil];
    }
    
    return self;
}
- (DConnectApiSpec *) build {
    DConnectApiSpec *apiSpec = [[DConnectApiSpec alloc] init];
    [apiSpec setName: [self name]];
    [apiSpec setType: [self type]];
    [apiSpec setMethod: [self method]];
    [apiSpec setPath: [self path]];
    [apiSpec setRequestParamSpecList: [self requestParamSpecList]];
    return apiSpec;
}

@end
