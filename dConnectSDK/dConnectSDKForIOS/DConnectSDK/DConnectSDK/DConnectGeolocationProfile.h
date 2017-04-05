//
//  DConnectGeolocationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2017 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Geolocationプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectGeolocationProfileName;

/*!
 @brief アトリビュート: currentPosition。
 */
extern NSString *const DConnectGeolocationProfileAttrCurrentPosition;

/*!
 @brief アトリビュート: onWatchPosition。
 */
extern NSString *const DConnectGeolocationProfileAttrOnWatchPosition;

/*!
 @brief パラメータ: highAccuracy。
 */
extern NSString *const DConnectGeolocationProfileParamHighAccuracy;

/*!
 @brief パラメータ: maximumAge。
 */
extern NSString *const DConnectGeolocationProfileParamMaximumAge;

/*!
 @brief パラメータ: interval。
 */
extern NSString *const DConnectGeolocationProfileParamInterval;

/*!
 @brief パラメータ: position。
 */
extern NSString *const DConnectGeolocationProfileParamPosition;

/*!
 @brief パラメータ: coordinates。
 */
extern NSString *const DConnectGeolocationProfileParamCoordinates;

/*!
 @brief パラメータ: latitude。
 */
extern NSString *const DConnectGeolocationProfileParamLatitude;

/*!
 @brief パラメータ: longitude。
 */
extern NSString *const DConnectGeolocationProfileParamLongitude;

/*!
 @brief パラメータ: altitude。
 */
extern NSString *const DConnectGeolocationProfileParamAltitude;

/*!
 @brief パラメータ: accuracy。
 */
extern NSString *const DConnectGeolocationProfileParamAccuracy;

/*!
 @brief パラメータ: altitudeAccuracy。
 */
extern NSString *const DConnectGeolocationProfileParamAltitudeAccuracy;

/*!
 @brief パラメータ: heading。
 */
extern NSString *const DConnectGeolocationProfileParamHeading;

/*!
 @brief パラメータ: speed。
 */
extern NSString *const DConnectGeolocationProfileParamSpeed;

/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DConnectGeolocationProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DConnectGeolocationProfileParamTimeStampString;


/*!
 @class DConnectGeolocationProfile
 @brief Geolocationプロファイル。
 
 Geolocation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectGeolocationProfile : DConnectProfile

#pragma mark - Getters

/*!
 @brief リクエストデータから測位精度設定を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 測位精度設定。
 @retval false 位置情報有効時間が指定されていない場合
 */
+ (BOOL) highAccuracyFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから位置情報有効時間を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 位置情報有効時間
 @retval nil 位置情報有効時間が指定されていない場合
 */
+ (NSNumber *) maximumAgeFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから情報受信間隔を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 情報受信間隔
 @retval nil 情報受信間隔が指定されていない場合
 */
+ (NSNumber *) intervalFromRequest:(DConnectMessage *)request;

#pragma mark - Setters

/*!
 @brief メッセージに位置情報オブジェクトを設定する。
 @param[in] position 位置情報オブジェクト
 @param[in,out] message 位置情報オブジェクトを格納するメッセージ
 */
+ (void) setPosition:(DConnectMessage *)position target:(DConnectMessage *)message;

/*!
 @brief メッセージに座標を設定する。
 @param[in] coordinates 座標
 @param[in,out] message 座標を格納するメッセージ
 */
+ (void) setCoordinates:(DConnectMessage *)coordinates target:(DConnectMessage *)message;

/*!
 @brief メッセージに緯度を設定する。
 @param[in] latitude 緯度
 @param[in,out] message 緯度を格納するメッセージ
 */
+ (void) setLatitude:(double)latitude target:(DConnectMessage *)message;

/*!
 @brief メッセージに経度を設定する。
 @param[in] longitude 経度
 @param[in,out] message 経度を格納するメッセージ
 */
+ (void) setLongitude:(double)longitude target:(DConnectMessage *)message;

/*!
 @brief メッセージに高度を設定する。
 @param[in] altitude 高度
 @param[in,out] message 高度を格納するメッセージ
 */
+ (void) setAltitude:(double)altitude target:(DConnectMessage *)message;

/*!
 @brief メッセージに緯度・経度の誤差を設定する。
 @param[in] accuracy 緯度・経度の誤差
 @param[in,out] message 緯度・経度の誤差を格納するメッセージ
 */
+ (void) setAccuracy:(double)accuracy target:(DConnectMessage *)message;

/*!
 @brief メッセージに高度の誤差を設定する。
 @param[in] altitudeAccuracy 高度の誤差
 @param[in,out] message 高度の誤差を格納するメッセージ
 */
+ (void) setAltitudeAccuracy:(double)altitudeAccuracy target:(DConnectMessage *)message;

/*!
 @brief メッセージに方角を設定する。
 @param[in] heading 方角
 @param[in,out] message 方角を格納するメッセージ
 */
+ (void) setHeading:(double)heading target:(DConnectMessage *)message;

/*!
 @brief メッセージに速度を設定する。
 @param[in] speed 速度
 @param[in,out] message 速度を格納するメッセージ
 */
+ (void) setSpeed:(double)speed target:(DConnectMessage *)message;

/*!
 @brief メッセージに測位時刻を設定する。
 @param[in] timeStamp 測位時刻
 @param[in,out] message 測位時刻を格納するメッセージ
 */
+ (void) setTimeStamp:(long long)timeStamp target:(DConnectMessage *)message;

/*!
 @brief メッセージに測位時刻 (文字列)を設定する。
 @param[in] timeStampString 測位時刻 (文字列)
 @param[in,out] message 測位時刻 (文字列)を格納するメッセージ
 */
+ (void) setTimeStampString:(NSString*)timeStampString target:(DConnectMessage *)message;

@end
