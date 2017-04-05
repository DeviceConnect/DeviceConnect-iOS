//
//  DConnectBatteryProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Batteryプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectBatteryProfileName;

/*!
 @brief アトリビュート: charging。
 */
extern NSString *const DConnectBatteryProfileAttrCharging;

/*!
 @brief アトリビュート: chargingTime。
 */
extern NSString *const DConnectBatteryProfileAttrChargingTime;

/*!
 @brief アトリビュート: dischargingTime。
 */
extern NSString *const DConnectBatteryProfileAttrDischargingTime;

/*!
 @brief アトリビュート: level。
 */
extern NSString *const DConnectBatteryProfileAttrLevel;

/*!
 @brief アトリビュート: onchargingchange。
 */
extern NSString *const DConnectBatteryProfileAttrOnChargingChange;

/*!
 @brief アトリビュート: onbatterychange。
 */
extern NSString *const DConnectBatteryProfileAttrOnBatteryChange;

/*!
 @brief パラメータ: charing。
 */
extern NSString *const DConnectBatteryProfileParamCharging;

/*!
 @brief パラメータ: chargingTime。
 */
extern NSString *const DConnectBatteryProfileParamChargingTime;

/*!
 @brief パラメータ: dischargingTime。
 */
extern NSString *const DConnectBatteryProfileParamDischargingTime;

/*!
 @brief パラメータ: level。
 */
extern NSString *const DConnectBatteryProfileParamLevel;

/*!
 @brief パラメータ: battery。
 */
extern NSString *const DConnectBatteryProfileParamBattery;

/*!
 @class DConnectBatteryProfile
 @brief Batteryプロファイル。
 
 Battery Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectBatteryProfile : DConnectProfile

#pragma mark - Setters

/*!
 @brief メッセージにバッテリーレベルを設定する。
 
 バッテリーレベルは、0.0〜1.0の範囲になる。
 @par
 - 0.0の場合は残量なし。
 - 1.0の場合はフル充電。
 
 @param[in] level バッテリーレベル(0〜1.0)
 @param[in,out] message バッテリーレベルを格納するメッセージ
 */
+ (void) setLevel:(double)level target:(DConnectMessage *)message;

/*!
 @brief メッセージにバッテリー充電中フラグを設定する。
 @param[in] charging 充電中はYES、それ以外はNO
 @param[in,out] message バッテリー充電中フラグを格納するメッセージ
 */
+ (void) setCharging:(BOOL)charging target:(DConnectMessage *)message;

/*!
 @brief メッセージにバッテリーの充電時間を設定する。
 @param[in] chargingTime 充電時間(秒)
 @param[in,out] message バッテリー充電時間を格納するメッセージ
 */
+ (void) setChargingTime:(double)chargingTime target:(DConnectMessage *)message;

/*!
 @brief メッセージにバッテリーの放電時間を設定する。
 @param[in] dischargingTime 放電時間(秒)
 @param[in,out] message バッテリー法電磁間を格納するメッセージ
 */
+ (void) setDischargingTime:(double)dischargingTime target:(DConnectMessage *)message;

/*!
 @brief メッセージにバッテリー情報を設定する。
 @param[in] battery バッテリー情報
 @param[in,out] message バッテリー情報を格納するメッセージ
 */
+ (void) setBattery:(DConnectMessage *)battery target:(DConnectMessage *)message;

@end
