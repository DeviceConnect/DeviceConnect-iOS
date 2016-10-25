//
//  DConnectStringParameterSpec.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringDataSpec.h"
#import "DConnectParameterSpec.h"

@interface DConnectStringParameterSpec : DConnectParameterSpec

- (instancetype) initWithDataFormat:(DConnectSpecDataFormat)dataFormat;

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format;

/*!
 @brief 文字列の最大長を取得する.
 @return 文字列の最大長
 */
- (NSNumber *) maxLength;

/*!
 @brief 文字列の最大長を設定する.
 @param maxLength 文字列の最大長
 */
- (void) setMaxLength: (NSNumber *) maxLength;

/*!
 @brief 文字列の最小長を取得する.
 @return 文字列の最小長
 */
- (NSNumber *) minLength;

/*!
 @brief 文字列の最小長を設定する.
 @param minLength 文字列の最小長
 */
- (void) setMinLength: (NSNumber *) minLength;

/*!
 @brief 定数一覧を取得する.
 @return 定数の配列
 */
- (NSArray *) enums;

/*!
 @brief 定数一覧を設定する.
 @param enums 定数の配列
 */
- (void) setEnums: (NSArray *) enums;


@end
