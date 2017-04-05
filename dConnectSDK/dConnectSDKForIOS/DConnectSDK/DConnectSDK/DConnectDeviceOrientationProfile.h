//
//  DConnectDeviceOrientationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Device Orientationプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectDeviceOrientationProfileName;

/*!
 @brief アトリビュート: ondeviceorientation。
 */
extern NSString *const DConnectDeviceOrientationProfileAttrOnDeviceOrientation;

/*!
 @brief パラメータ: orientation。
 */
extern NSString *const DConnectDeviceOrientationProfileParamOrientation;

/*!
 @brief パラメータ: acceleration。
 */
extern NSString *const DConnectDeviceOrientationProfileParamAcceleration;

/*!
 @brief パラメータ: x。
 */
extern NSString *const DConnectDeviceOrientationProfileParamX;

/*!
 @brief パラメータ: y。
 */
extern NSString *const DConnectDeviceOrientationProfileParamY;

/*!
 @brief パラメータ: z。
 */
extern NSString *const DConnectDeviceOrientationProfileParamZ;

/*!
 @brief パラメータ: rotationRate。
 */
extern NSString *const DConnectDeviceOrientationProfileParamRotationRate;

/*!
 @brief パラメータ: alpha。
 */
extern NSString *const DConnectDeviceOrientationProfileParamAlpha;

/*!
 @brief パラメータ: beta。
 */
extern NSString *const DConnectDeviceOrientationProfileParamBeta;

/*!
 @brief パラメータ: gamma。
 */
extern NSString *const DConnectDeviceOrientationProfileParamGamma;

/*!
 @brief パラメータ: interval。
 */
extern NSString *const DConnectDeviceOrientationProfileParamInterval;

/*!
 @brief パラメータ: accelerationIncludingGravity。
 */
extern NSString *const DConnectDeviceOrientationProfileParamAccelerationIncludingGravity;

/*!
 @class DConnectDeviceOrientationProfile
 @brief Device Orientationプロファイル。
 
 Device Orientation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectDeviceOrientationProfile : DConnectProfile

#pragma mark - Setters

/*!
 @brief メッセージに計測のインターバルを設定する。
 @param[in] interval 計測のインターバル(ミリ秒)
 @param[in,out] message インターバルを格納するメッセージ
 */
+ (void) setInterval:(long long)interval target:(DConnectMessage *)message;

/*!
 @brief メッセージにオリエンテーション情報を設定する。
 @param[in] orientation オリエンテーション情報
 @param[in,out] message オリエンテーション情報を格納するメッセージ
 */
+ (void) setOrientation:(DConnectMessage *)orientation target:(DConnectMessage *)message;

/*!
 @brief メッセージに加速度情報を設定する。
 @param[in] acceleration 加速度情報
 @param[in,out] message 加速度情報を格納するメッセージ
 */
+ (void) setAcceleration:(DConnectMessage *)acceleration target:(DConnectMessage *)message;

/*!
 @brief メッセージに重力込み加速度情報を設定する。
 @param[in] accelerationIncludingGravity 重力込み加速度情報
 @param[in,out] message 重力込み加速度情報を格納するメッセージ
 */
+ (void) setAccelerationIncludingGravity:(DConnectMessage *)accelerationIncludingGravity target:(DConnectMessage *)message;

/*!
 @brief メッセージに角速度情報を設定する。
 @param[in] rotationRate 角速度情報
 @param[in,out] message 角速度情報を格納するメッセージ
 */
+ (void) setRotationRate:(DConnectMessage *)rotationRate target:(DConnectMessage *)message;

/*!
 @brief メッセージにx軸方向の加速度、または重力加速度を設定する。
 @param[in] x x軸方向の加速度、または重力加速度
 @param[in,out] message x軸方向の加速度、または重力加速度を格納するメッセージ
 */
+ (void) setX:(double)x target:(DConnectMessage *)message;

/*!
 @brief メッセージにy軸方向の加速度、または重力加速度を設定する。
 @param[in] y y軸方向の加速度、または重力加速度
 @param[in,out] message y軸方向の加速度、または重力加速度を格納するメッセージ
 */
+ (void) setY:(double)y target:(DConnectMessage *)message;

/*!
 @brief メッセージにz軸方向の加速度、または重力加速度を設定する。
 @param[in] z z軸方向の加速度、または重力加速度
 @param[in,out] message z軸方向の加速度、または重力加速度を格納するメッセージ
 */
+ (void) setZ:(double)z target:(DConnectMessage *)message;

/*!
 @brief メッセージにz軸周り角速度を設定する。
 @param[in] alpha z軸周り角速度(degree/s)
 @param[in,out] message z軸周り角速度を格納するメッセージ
 */
+ (void) setAlpha:(double)alpha target:(DConnectMessage *)message;

/*!
 @brief メッセージにx軸周り角速度を設定する。
 @param[in] beta x軸周り角速度(degree/s)
 @param[in,out] message x軸周り角速度を格納するメッセージ
 */
+ (void) setBeta:(double)beta target:(DConnectMessage *)message;

/*!
 @brief メッセージにy軸周り角速度を設定する。
 @param[in] gamma y軸周り角速度(degree/s)
 @param[in,out] message y軸周り角速度を格納するメッセージ
 */
+ (void) setGamma:(double)gamma target:(DConnectMessage *)message;

@end
