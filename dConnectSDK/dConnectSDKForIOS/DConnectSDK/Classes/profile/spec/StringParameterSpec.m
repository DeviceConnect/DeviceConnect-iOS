//
//  StringParameterSpec.m
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "StringParameterSpec.h"

@implementation StringParameterSpec

- (instancetype) initWithDataFormat:(DConnectSpecDataFormat)dataFormat {

    self = [super initWitDataSpec: [[StringDataSpec alloc] initWitDataFormat: dataFormat]];
    return self;
}

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format {
    return [[self stringDataSpec] format];
}

/*!
 @brief 文字列の最大長を取得する.
 @return 文字列の最大長
 */
- (int) maxLength {
    return [[self stringDataSpec] maxLength];
}

/*!
 @brief 文字列の最大長を設定する.
 @param maxLength 文字列の最大長
 */
- (void) setMaxLength: (int) maxLength {
    [[self stringDataSpec] setMaxLength: maxLength];
}

/*!
 @brief 文字列の最小長を取得する.
 @return 文字列の最小長
 */
- (int) minLength {
    return [[self stringDataSpec] minLength];
}

/*!
 @brief 文字列の最小長を設定する.
 @param minLength 文字列の最小長
 */
- (void) setMinLength: (int) minLength {
    [[self stringDataSpec] setMinLength: minLength];
}

/*!
 @brief 定数一覧を取得する.
 @return 定数の配列
 */
- (NSArray *) enumList {
    return [[self stringDataSpec] enumList];
}

/*!
 @brief 定数一覧を設定する.
 @param enumList 定数の配列
 */
- (void) setEnumList: (NSArray *) enumList {
    return [[self stringDataSpec] setEnumList: enumList];
}

#pragma mark - Private Methods.

- (StringDataSpec *) stringDataSpec {
    return (StringDataSpec *)[self dataSpec];
}

@end
