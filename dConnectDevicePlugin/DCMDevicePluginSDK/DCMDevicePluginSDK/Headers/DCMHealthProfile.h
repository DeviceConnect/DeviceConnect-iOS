//
//  DCMHealthProfile.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @file
 @brief Healthプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectSDK.h>

/*!
 @brief プロファイル名: health。
 */
extern NSString *const DCMHealthProfileName;

/*!
 @brief アトリビュート: heart。
 */
extern NSString *const DConnectHealthProfileAttrHeart;


/*!
 @brief パラメータ: heart。
 */
extern NSString *const DConnectHealthProfileParamHeart;


/*!
 @brief パラメータ: rate。
 */
extern NSString *const DConnectHealthProfileParamRate;

/*!
 @brief パラメータ: value。
 */
extern NSString *const DConnectHealthProfileParamValue;

/*!
 @brief パラメータ: mderFloat。
 */
extern NSString *const DConnectHealthProfileParamMDERFloat;

/*!
 @brief パラメータ: type。
 */
extern NSString *const DConnectHealthProfileParamType;

/*!
 @brief パラメータ: typeCode。
 */
extern NSString *const DConnectHealthProfileParamTypeCode;

/*!
 @brief パラメータ: unit。
 */
extern NSString *const DConnectHealthProfileParamUnit;

/*!
 @brief パラメータ: unitCode。
 */
extern NSString *const DConnectHealthProfileParamUnitCode;

/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DConnectHealthProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DConnectHealthProfileParamTimeStampString;

/*!
 @brief パラメータ: rr。
 */
extern NSString *const DConnectHealthProfileParamRR;

/*!
 @brief パラメータ: energy。
 */
extern NSString *const DConnectHealthProfileParamEnergy;

/*!
 @brief パラメータ: device。
 */
extern NSString *const DConnectHealthProfileParamDevice;

/*!
 @brief パラメータ: productName。
 */
extern NSString *const DConnectHealthProfileParamProductName;

/*!
 @brief パラメータ: manufacturerName。
 */
extern NSString *const DConnectHealthProfileParamManufacturerName;

/*!
 @brief パラメータ: modelNumber。
 */
extern NSString *const DConnectHealthProfileParamModelNumber;


/*!
 @brief パラメータ: firmwareRevision。
 */
extern NSString *const DConnectHealthProfileParamFirmwareRevision;

/*!
 @brief パラメータ: serialNumber。
 */
extern NSString *const DConnectHealthProfileParamSerialNumber;

/*!
 @brief パラメータ: softwareRevision。
 */
extern NSString *const DConnectHealthProfileParamSoftwareRevision;

/*!
 @brief パラメータ: hardwareRevision。
 */
extern NSString *const DConnectHealthProfileParamHardwareRevision;

/*!
 @brief パラメータ: partNumber。
 */
extern NSString *const DConnectHealthProfileParamPartNumber;

/*!
 @brief パラメータ: protocolRevision。
 */
extern NSString *const DConnectHealthProfileParamProtocolRevision;

/*!
 @brief パラメータ: systemId。
 */
extern NSString *const DConnectHealthProfileParamSystemId;
/*!
 @brief パラメータ: batteryLevel。
 */
extern NSString *const DConnectHealthProfileParamBatteryLevel;


@class DCMHealthProfile;

/*!
 @protocol DCMHealthProfileDelegate
 @brief HealthProfile各APIリクエスト通知用デリゲート。
 
 Health Profileの各APIへのリクエスト受信通知を受け取るデリゲート。
 */
@protocol DCMHealthProfileDelegate<NSObject>
@optional

#pragma mark - Get Methods

/*!
 @brief heart取得リクエストを受け取ったことをデリゲートに通知する。
 
 profileがheart取得リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] Health API [GET]
 </p>
 
 @param[in] profile このイベントを通知するDCMHealthProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)          profile:(DCMHealthProfile *)profile
didReceiveGetHeartRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId;

#pragma mark - Put Methods
#pragma mark Event Registration

/*!
 @brief heartイベント登録リクエストを受け取ったことをデリゲートに通知する。
 
 profileがheartイベント登録リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] Health Event API [Register]
 </p>
 
 @param[in] profile このイベントを通知するDCMHealthProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)           profile:(DCMHealthProfile *)profile
didReceivePutHeartRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                sessionKey:(NSString *)sessionKey;


#pragma mark - Delete Methods
#pragma mark Event Unregistration

/*!
 @brief heartイベント解除リクエストを受け取ったことをデリゲートに通知する。
 
 profileがheartイベント解除リクエストを受け取ったことをデリゲートに通知する。<br>
 実装されない場合には、Not supportのエラーが返却される。
 
 <p>
 [対応するAPI] Heart Event API [Unregister]
 </p>
 
 @param[in] profile このイベントを通知するDCMHealthProfileのオブジェクト
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @param[in] sessionKey セッションキー
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                           profile:(DCMHealthProfile *)profile
didReceiveDeleteHeartRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
                                 serviceId:(NSString *)serviceId
                                sessionKey:(NSString *)sessionKey;

@end

/*!
 @class DCMHealthProfile
 @brief Healthプロファイル。
 
 Health Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMHealthProfile : DConnectProfile
/*!
 @brief DCMHealthProfileのデリゲートオブジェクト。
 
 デリゲートは @link DCMHealthProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, weak) id<DCMHealthProfileDelegate> delegate;


#pragma mark - Setters
/*!
 @brief メッセージにHeartRate情報を設定する。
 @param[in] heart HeartRate情報
 @param[in,out] message HeartRate情報を格納するメッセージ
 */
+ (void) setHeart:(DConnectMessage *)heart target:(DConnectMessage *)message;

/*!
 @brief メッセージにRate情報を設定する。
 @param[in] rate Rate情報
 @param[in,out] message Rate情報を格納するメッセージ
 */
+ (void) setRate:(DConnectMessage *)rate target:(DConnectMessage *)message;


/*!
 @brief メッセージにRRI情報を設定する。
 @param[in] rr RRI情報
 @param[in,out] message RRI情報を格納するメッセージ
 */
+ (void) setRRI:(DConnectMessage *)rr target:(DConnectMessage *)message;


/*!
 @brief メッセージにEnergyExtended情報を設定する。
 @param[in] energy EnergyExtended情報
 @param[in,out] message EnergyExtended情報を格納するメッセージ
 */
+ (void) setEnergyExtended:(DConnectMessage *)energy target:(DConnectMessage *)message;

/*!
 @brief メッセージに健康機器情報を設定する。
 @param[in] device 健康機器情報
 @param[in,out] message 健康機器情報を格納するメッセージ
 */
+ (void) setDevice:(DConnectMessage *)device target:(DConnectMessage *)message;


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
+ (void) setTypeCode:(NSString*)typeCode target:(DConnectMessage *)message;

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
+ (void) setUnitCode:(NSString*)unitCode target:(DConnectMessage *)message;

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
