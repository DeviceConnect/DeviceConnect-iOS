//
//  StringParameterSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "StringDataSpec.h"

@interface StringParameterSpec : StringDataSpec

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
- (int) maxLength;

/*!
 @brief 文字列の最大長を設定する.
 @param maxLength 文字列の最大長
 */
- (void) setMaxLength: (int) maxLength;

/*!
 @brief 文字列の最小長を取得する.
 @return 文字列の最小長
 */
- (int) minLength;

/*!
 @brief 文字列の最小長を設定する.
 @param minLength 文字列の最小長
 */
- (void) setMinLength: (int) minLength;

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
