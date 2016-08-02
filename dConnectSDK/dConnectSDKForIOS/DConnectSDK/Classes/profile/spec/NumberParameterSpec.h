//
//  NumberParameterSpec.h
//  DConnectSDK
//
//  Created by Mitsuhiro Suzuki on 2016/08/02.
//  Copyright © 2016年 NTT DOCOMO, INC. All rights reserved.
//

#import "NumberDataSpec.h"

@interface NumberParameterSpec : NumberDataSpec

- (instancetype) initWithDataType:(DConnectSpecDataType)dataType;

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format;

/*!
 @brief 最大値を取得する.
 @return 最大値
 */
- (double) maximum;

/*!
 @brief 最大値を設定する.
 @param maximum 最大値
 */
- (void) setMaximum: (double) maximum;

/*!
 @brief 最小値を取得する.
 @return 最小値
 */
- (double) minimum;

/*!
 @brief 最小値を設定する.
 @param minimum 最小値
 */
- (void) setMinimum: (double) minimum;

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

@end
