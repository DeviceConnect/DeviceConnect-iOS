//
//  DCMTVProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! @file
 @brief TVプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2015.8.2)
 */
#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: tv。
 */
extern NSString *const DCMTVProfileName;

/*!
 @brief 属性: channel。
 */
extern NSString *const DCMTVProfileAttrChannel;

/*!
 @brief 属性: volume。
 */
extern NSString *const DCMTVProfileAttrVolume;

/*!
 @brief 属性: broadcastwave。
 */
extern NSString *const DCMTVProfileAttrBroadcastwave;

/*!
 @brief 属性: mute。
 */
extern NSString *const DCMTVProfileAttrMute;

/*!
 @brief 属性: enlproperty。
 */
extern NSString *const DCMTVProfileAttrEnlproperty;

/*!
 @brief パラメータ: control。
 */
extern NSString *const DCMTVProfileParamControl;

/*!
 @brief パラメータ: tuning。
 */
extern NSString *const DCMTVProfileParamTuning;

/*!
 @brief パラメータ: select。
 */
extern NSString *const DCMTVProfileParamSelect;

/*!
 @brief パラメータ: epc。
 */
extern NSString *const DCMTVProfileParamEPC;

/*!
 @brief パラメータ: value。
 */
extern NSString *const DCMTVProfileParamValue;

/*!
 @brief パラメータ: powerstatus。
 */
extern NSString *const DCMTVProfileParamPowerStatus;

/*!
 @brief パラメータ: properties。
 */
extern NSString *const DCMTVProfileParamProperties;

/*!
 @brief パラメータ: ON。
 */
extern NSString *const DCMTVProfileParamPowerStatusOn;

/*
 @brief パラメータ: OFF。
 */
extern NSString *const DCMTVProfileParamPowerStatusOff;

/*!
 @brief パラメータ: UNKNOWN。
 */
extern NSString *const DCMTVProfileParamPowerStatusUnknown;

/*!
 @brief パラメータ: next。
 */
extern NSString *const DCMTVProfileChannelStateNext;

/*!
 @brief パラメータ: previous。
 */
extern NSString *const DCMTVProfileChannelStatePrevious;

/*!
 @brief パラメータ: up。
 */
extern NSString *const DCMTVProfileVolumeStateUp;

/*!
 @brief パラメータ: down。
 */
extern NSString *const DCMTVProfileVolumeStateDown;

/*!
 @brief パラメータ: DTV。
 */
extern NSString *const DCMTVProfileBroadcastwaveDTV;

/*!
 @brief パラメータ: BS。
 */
extern NSString *const DCMTVProfileBroadcastwaveBS;

/*!
 @brief パラメータ: CS。
 */
extern NSString *const DCMTVProfileBroadcastwaveCS;

@class DCMTVProfile;

/*!
 @protocol DCMTVProfileDelegate
 @brief TVProfile各APIリクエスト通知用デリゲート。
 
 TV Profileの各APIへのリクエスト受信通知を受け取るデリゲート。
 */
@protocol DCMTVProfileDelegate<NSObject>
@optional

/*!
 @brief 電源の状態を取得する。
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 GET http://{dConnectドメイン}/tv?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
        didReceiveGetTVRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId;
/*!
 @brief 電源を入れる。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 GET http://{dConnectドメイン}/tv?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
                 didReceivePutTVRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId;
/*!
 @brief 電源を消す。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
                 didReceiveDeleteTVRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId;
/*!
 @brief チャンネルを変える。
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv/channel?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] tuning チャンネル番号
 @param[in] control チャンネルを前か次に送る
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
                 didReceivePutTVChannelRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 tuning:(NSString *)tuning
                                 control:(NSString *)control;


/*!
 @brief 音量を変える。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv/volume?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] control 音量をあげるかさげるか
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
          didReceivePutTVVolumeRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 control:(NSString *)control;

/*!
 @brief 放送波を変える。
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv/broadcastwave?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] select 放送波
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
           didReceivePutTVBroadcastWaveRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                 select:(NSString *)select;

/*!
 @brief ミュートをONにする。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv/mute?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
           didReceivePutTVMuteRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId;

/*!
 @brief ミュートをOFFにする。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 DELETE http://{dConnectドメイン}/tv/mute?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
           didReceiveDeleteTVMuteRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId;
/*!
 @brief 該当デバイスがサポートしているECHONET Lite 機器オブジェクトプロパティの設定内容を取得する。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 GET http://{dConnectドメイン}/tv/enlproperty?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] epc ECHONET Liteコマンド
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
           didReceiveGetTVEnlpropertyRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                    epc:(NSString *)epc;

/*!
 @brief 該当デバイスがサポートしているECHONET Lite 機器オブジェクトプロパティに設定を行う。
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/tv/enlproperty?serviceId=xxxxx&tvId=yyyyy
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] epc ECHONET Liteコマンド
 @param[in] value ECHONET Lite値
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTVProfile *)profile
      didReceivePutTVEnlpropertyRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                                    epc:(NSString *)epc
                                  value:(NSString *)value;

@end

/*!
 @class DCMTVeProfile
 @brief TVプロファイル。
 
 TV Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMTVProfile : DConnectProfile

/*!
 @brief DCMTVProfileのデリゲートオブジェクト。
 
 デリゲートは @link DCMTVProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, assign) id<DCMTVProfileDelegate> delegate;

@end
