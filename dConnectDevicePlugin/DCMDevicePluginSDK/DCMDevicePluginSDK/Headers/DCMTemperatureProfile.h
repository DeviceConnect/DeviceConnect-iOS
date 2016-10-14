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
 @brief 摂氏・華氏を表す
 */
enum {
    DCMTemperatureProfileEnumCelsius = 1,  /*!< 摂氏 */
    DCMTemperatureProfileEnumCelsiusFahrenheit /*!<華氏 */
};


/*!
 @class DCMTemperatureProfile
 @brief Temperatureプロファイル。
 
 Temperature Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMTemperatureProfile : DConnectProfile

@end
