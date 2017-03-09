//
//  DConnectProfileSpecBuilder.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpec.h"

@interface DConnectProfileSpecBuilder : NSObject

@property(nonatomic, strong) NSMutableDictionary *allApiSpecs;  // Map<String, Map<Method, DConnectApiSpec>>

@property(nonatomic, strong) NSDictionary *bundle;

@property (nonatomic, strong) NSString * api;

@property (nonatomic, strong) NSString * profile;

/*!
 @brief APIの仕様定義を追加する.
 
 @param path[in] パス
 @param method[in] メソッド
 @param apiSpec[in] 仕様定義
 @param error[out] エラー
 @retval YES 成功
 @retval NO エラー
 */
- (BOOL) addApiSpec: (NSString *) path method: (DConnectSpecMethod) method apiSpec: (DConnectApiSpec *) apiSpec error: (NSError **) error;

- (DConnectProfileSpec *) build;

@end
