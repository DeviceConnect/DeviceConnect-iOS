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
 @protocol DCMPoseEstimationProfileDelegate
 @brief PoseEstimationProfile各APIリクエスト通知用デリゲート。
 
 PoseEstimation Profileの各APIへのリクエスト受信通知を受け取るデリゲート。
 */
@protocol DCMPoseEstimationProfileDelegate<NSObject>
@optional

#pragma mark - Get Methods

/*!
 @brief PoseEstimation取得リクエストを受け取ったことをデリゲートに通知する。
 
 profileがPoseEstimation取得リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] PoseEstimation API [GET]
 </p>
 
 @param[in] profile このイベントを通知するDCMPoseEstimationrofileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)          profile:(DCMPoseEstimationProfile *)profile
didReceiveGetOnPoseEstimationRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId;
#pragma mark - Put Methods
#pragma mark Event Registration

/*!
 @brief PoseEstimationイベント登録リクエストを受け取ったことをデリゲートに通知する。
 
 profileがPoseEstimationイベント登録リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] PoseEstimation Event API [Register]
 </p>
 
 @param[in] profile このイベントを通知するDCMPoseEstimationProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)           profile:(DCMPoseEstimationProfile *)profile
didReceivePutOnPoseEstimationRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                sessionKey:(NSString *)sessionKey;


#pragma mark - Delete Methods
#pragma mark Event Unregistration

/*!
 @brief PoseEstimationイベント解除リクエストを受け取ったことをデリゲートに通知する。
 
 profileがPoseEstimationイベント解除リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] PoseEstimation Event API [Unregister]
 </p>
 
 @param[in] profile このイベントを通知するDCMPoseEstimationProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                           profile:(DCMPoseEstimationProfile *)profile
 didReceiveDeleteOnPoseEstimationRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                 serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey;

@end

/*!
 @class DCMPoseEstimationProfile
 @brief PoseEstimationプロファイル。
 
 PoseEstimation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMPoseEstimationProfile : DConnectProfile
/*!
 @brief DCMPoseEstimationProfileのデリゲートオブジェクト。
 
 デリゲートは @link DCMPoseEstimationProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, weak) id<DCMPoseEstimationProfileDelegate> delegate;


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
