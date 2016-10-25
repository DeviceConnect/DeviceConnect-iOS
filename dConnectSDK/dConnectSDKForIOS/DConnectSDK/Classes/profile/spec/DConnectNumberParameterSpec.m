//
//  DConnectNumberParameterSpec.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNumberParameterSpec.h"

@implementation DConnectNumberParameterSpec

- (instancetype) initWithDataFormat:(DConnectSpecDataFormat)dataFormat {
    
    self = [super initWithDataSpec: [[DConnectNumberDataSpec alloc] initWithDataFormat: dataFormat]];
    return self;
}

/*!
 @brief データのフォーマット指定を取得する.
 @return データのフォーマット指定
 */
- (DConnectSpecDataFormat) format {
    return [[self numberDataSpec] dataFormat];
}

/*!
 @brief 最大値を取得する.
 @return 最大値
 */
- (double) maximum {
    return [[[self numberDataSpec] maximum] doubleValue];
}

/*!
 @brief 最大値を設定する.
 @param maximum 最大値
 */
- (void) setMaximum: (double) maximum {
    [[self numberDataSpec] setMaximum: [NSNumber numberWithDouble:maximum]];
}

/*!
 @brief 最小値を取得する.
 @return 最小値
 */
- (double) minimum {
    return [[[self numberDataSpec] minimum] doubleValue];
}

/*!
 @brief 最小値を設定する.
 @param minimum 最小値
 */
- (void) setMinimum: (double) minimum {
    [[self numberDataSpec] setMinimum: [NSNumber numberWithDouble: minimum]];
}

/*!
 @brief 最大値自体を指定可能かどうかのフラグを取得する.
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMaximum {
    return [[self numberDataSpec] exclusiveMaximum];
}

/*!
 @brief 最大値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMaximum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMaximum: (BOOL) exclusiveMaximum {
    [[self numberDataSpec] setExclusiveMaximum: exclusiveMaximum];
}

/*!
 @brief 最小値自体を指定可能かどうかのフラグを取得する
 @return 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (BOOL) isExclusiveMinimum {
    return [[self numberDataSpec] exclusiveMinimum];
}

/*!
 @brief 最小値自体を指定可能かどうかのフラグを設定する.
 @param exclusiveMinimum 指定できない場合は<code>true</code>. それ以外の場合は<code>false</code>
 */
- (void) setExclusiveMinimum: (BOOL) exclusiveMinimum {
    [[self numberDataSpec] setExclusiveMinimum: exclusiveMinimum];
}

#pragma mark - Private Methods.

- (DConnectNumberDataSpec *) numberDataSpec {
    return (DConnectNumberDataSpec *)[self dataSpec];
}


@end
