//
//  DConnectLightProfileName.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief Lightプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.7.22)
 */
#import <DConnectSDK/DConnectSDK.h>
/*! @brief プロファイル名: light。 */
extern NSString *const DConnectLightProfileName;
/*!
 @brief インターフェイス: group。
 */
extern NSString *const DConnectLightProfileInterfaceGroup;
/*!
 @brief 属性: create。
 */
extern NSString *const DConnectLightProfileAttrCreate;
/*!
 @brief 属性: clear。
 */
extern NSString *const DConnectLightProfileAttrClear;

/*!
 @brief パラメータ: lightId。
 */
extern NSString *const DConnectLightProfileParamLightId;
/*!
 @brief パラメータ: name。
 */
extern NSString *const DConnectLightProfileParamName;
/*!
 @brief パラメータ: color。
 */
extern NSString *const DConnectLightProfileParamColor;
/*!
 @brief パラメータ: brightness。
 */
extern NSString *const DConnectLightProfileParamBrightness;
/*!
 @brief パラメータ: flashing。
 */
extern NSString *const DConnectLightProfileParamFlashing;
/*!
 @brief パラメータ: lights。
 */
extern NSString *const DConnectLightProfileParamLights;
/*!
 @brief パラメータ: on。
 */
extern NSString *const DConnectLightProfileParamOn;
/*!
 @brief パラメータ: config。
 */
extern NSString *const DConnectLightProfileParamConfig;
/*!
 @brief パラメータ: groupId。
 */
extern NSString *const DConnectLightProfileParamGroupId;
/*!
 @brief パラメータ: groups。
 */
extern NSString *const DConnectLightProfileParamLightGroups;
/*!
 @brief パラメータ: lightIds。
 */
extern NSString *const DConnectLightProfileParamLightIds;
/*!
 @brief パラメータ: groupName。
 */
extern NSString *const DConnectLightProfileParamGroupName;


/*!
 @class DConnectLightProfile
 @brief Lightプロファイル。
 
 Light Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectLightProfile : DConnectProfile

#pragma mark - Getter

/*!
 @brief リクエストからlightIdを取得する。
 @retval lightId
 @retval nil リクエストにlightIdが指定されていない場合
 */
+ (NSString *) lightIdFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからlightIdsを取得する。
 @retval lightIds
 @retval nil リクエストにlightIdsが指定されていない場合
 */
+ (NSString *) lightIdsFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからbrightnessを取得する。
 @retval brightness
 @retval nil リクエストにbrightnessが指定されていない場合
 */
+ (NSNumber *) brightnessFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからnameを取得する。
 @retval name
 @retval nil リクエストにnameが指定されていない場合
 */
+ (NSString *) nameFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからcolorを取得する。
 @retval color
 @retval nil リクエストにcolorが指定されていない場合
 */
+ (NSString *) colorFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからflashingを取得する。
 @retval flashing
 @retval nil リクエストにflashingが指定されていない場合
 */
+ (NSString *) flashingFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからgroupIdを取得する。
 @retval groupId
 @retval nil リクエストにgroupIdが指定されていない場合
 */
+ (NSString *) groupIdFromRequest: (DConnectRequestMessage *) request;

/*!
 @brief リクエストからgroupNameを取得する。
 @retval groupName
 @retval nil リクエストにgroupNameが指定されていない場合
 */
+ (NSString *) groupNameFromRequest: (DConnectRequestMessage *) request;

/*
 flashingをパースする。
 */
+ (NSArray *) parsePattern:(NSString *)pattern
                      isId:(BOOL)isId;

- (BOOL)checkFlash:(DConnectResponseMessage *)response flashing:(NSArray *)flashing;


#pragma mark - Setter


/*!
 @brief メッセージにライト一覧を設定する。
 
 @param[in] lights ライト一覧
 @param[in,out] message ライト一覧を格納するメッセージ
 */
+ (void) setLights:(DConnectArray *)lights target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトIDを設定する。
 
 @param[in] lightId ライトID
 @param[in,out] message ライトIDを格納するメッセージ
 */
+ (void) setLightId:(NSString*)lightId target:(DConnectMessage *)message;

/*!
 @brief メッセージにライト名を設定する。
 
 @param[in] lightName ライト名
 @param[in,out] message ライト名を格納するメッセージ
 */
+ (void) setLightName:(NSString*)lightName target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトの点灯状態を設定する。
 
 @param[in] isOn 点灯: YES、 消灯: NO
 @param[in,out] message ライトの点灯状態を格納するメッセージ
 */
+ (void) setLightOn:(BOOL)isOn target:(DConnectMessage *)message ;

/*!
 @brief メッセージにライトの設定情報を設定する。
 
 @param[in] config 設定情報文字列
 @param[in,out] message ライトの設定情報を格納するメッセージ
 */
+ (void) setLightConfig:(NSString*)config target:(DConnectMessage *)message;


/*!
 @brief メッセージにライトグループ一覧を設定する。
 
 @param[in] lightGroups ライトグループ一覧
 @param[in,out] message ライトグループ一覧を格納するメッセージ
 */
+ (void) setLightGroups:(DConnectArray *)lightGroups target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトグループIDを設定する。
 
 @param[in] lightGroupId ライトグループID
 @param[in,out] message ライトグループIDを格納するメッセージ
 */
+ (void) setLightGroupId:(NSString*)lightGroupId target:(DConnectMessage *)message;

/*!
 @brief メッセージにライトグループ名を設定する。
 
 @param[in] lightGroupName ライトグループ名
 @param[in,out] message ライトグループ名を格納するメッセージ
 */
+ (void) setLightGroupName:(NSString*)lightGroupName target:(DConnectMessage *)message;

@end
