//
//  DCMPoseEstimationProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: PoseEstimation。
 */
extern NSString *const DCMPoseEstimationProfileName;

/*!
 @brief アトリビュート: onPoseEstimation。
 */
extern NSString *const DCMPoseEstimationProfileAttrOnPoseEstimation;


/*!
 @brief パラメータ: pose。
 */
extern NSString *const DCMPoseEstimationProfileParamPose;

/*!
 @brief パラメータ: state。
 */
extern NSString *const DCMPoseEstimationProfileParamState;


/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DCMPoseEstimationProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DCMPoseEstimationProfileParamTimeStampString;

/*!
 @brief 状態: Forward。
 */
extern NSString *const DCMPoseEstimationProfileStateForward;
/*!
 @brief 状態: Backward。
 */
extern NSString *const DCMPoseEstimationProfileStateBackward;
/*!
 @brief 状態: Rightside。
 */
extern NSString *const DCMPoseEstimationProfileStateRightside;
/*!
 @brief 状態: Leftside。
 */
extern NSString *const DCMPoseEstimationProfileStateLeftside;
/*!
 @brief 状態: FaceUp。
 */
extern NSString *const DCMPoseEstimationProfileStateFaceUp;
/*!
 @brief 状態: FaceLeft。
 */
extern NSString *const DCMPoseEstimationProfileStateFaceLeft;
/*!
 @brief 状態: FaceDown。
 */
extern NSString *const DCMPoseEstimationProfileStateFaceDown;
/*!
 @brief 状態: FaceRight。
 */
extern NSString *const DCMPoseEstimationProfileStateFaceRight;
/*!
 @brief 状態: Standing。
 */
extern NSString *const DCMPoseEstimationProfileStateStanding;

@class DCMPoseEstimationProfile;


/*!
 @class DCMPoseEstimationProfile
 @brief PoseEstimationプロファイル。
 
 PoseEstimation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMPoseEstimationProfile : DConnectProfile

#pragma mark - Setters
/*!
 @brief メッセージにPoseEstimation情報を設定する。
 @param[in] pose PoseEstimation情報
 @param[in,out] message PoseEstimation情報を格納するメッセージ
 */
+ (void) setPose:(DConnectMessage *)pose target:(DConnectMessage *)message;



/*!
 @brief メッセージに健康機器の姿勢推定値を設定する。
 @param[in] state 健康機器の姿勢推定値
 @param[in,out] message 健康機器のストレス推定値を格納するメッセージ
 */
+ (void) setState:(NSString*)state target:(DConnectMessage *)message;


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
