//
//  IntegerParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectIntegerParameterSpec.h"
#import "DConnectIntegerDataSpec.h"

@implementation DConnectIntegerParameterSpec

- (instancetype) initWithDataFormat: (DConnectSpecDataFormat) dataFormat {
    self = [super initWithDataSpec: [[DConnectIntegerDataSpec alloc] initWithFormat: dataFormat]];
    return self;
}

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format {
    return [[self integerDataSpec] format];
}

/*!
 @brief 最大値を取得する.
 @return 最大値
 */
- (long) maximum {
    return [[[self integerDataSpec] maximum] longValue];
}

/*!
 @brief 最大値を設定する.
 @param maximum 最大値
 */
- (void) setMaximum: (long) maximum {
    [[self integerDataSpec] setMaximum: [NSNumber numberWithLong: maximum]];
}

/*!
 @brief 最小値を取得する.
 @return 最小値
 */
- (long) minimum {
    return [[[self integerDataSpec] minimum] longValue];
}

/*!
 @brief 最小値を設定する.
 @param[in] minimum 最小値
 */
- (void) setMinimum: (long) minimum {
    [[self integerDataSpec] setMinimum: [NSNumber numberWithLong: minimum]];
}

/*!
 @brief 最大値自体を指定可能かどうかのフラグを取得する.
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMaximum {
    return [[self integerDataSpec] exclusiveMaximum];
}

/*!
 @brief 最大値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMaximum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMaximum: (BOOL) exclusiveMaximum {
    [[self integerDataSpec] setExclusiveMaximum: exclusiveMaximum];
}

/*!
 @brief 最小値自体を指定可能かどうかのフラグを取得する
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMinimum {
    return [[self integerDataSpec] exclusiveMinimum];
}

/*!
 @brief 最小値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMinimum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMinimum: (BOOL) exclusiveMinimum {
    [[self integerDataSpec] setExclusiveMinimum: exclusiveMinimum];
}

/*!
 @brief 定数一覧を取得する.
 @return 定数の配列
 */
- (NSArray *) enumList {
    return [[self integerDataSpec] enumList];
}

/*!
 @brief 定数一覧を設定する.
 @param enumList 定数の配列
 */
- (void) setEnumList: (NSArray *) enumList {
    [[self integerDataSpec] setEnumList: enumList];
}

#pragma mark - Private Methods.

- (DConnectIntegerDataSpec *) integerDataSpec {
    return (DConnectIntegerDataSpec *)[self dataSpec];
}


@end
