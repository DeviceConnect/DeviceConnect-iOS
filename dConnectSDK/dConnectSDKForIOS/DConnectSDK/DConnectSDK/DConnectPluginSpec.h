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

@interface DConnectPluginSpec : NSObject

/*!
 @brief 入力ファイルからDevice Connectプロファイルの仕様定義を追加する.
 
 @param[in] profileName プロファイル名
 @param[in] filename 入力ファイル
 @retval YES 追加成功。
 @retval NO 追加失敗。API仕様定義JSONファイル解析に失敗等。
 */
- (BOOL) addProfileSpec: (NSString *) profileName;
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
 */
- (NSString *) loadFile: (NSString *) profileName;

@end
