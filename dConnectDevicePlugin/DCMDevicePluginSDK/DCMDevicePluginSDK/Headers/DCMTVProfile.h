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

/*!
 @class DCMTVeProfile
 @brief TVプロファイル。
 
 TV Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DCMTVProfile : DConnectProfile

@end
