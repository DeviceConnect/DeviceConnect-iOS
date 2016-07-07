//
//  DConnectApi.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectApi.h"

@interface DConnectApi()

// DConnectApiの子クラスから渡されるメソッド.
@property DConnectApiSpecMethod mMethod;

// DConnectApiの子クラスで実装されるAPI仕様.
@property DConnectApiSpec *mApiSpec;






@end


@implementation DConnectApi

- (instancetype) initWithMethod: (DConnectApiSpecMethod) method {
    self = [super init];
    if (self) {
        // 初期値設定
        self.mMethod = method;
    }
    return self;
}


- (NSString *) interface {
    return nil;
}

- (NSString *) attribute {
    return nil;
}

- (DConnectApiSpecMethod) method {
    return self.mMethod;
}

- (DConnectApiSpec *) apiSpec {
    return self.mApiSpec;
}

- (void) setApiSpec: (DConnectApiSpec *) apiSpec {
    self.mApiSpec = apiSpec;
}

@end
