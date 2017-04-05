//
//  DConnectPluginSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectProfileSpec.h"

/*!
 @class DConnectPluginSpec
 @brief プラグインのサポートする仕様を保持するクラス。
 
 プラグインのサポートするプロファイルのリストを持つ。
 */
@interface DConnectPluginSpec : NSObject

/*!
 @brief DConnectPluginSpecのシングルトンを返す.
 */
+ (DConnectPluginSpec *) shared;

/*!
 @brief 入力ファイルからDevice Connectプロファイルの仕様定義を追加する.
 
 @param[in] profileName プロファイル名
 @param[in] selfBundle 独自拡張プロファイルのSwaggerJsonファイルをデバイスプラグインのBundleから提供する場合は、そのBundleを渡す。渡す必要がなければnilを渡す。
 @retval YES 追加成功。
 @retval NO 追加失敗。API仕様定義JSONファイル解析に失敗等。
 */
- (BOOL) addProfileSpec: (NSString *) profileName bundle: (NSBundle *) selfBundle error: (NSError **) error;

/*!
 @brief 指定したプロファイルの仕様定義を取得する.
 @param profileName プロファイル名
 @return {@link DConnectProfileSpec}のインスタンス
 */
- (DConnectProfileSpec *) findProfileSpec: (NSString *) profileName;

/*!
 @brief プラグインのサポートするプロファイルの仕様定義の一覧を取得する.
 <p>
 このメソッドから返される一覧には、各プロファイル上で定義されているすべてのAPIの定義が含まれる.
 </p>
 @return {@link DConnectProfileSpec}のマップ. キーはプロファイル名.Map<String, DConnectProfileSpec>
 */
- (NSDictionary *) profileSpecs;


/*!
 @brief profileSpecJSONファイルを読み込み
 @param[in] プロファイル名
 @param[in] デバイスプラグインのBundle(独自拡張プロファイルのSwaggerJsonがデバイスプラグインのBundleに含まれる場合にそのBundleを渡す。渡す必要がなければnilを渡す)
 */
- (NSString *) loadFile: (NSString *) profileName bundle: (NSBundle *) selfBundle;

@end
