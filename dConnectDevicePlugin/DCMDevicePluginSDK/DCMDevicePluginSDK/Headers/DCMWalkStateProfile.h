//
//  DCMWalkStateProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: walkState。
 */
extern NSString *const DCMWalkStateProfileName;

/*!
 @brief アトリビュート: onWalkState。
 */
extern NSString *const DCMWalkStateProfileAttrOnWalkState;


/*!
 @brief パラメータ: walk。
 */
extern NSString *const DCMWalkStateProfileParamWalk;

/*!
 @brief パラメータ: step。
 */
extern NSString *const DCMWalkStateProfileParamStep;
/*!
 @brief パラメータ: state。
 */
extern NSString *const DCMWalkStateProfileParamState;
/*!
 @brief パラメータ: speed。
 */
extern NSString *const DCMWalkStateProfileParamSpeed;

/*!
 @brief パラメータ: distance。
 */
extern NSString *const DCMWalkStateProfileParamDistance;

/*!
 @brief パラメータ: Balance。
 */
extern NSString *const DCMWalkStateProfileParamBalance;

/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DCMWalkStateProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DCMWalkStateProfileParamTimeStampString;

/*!
 @brief 状態: Stop。
 */
extern NSString *const DCMWalkStateProfileStateStop;
/*!
 @brief 状態: Walking。
 */
extern NSString *const DCMWalkStateProfileStateWalking;
/*!
 @brief 状態: Running。
 */
extern NSString *const DCMWalkStateProfileStateRunning;



/*!
 @class DCMWalkStateProfile
 @brief WalkStateプロファイル。
 
 WalkState Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMWalkStateProfile : DConnectProfile


#pragma mark - Setters
/*!
 @brief メッセージにWalkState情報を設定する。
 @param[in] walk WalkState情報
 @param[in,out] message WalkState情報を格納するメッセージ
 */
+ (void) setWalk:(DConnectMessage *)walk target:(DConnectMessage *)message;


/*!
 @brief メッセージに健康機器の歩数を設定する。
 
 @param[in] step 健康機器の歩数
 @param[in,out] message 健康機器の歩数を格納するメッセージ
 */
+ (void) setStep:(int)step target:(DConnectMessage *)message;
/*!
 @brief メッセージに健康機器の歩行状態を設定する。
 
 @param[in] state 健康機器の歩行状態
 @param[in,out] message 健康機器の歩行状態を格納するメッセージ
 */
+ (void) setState:(NSString*)state target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器の歩行速度を設定する。
 @param[in] speed 健康機器の歩行速度
 @param[in,out] message 健康機器の歩行速度を格納するメッセージ
 */
+ (void) setSpeed:(double)speed target:(DConnectMessage *)message;
/*!
 @brief メッセージに健康機器の歩行距離を設定する。
 @param[in] distance 健康機器の歩行距離
 @param[in,out] message 健康機器の歩行距離を格納するメッセージ
 */
+ (void) setDistance:(double)distance target:(DConnectMessage *)message;
/*!
 @brief メッセージに健康機器の左右バランスを設定する。
 @param[in] balance 健康機器の左右バランス
 @param[in,out] message 健康機器の左右バランスを格納するメッセージ
 */
+ (void) setBalance:(double)balance target:(DConnectMessage *)message;


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
