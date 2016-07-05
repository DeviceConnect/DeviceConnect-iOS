//
//  DConnectApiSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApiSpecBuilder.h"

@interface DConnectApiSpecBuilder()

@property NSString *mName;

@property DConnectApiSpecType mType;

@property DConnectApiSpecMethod mMethod;

@property NSString *mPath;

@property NSArray *mRequestParamSpecList;



@end


@implementation DConnectApiSpecBuilder

- (id) init {
    
    self = [super init];
    
    if (self) {
        self.mName = nil;
        self.mType = GET;
        self.mMethod = ONESHOT;
        self.mPath = nil;
        self.mRequestParamSpecList = nil;
    }
    
    return self;
}

- (id)name: (NSString *)name {
    self.mName = name;
    return self;
}

- (id)type: (DConnectApiSpecType)type {
    self.mType = type;
    return self;
}

- (id)method: (DConnectApiSpecMethod)method {
    self.mMethod = method;
    return self;
}

- (id)path: (NSString *)path {
    self.mPath = path;
    return self;
}

- (id)requestParamSpecList: (NSArray *)requestParamSpecList {
    self.mRequestParamSpecList = requestParamSpecList;
    return self;
}

- (DConnectApiSpec *) build {
    DConnectApiSpec *apiSpec = [[DConnectApiSpec alloc] init];
    [apiSpec setName: self.mName];
    [apiSpec setType: self.mType];
    [apiSpec setMethod: self.mMethod];
    [apiSpec setPath: self.mPath];
    [apiSpec setRequestParamSpecList: self.mRequestParamSpecList];
    return apiSpec;
}

@end
