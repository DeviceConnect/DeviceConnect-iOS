//
//  DConnectProfileSpecBuilder.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectProfileSpecBuilder.h"

@implementation DConnectProfileSpecBuilder

- (instancetype) init {
    
    self = [super init];
    if (self) {
        self.allApiSpecs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL) addApiSpec: (NSString *) path method: (DConnectSpecMethod) method apiSpec: (DConnectApiSpec *) apiSpec error: (NSError **) error {
    NSString *pathKey = [path lowercaseString];
    NSMutableDictionary *apiSpecs = [self allApiSpecs][pathKey];        // Map<Method, DConnectApiSpec>
    if (!apiSpecs) {
        apiSpecs = [NSMutableDictionary dictionary];                    // HashMap<Method, DConnectApiSpec>
        [self allApiSpecs][pathKey] = apiSpecs;
    }
    NSString *strMethod = [DConnectSpecConstants toMethodString: method error: error];
    if (!strMethod) {
        return NO;
    }
    apiSpecs[strMethod] = apiSpec;
    return YES;
}

/**
 * {@link DConnectProfileSpec}のインスタンスを生成する.
 *
 * @return {@link DConnectProfileSpec}のインスタンス
 */
- (DConnectProfileSpec *) build {
    DConnectProfileSpec *profileSpec = [[DConnectProfileSpec alloc] init];
    [profileSpec setAllApiSpecs: [self allApiSpecs]];
    [profileSpec setBundle: [self bundle]];
    [profileSpec setApi:[self api] ? [self api] : DConnectMessageDefaultAPI];
    [profileSpec setProfile:[self profile]];
    return profileSpec;
}

@end
