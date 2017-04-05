//
//  DConnectSettingProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Settingプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名: setting。
 */
extern NSString *const DConnectSettingProfileName;

/*!
 @brief インターフェース: sound。
 */
extern NSString *const DConnectSettingProfileInterfaceSound;

/*!
 @brief インターフェース: display。
 */
extern NSString *const DConnectSettingProfileInterfaceDisplay;

/*!
 @brief アトリビュート: volume。
 */
extern NSString *const DConnectSettingProfileAttrVolume;

/*!
 @brief アトリビュート: date。
 */
extern NSString *const DConnectSettingProfileAttrDate;

/*!
 @brief アトリビュート: light。
 */
extern NSString *const DConnectSettingProfileAttrBrightness;

/*!
 @brief アトリビュート: sleep。
 */
extern NSString *const DConnectSettingProfileAttrSleep;

/*!
 @brief パラメータ: kind。
 */
extern NSString *const DConnectSettingProfileParamKind;

/*!
 @brief パラメータ: level。
 */
extern NSString *const DConnectSettingProfileParamLevel;

/*!
 @brief パラメータ: date。
 */
extern NSString *const DConnectSettingProfileParamDate;

/*!
 @brief パラメータ: time。
 */
extern NSString *const DConnectSettingProfileParamTime;

/*!
 @brief ボリュームのレベルの最大値: 1.0。
 */
extern const double DConnectSettingProfileMaxLevel;

/*!
 @brief ボリュームのレベルの最小値: 0.0。
 */
extern const double DConnectSettingProfileMinLevel;

/*!
 @enum DConnectSettingProfileVolumeKind
 @brief 音量の種別定数。
 */
typedef NS_ENUM(NSInteger, DConnectSettingProfileVolumeKind) {
    DConnectSettingProfileVolumeKindUnknown = -1,  /*!< 未定義値 */
    DConnectSettingProfileVolumeKindAlarm = 1,     /*!< アラーム */
    DConnectSettingProfileVolumeKindCall,          /*!< 通話音 */
    DConnectSettingProfileVolumeKindRingtone,      /*!< 着信音 */
    DConnectSettingProfileVolumeKindMail,          /*!< メール着信音 */
    DConnectSettingProfileVolumeKindOther,         /*!< その他SNS等の着信音 */
    DConnectSettingProfileVolumeKindMediaPlay,     /*!< メディアプレーヤーの音量 */
};

@class DConnectSettingProfile;
/*!
 @class DConnectSettingProfile
 @brief Settingプロファイル.
 
 Setting Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectSettingProfile : DConnectProfile

#pragma mark - Getter

/*!
 @brief リクエストから音量種別を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval DConnectSettingProfileVolumeKindUnknown
 @retval DConnectSettingProfileVolumeKindAlarm
 @retval DConnectSettingProfileVolumeKindCall
 @retval DConnectSettingProfileVolumeKindRingtone
 @retval DConnectSettingProfileVolumeKindMail
 @retval DConnectSettingProfileVolumeKindOther
 @retval DConnectSettingProfileVolumeKindMediaPlay
 */
+ (DConnectSettingProfileVolumeKind) volumeKindFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから音量を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 音量
 @retval nil 音量が指定されていない場合
 */
+ (NSNumber *) levelFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから日時(RFC3339)を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 日時文字列(RFC3339)
 @retval nil 日時が指定されていない場合
 */
+ (NSString *) dateFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから消灯するまでの時間(ミリ秒)を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 消灯するまでの時間(ミリ秒)。
 @retval nil 消灯時間が指定されていない場合
 */
+ (NSNumber *) timeFromRequest:(DConnectMessage *)request;

#pragma mark - Setter

/*!
 @brief メッセージに音量を設定する。
 
 @param[in] level 音量パーセント(0〜1.0)
 @param[in,out] message 音量を格納するメッセージ
 */
+ (void) setVolumeLevel:(double)level target:(DConnectMessage *)message;

/*!
 @brief メッセージにバックライト明度を設定する。
 
 @param[in] level 明度パーセント(0〜1.0)
 @param[in,out] message バックライト明度を格納するメッセージ
 */
+ (void) setLightLevel:(double)level target:(DConnectMessage *)message;

/*!
 @brief メッセージに日時を設定する。
 
 @param[in] date 日時文字列(RFC3339)
 @param[in,out] message 日時を格納するメッセージ
 */
+ (void) setDate:(NSString *)date target:(DConnectMessage *)message;

/*!
 @brief メッセージに消灯するまでの時間(ミリ秒)を設定する。
 
 @param[in] time 消灯するまでの時間(ミリ秒)
 @param[in,out] message 消灯するまでの時間を格納するメッセージ
 */
+ (void) setTime:(int)time target:(DConnectMessage *)message;

@end
