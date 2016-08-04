//
//  StringParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "StringParameterSpec.h"
#import "StringDataSpec.h"
#import "DConnectDataSpec.h"

@implementation StringParameterSpec

- (instancetype) initWithDataFormat:(DConnectSpecDataFormat)dataFormat {

    StringDataSpec *stringDataSpec = [[StringDataSpec alloc] initWitDataFormat: dataFormat];
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
- (int) maxLength {
    return [[[self stringDataSpec] maxLength] intValue];
}

/*!
 @brief 文字列の最大長を設定する.
 @param maxLength 文字列の最大長
 */
- (void) setMaxLength: (int) maxLength {
    [[self stringDataSpec] setMaxLength: [NSNumber numberWithInt: maxLength]];
}

/*!
 @brief 文字列の最小長を取得する.
 @return 文字列の最小長
 */
- (int) minLength {
    return [[[self stringDataSpec] minLength] intValue];
}

/*!
 @brief 文字列の最小長を設定する.
 @param minLength 文字列の最小長
 */
- (void) setMinLength: (int) minLength {
    [[self stringDataSpec] setMinLength: [NSNumber numberWithInt: minLength]];
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
