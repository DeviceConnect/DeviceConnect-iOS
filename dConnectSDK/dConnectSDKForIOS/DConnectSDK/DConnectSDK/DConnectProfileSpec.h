//
//  DConnectProfileSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectApiSpec.h"
#import "DConnectSpecConstants.h"
#import "DConnectProfileSpec.h"

/*!
 @class DConnectProfileSpec
 @brief プロファイルについての仕様を保持するクラス。
 
 当該プロファイル上で定義されるAPIの仕様のリストを持つ。
 */
@interface DConnectProfileSpec : NSObject

/*!
 @brief API仕様定義ファイルの元データ。
 */
@property (nonatomic, strong) NSDictionary * bundle;

/*!
 @brief API名。
 */
@property (nonatomic, strong) NSString * api;

/*!
 @brief プロファイル名.
 */
@property (nonatomic, strong) NSString * profile;

/*!
 @brief 当該プロファイルのもつDConnectApiSpec一覧。
 */
@property (nonatomic, strong) NSMutableDictionary * allApiSpecs;    // Map<String, Map<Method, DConnectApiSpec>>


/*!
 @brief 当該プロファイル上で定義されている、APIの仕様定義のリストを取得する.
 @return {@link DConnectApiSpec}のリスト
 */
- (NSArray *) apiSpecList;

/**
 @brief 指定されたパスで提供されるAPIの仕様定義のマップを取得する.
 @param path APIのパス
 @return {@link DConnectApiSpec}のマップ. キーはメソッド名.
         指定されたパスで提供しているAPIが存在しない場合は<code>null</code>
 */
- (NSDictionary *) findApiSpecs: (NSString *) path;

/*!
 @brief 指定されたパスとメソッドで提供されるAPIの仕様定義を取得する.
 @param path APIのパス
 @param method APIのメソッド名
 @return {@link DConnectApiSpec}のインスタンス.
         指定されたパスとメソッドで提供しているAPIが存在しない場合は<code>null</code>
 */
- (DConnectApiSpec *) findApiSpec: (NSString *)path method: (DConnectSpecMethod) method;

/*!
 @brief API仕様定義ファイルから生成したBundleのインスタンスを取得する.
 @return Bundleのインスタンス
 */
- (NSDictionary *) toBundle;

@end


