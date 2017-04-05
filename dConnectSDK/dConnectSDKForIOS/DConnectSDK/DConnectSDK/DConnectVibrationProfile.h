//
//  DConnectVibrationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! 
 @file
 @brief Vibrationプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名: vibration。
 */
extern NSString *const DConnectVibrationProfileName;

/*!
 @brief アトリビュート: vibrate。
 */
extern NSString *const DConnectVibrationProfileAttrVibrate;

/*!
 @brief パラメータ: pattern。
 */
extern NSString *const DConnectVibrationProfileParamPattern;

/*!
 @brief 振動パターンで使われる区切り文字。
 */
extern NSString *const DConnectVibrationProfileVibrationDurationDelim;

/*!
 @brief デフォルトの最大バイブレーション鳴動時間。 500 ミリ秒。
 */
extern const long long DConnectVibrationProfileDefaultMaxVibrationTime;

/*!
 @class DConnectVibrationProfile
 @brief Vibrationプロファイル。
 
 Vibration Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectVibrationProfile : DConnectProfile

/*!
 @brief バイブレーションの最大鳴動時間。
 
 バイブレーションのパターンが省略された場合、自動的にデフォルト値として適用される。<br/>
 デバイスごとに適切な数値を設定すること。
 デフォルトでは @link DConnectVibrationProfileDefaultMaxVibrationTime @endlink が設定される。
 */
@property (nonatomic, assign) long long maxVibrationTime;

#pragma mark - Getter

/*!
 @brief リクエストから鳴動パターンを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval NSString* 鳴動パターンの文字列
 @retval nil リクエストに鳴動パターンが指定されていない場合
 */
+ (NSString *) patternFromRequest:(DConnectMessage *)request;

#pragma mark - Utility

/*!
 @brief 鳴動パターンを文字列から解析し、数値の配列に変換する。
 
 数値の前後の半角のスペースは無視される。その他の半角、全角のスペースは不正なフォーマットとして扱われる。
 
 @param[in] pattern 鳴動パターン文字列。
 
 @retval NSArray* 鳴動パターンの配列
 @retval nil 鳴動パターンが解析できない場合
 */
- (NSArray *) parsePattern:(NSString *)pattern;

@end
