//
//  DConnectStringParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectStringParameterSpec.h"
#import "DConnectStringDataSpec.h"
#import "DConnectDataSpec.h"

@implementation DConnectStringParameterSpec

- (instancetype) initWithDataFormat:(DConnectSpecDataFormat)dataFormat {

    DConnectStringDataSpec *stringDataSpec = [[DConnectStringDataSpec alloc] initWitDataFormat: dataFormat];
    self = [super initWithDataSpec: stringDataSpec];
    return self;
}

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format {
    return [[self stringDataSpec] dataFormat];
}

/*!
 @brief 文字列の最大長を取得する.
 @return 文字列の最大長
 */
- (NSNumber *) maxLength {
    return [[self stringDataSpec] maxLength];
}

/*!
 @brief 文字列の最大長を設定する.
 @param maxLength 文字列の最大長
 */
- (void) setMaxLength: (NSNumber *) maxLength {
    [[self stringDataSpec] setMaxLength: maxLength];
}

/*!
 @brief 文字列の最小長を取得する.
 @return 文字列の最小長
 */
- (NSNumber *) minLength {
    return [[self stringDataSpec] minLength];
}

/*!
 @brief 文字列の最小長を設定する.
 @param minLength 文字列の最小長
 */
- (void) setMinLength: (NSNumber *) minLength {
    [[self stringDataSpec] setMinLength: minLength];
}

/*!
 @brief 定数一覧を取得する.
 @return 定数の配列
 */
- (NSArray *) enums {
    return [[self stringDataSpec] enums];
}

/*!
 @brief 定数一覧を設定する.
 @param enumList 定数の配列
 */
- (void) setEnums: (NSArray *) enums {
    return [[self stringDataSpec] setEnums: enums];
}

#pragma mark - Private Methods.

- (DConnectStringDataSpec *) stringDataSpec {

    return (DConnectStringDataSpec *)[self dataSpec];
}

@end
