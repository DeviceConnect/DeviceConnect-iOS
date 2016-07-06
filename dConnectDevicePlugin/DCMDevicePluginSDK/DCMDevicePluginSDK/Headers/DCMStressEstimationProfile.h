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
 @protocol DCMStressEstimationProfileDelegate
 @brief StressEstimationProfile各APIリクエスト通知用デリゲート。
 
 StressEstimation Profileの各APIへのリクエスト受信通知を受け取るデリゲート。
 */
@protocol DCMStressEstimationProfileDelegate<NSObject>
@optional

#pragma mark - Get Methods

/*!
 @brief StressEstimation取得リクエストを受け取ったことをデリゲートに通知する。
 
 profileがStressEstimation取得リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] StressEstimation API [GET]
 </p>
 
 @param[in] profile このイベントを通知するDCMStressEstimationrofileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)          profile:(DCMStressEstimationProfile *)profile
didReceiveGetOnStressEstimationRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId;
#pragma mark - Put Methods
#pragma mark Event Registration

/*!
 @brief StressEstimationイベント登録リクエストを受け取ったことをデリゲートに通知する。
 
 profileがStressEstimationイベント登録リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] StressEstimation Event API [Register]
 </p>
 
 @param[in] profile このイベントを通知するDCMStressEstimationProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)           profile:(DCMStressEstimationProfile *)profile
didReceivePutOnStressEstimationRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                sessionKey:(NSString *)sessionKey;


#pragma mark - Delete Methods
#pragma mark Event Unregistration

/*!
 @brief StressEstimationイベント解除リクエストを受け取ったことをデリゲートに通知する。
 
 profileがStressEstimationイベント解除リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] StressEstimation Event API [Unregister]
 </p>
 
 @param[in] profile このイベントを通知するDCMStressEstimationProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                           profile:(DCMStressEstimationProfile *)profile
 didReceiveDeleteOnStressEstimationRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                 serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey;

@end

/*!
 @class DCMStressEstimationProfile
 @brief StressEstimationプロファイル。
 
 StressEstimation Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMStressEstimationProfile : DConnectProfile
/*!
 @brief DCMStressEstimationProfileのデリゲートオブジェクト。
 
 デリゲートは @link DCMStressEstimationProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, weak) id<DCMStressEstimationProfileDelegate> delegate;


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
