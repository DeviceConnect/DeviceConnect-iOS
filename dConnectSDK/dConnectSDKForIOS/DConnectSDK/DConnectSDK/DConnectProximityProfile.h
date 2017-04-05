//
//  DConnectProximityProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Proximityプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名: proximity。
 */
extern NSString *const DConnectProximityProfileName;

/*!
 @brief アトリビュート: ondeviceproximity。
 */

extern NSString *const DConnectProximityProfileAttrOnDeviceProximity;

/*!
 @brief アトリビュート: onuserproximity。
 */
extern NSString *const DConnectProximityProfileAttrOnUserProximity;

/*!
 @brief パラメータ: value。
 */
extern NSString *const DConnectProximityProfileParamValue;

/*!
 @brief パラメータ: min。
 */
extern NSString *const DConnectProximityProfileParamMin;

/*!
 @brief パラメータ: max。
 */
extern NSString *const DConnectProximityProfileParamMax;

/*!
 @brief パラメータ: threshold。
 */
extern NSString *const DConnectProximityProfileParamThreshold;

/*!
 @brief パラメータ: proximity。
 */
extern NSString *const DConnectProximityProfileParamProximity;

/*!
 @brief パラメータ: near。
 */
extern NSString *const DConnectProximityProfileParamNear;

/*!
 @brief パラメータ: range。
 */
extern NSString *const DConnectProximityProfileParamRange;

extern NSString *const DConnectProximityProfileRangeImmediate;
extern NSString *const DConnectProximityProfileRangeNear;
extern NSString *const DConnectProximityProfileRangeFar;
extern NSString *const DConnectProximityProfileRangeUnknown;;

/*!
 @class DConnectProximityProfile
 @brief Proximityプロファイル。
 
 Proximity Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectProximityProfile : DConnectProfile

#pragma mark - Setter

/*!
 @brief メッセージに近接距離を設定する。
 
 @param[in] value 近接距離
 @param[in,out] message 近接距離を格納するメッセージ
 */
+ (void) setValue:(double)value target:(DConnectMessage *)message;

/*!
 @brief メッセージに近接距離の最小値を設定する。
 
 @param[in] min 最小値
 @param[in,out] message 近接距離の最小値を格納するメッセージ
 */
+ (void) setMin:(double)min target:(DConnectMessage *)message;

/*!
 @brief メッセージに近接距離の最大値を設定する。
 
 @param[in] max 最大値
 @param[in,out] message 近接距離の最大値を格納するメッセージ
 */
+ (void) setMax:(double)max target:(DConnectMessage *)message;

/*!
 @brief メッセージに近接距離の閾値を設定する。
 
 @param[in] threshold 閾値
 @param[in,out] message 近接距離の閾値を格納するメッセージ
 */
+ (void) setThreshold:(double)threshold target:(DConnectMessage *)message;

/*!
 @brief メッセージに近接センサー情報を設定する。
 
 @param[in] proximity 近接センサー情報
 @param[in,out] message 近接センサー情報を格納するメッセージ
 */
+ (void) setProximity:(DConnectMessage *)proximity target:(DConnectMessage *)message;

/*!
 @brief メッセージに近接センサー情報を設定する。
 
 @param[in] near 近接の有無。YESの場合近接中、その他はNO
 @param[in,out] message 近接センサー情報を格納するメッセージ
 */
+ (void) setNear:(BOOL)near target:(DConnectMessage *)message;

/*!
 @brief メッセージにRange情報を設定する。
 
 @param[in] rage 距離に応じた文字列。(IMMEDIATE,NEAR,FAR,UNKNOWN)
 @param[in,out] message Range情報を格納するメッセージ
 */
+ (void) setRange:(NSString *)range target:(DConnectMessage *)message;

@end
