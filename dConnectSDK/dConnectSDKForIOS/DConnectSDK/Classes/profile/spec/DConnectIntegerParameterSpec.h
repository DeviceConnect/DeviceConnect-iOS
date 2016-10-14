//
//  DConnectIntegerParameterSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectIntegerDataSpec.h"
#import "DConnectParameterSpec.h"

@interface DConnectIntegerParameterSpec : DConnectParameterSpec

- (instancetype) initWithDataFormat: (DConnectSpecDataFormat) dataFormat;

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format;

/*!
 @brief 最大値を取得する.
 @return 最大値
 */
- (long) maximum;

/*!
 @brief 最大値を設定する.
 @param maximum 最大値
 */
- (void) setMaximum: (long) maximum;

/*!
 @brief 最小値を取得する.
 @return 最小値
 */
- (long) minimum;

/*!
 @brief 最小値を設定する.
 @param[in] minimum 最小値
 */
- (void) setMinimum: (long) minimum;

/*!
 @brief 最大値自体を指定可能かどうかのフラグを取得する.
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMaximum;

/*!
 @brief 最大値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMaximum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMaximum: (BOOL) exclusiveMaximum;

/*!
 @brief 最小値自体を指定可能かどうかのフラグを取得する
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMinimum;

/*!
 @brief 最小値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMinimum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMinimum: (BOOL) exclusiveMinimum;

/*!
 @brief 定数一覧を取得する.
 @return 定数の配列
 */
- (NSArray *) enumList;

/*!
 @brief 定数一覧を設定する.
 @param enumList 定数の配列
 */
- (void) setEnumList: (NSArray *) enumList;


@end
