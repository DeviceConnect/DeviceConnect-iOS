//
//  DCMTemperatureProfileName.h
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief Temperatureプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.7.15)
 */
#import <DConnectSDK/DConnectSDK.h>
/*!
 @brief プロファイル名: temperature。
 */
extern NSString *const DCMTemperatureProfileName;

/*!
 @brief パラメータ: temperature。
 */
extern NSString *const DCMTemperatureProfileParamTemperature;

/*!
 @brief パラメータ: type。
 */
extern NSString *const DCMTemperatureProfileParamType;

/*!
 @brief パラメータ: timeStamp。
 */
extern NSString *const DCMTemperatureProfileParamTimeStamp;

/*!
 @brief パラメータ: timeStampString。
 */
extern NSString *const DCMTemperatureProfileParamTimeStampString;

/*!
 @brief 摂氏・華氏を表す
 */
typedef NS_ENUM(NSInteger, DCMTemperatureType) {
    DCMTemperatureProfileEnumCelsius = 1,  /*!< 摂氏 */
    DCMTemperatureProfileEnumCelsiusFahrenheit /*!<華氏 */
};

@class DCMTemperatureProfile;


/*!
 @protocol DCMTemperatureProfileDelegate
 @brief TemperatureProfile各APIリクエスト通知用デリゲート。
 
  Temperature Profileの各APIへのリクエスト受信通知を受け取るデリゲート。
 */
@protocol DCMTemperatureProfileDelegate<NSObject>
@optional

/*!
 @brief 温度の取得.<br>
 
 実装されない場合には、Not supportのエラーが返却される。
 <pre>
 [対応するRESTful]
 PUT http://{dConnectドメイン}/temperature?serviceId=xxxxx
 </pre>
 @param[in] profile プロファイル
 @param[in] request リクエスト
 @param[in,out] response レスポンス
 @param[in] serviceId サービスID
 @retval YES レスポンスパラメータを返却する
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL)                        profile:(DCMTemperatureProfile *)profile
        didReceiveGetTemperatureRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId;
@end

/*!
 @class DCMTemperatureProfile
 @brief Temperatureプロファイル。
 
 Temperature Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMTemperatureProfile : DConnectProfile

/*!
 @brief DCMTemperatureProfileのデリゲートオブジェクト。
 
 デリゲートは @link DCMTemperatureProfileDelegate @endlink を実装しなくてはならない。
 デリゲートはretainされない。
 */
@property (nonatomic, assign) id<DCMTemperatureProfileDelegate> delegate;

+ (void) setTemperature:(float)temperature target:(DConnectMessage *)message;
+ (void) setTimeStamp:(long)timeStamp target:(DConnectMessage *)message;
+ (void) setType:(DCMTemperatureType)type target:(DConnectMessage *)message;
+ (float) convertCelsiusToFahrenheit:(float)celsius;
+ (float) convertFahrenheitToCelsius:(float)fahrenheit;
@end
