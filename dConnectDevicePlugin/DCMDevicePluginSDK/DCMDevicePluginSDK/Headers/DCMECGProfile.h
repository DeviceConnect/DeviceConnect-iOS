//
//  DCMECGProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @file
 @brief ECGプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectSDK.h>



/*!
 @brief プロファイル名: ecg。
 */
extern NSString *const DCMECGProfileName;

/*!
 @brief アトリビュート: onECG。
 */
extern NSString *const DCMECGProfileAttrOnECG;


/*!
 @brief パラメータ: ecg。
 */
extern NSString *const DCMECGProfileParamECG;

/*!
 @brief パラメータ: value。
 */
extern NSString *const DCMECGProfileParamValue;

/*!
 @brief パラメータ: mderFloat。
 */
extern NSString *const DCMECGProfileParamMDERFloat;

/*!
 @brief パラメータ: type。
 */
extern NSString *const DCMECGProfileParamType;

/*!
 @brief パラメータ: typeCode。
 */
extern NSString *const DCMECGProfileParamTypeCode;

/*!
 @brief パラメータ: unit。
 */
extern NSString *const DCMECGProfileParamUnit;

/*!
 @brief パラメータ: unitCode。
 */
extern NSString *const DCMECGProfileParamUnitCode;

/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DCMECGProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DCMECGProfileParamTimeStampString;

@class DCMECGProfile;



/*!
 @class DCMECGProfile
 @brief ECGプロファイル。
 
 ECG Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMECGProfile : DConnectProfile

#pragma mark - Setters
/*!
 @brief メッセージにECGRate情報を設定する。
 @param[in] ECG ECGRate情報
 @param[in,out] message ECGRate情報を格納するメッセージ
 */
+ (void) setECG:(DConnectMessage *)ecg target:(DConnectMessage *)message;



/*!
 @brief メッセージに健康機器の計測値を設定する。
 @param[in] value 健康機器の計測値
 @param[in,out] message 健康機器の計測値を格納するメッセージ
 */
+ (void) setValue:(double)value target:(DConnectMessage *)message;

/*!
 @brief メッセージにMDERFloat値を設定する。
 
 @param[in] mderFloat MDERFloat値
 @param[in,out] message MDERFloat値を格納するメッセージ
 */
+ (void) setMDERFloat:(NSString*)mderFloat target:(DConnectMessage *)message;


/*!
 @brief メッセージに健康機器の計測値のタイプを設定する。
 
 @param[in] type 健康機器の計測値のタイプ
 @param[in,out] message 健康機器の計測値のタイプを格納するメッセージ
 */
+ (void) setType:(NSString*)type target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器の計測値のタイプコードを設定する。
 
 @param[in] typeCode 健康機器の計測値のタイプコード
 @param[in,out] message 健康機器の計測値のタイプコードを格納するメッセージ
 */
+ (void) setTypeCode:(int)typeCode target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器の計測値の単位を設定する。
 
 @param[in] unit 健康機器の計測値の単位
 @param[in,out] message 健康機器の計測値の単位を格納するメッセージ
 */
+ (void) setUnit:(NSString*)unit target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器の計測値の単位コードを設定する。
 
 @param[in] unitCode 健康機器の計測値の単位コード
 @param[in,out] message 健康機器の計測値の単位コードを格納するメッセージ
 */
+ (void) setUnitCode:(int)unitCode target:(DConnectMessage *)message;

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
