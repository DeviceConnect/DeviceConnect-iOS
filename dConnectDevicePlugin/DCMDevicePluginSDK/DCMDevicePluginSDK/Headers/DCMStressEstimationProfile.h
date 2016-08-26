//
//  DCMStressEstimationProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: stressEstimation。
 */
extern NSString *const DCMStressEstimationProfileName;

/*!
 @brief アトリビュート: onStressEstimation。
 */
extern NSString *const DCMStressEstimationProfileAttrOnStressEstimation;


/*!
 @brief パラメータ: stress。
 */
extern NSString *const DCMStressEstimationProfileParamStress;

/*!
 @brief パラメータ: lfhf。
 */
extern NSString *const DCMStressEstimationProfileParamLFHF;


/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DCMStressEstimationProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DCMStressEstimationProfileParamTimeStampString;




@class DCMStressEstimationProfile;



/*!
 @class DCMStressEstimationProfile
 @brief StressEstimationプロファイル。
 
 StressEstimation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMStressEstimationProfile : DConnectProfile


#pragma mark - Setters
/*!
 @brief メッセージにStressEstimation情報を設定する。
 @param[in] stress StressEstimation情報
 @param[in,out] message StressEstimation情報を格納するメッセージ
 */
+ (void) setStress:(DConnectMessage *)stress target:(DConnectMessage *)message;



/*!
 @brief メッセージに健康機器のストレス推定値を設定する。
 @param[in] lfhf 健康機器のストレス推定値
 @param[in,out] message 健康機器のストレス推定値を格納するメッセージ
 */
+ (void) setLFHF:(double)lfhf target:(DConnectMessage *)message;


/*!
 @brief メッセージに健康機器の計測値のタイムスタンプを設定する。
 
 @param[in] timeStamp 健康機器の計測値のタイムスタンプ
 @param[in,out] message 健康機器の計測値のタイムスタンプを格納するメッセージ
 */
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器の計測値のタイムスタンプの文字列を設定する。
 
 @param[in] timeStampString 健康機器の計測値のタイムスタンプの文字列
 @param[in,out] message 健康機器の計測値のタイムスタンプの文字列を格納するメッセージ
 */
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message;

@end
