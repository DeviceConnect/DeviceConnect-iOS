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

/**
 * APIの仕様定義を追加する.
 *
 * @param path パス
 * @param method メソッド
 * @param apiSpec 仕様定義
 */
- (void) addApiSpec: (NSString *) path method: (DConnectSpecMethod) method apiSpec: (DConnectApiSpec *) apiSpec {
    NSString *pathKey = [path lowercaseString];
    NSMutableDictionary *apiSpecs = [self allApiSpecs][pathKey];        // Map<Method, DConnectApiSpec>
    if (!apiSpecs) {
        apiSpecs = [NSMutableDictionary dictionary];                    // HashMap<Method, DConnectApiSpec>
        [self allApiSpecs][pathKey] = apiSpecs;
    }
    NSString *strMethod = [DConnectSpecConstants toMethodString: method];
    apiSpecs[strMethod] = apiSpec;
}

/**
 * {@link DConnectProfileSpec}のインスタンスを生成する.
 *
 * @return {@link DConnectProfileSpec}のインスタンス
 */
- (DConnectProfileSpec *) build {
    DConnectProfileSpec *profileSpec = [[DConnectProfileSpec alloc] init];
    [profileSpec setApiSpecs: [self allApiSpecs]];
    [profileSpec setBundle: [self bundle]];
    return profileSpec;
}

@end
