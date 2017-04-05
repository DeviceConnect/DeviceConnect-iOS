//
//  NotificationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Notificationプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名: notification。
 */
extern NSString *const DConnectNotificationProfileName;

/*!
 @brief アトリビュート: notify。
 */
extern NSString *const DConnectNotificationProfileAttrNotify;

/*!
 @brief アトリビュート: onclick。
 */
extern NSString *const DConnectNotificationProfileAttrOnClick;

/*!
 @brief アトリビュート: onshow。
 */
extern NSString *const DConnectNotificationProfileAttrOnShow;

/*!
 @brief アトリビュート: onclose。
 */
extern NSString *const DConnectNotificationProfileAttrOnClose;

/*!
 @brief アトリビュート: onerror。
 */
extern NSString *const DConnectNotificationProfileAttrOnError;

/*!
 @brief パラメータ: body。
 */
extern NSString *const DConnectNotificationProfileParamBody;

/*!
 @brief パラメータ: type。
 */
extern NSString *const DConnectNotificationProfileParamType;

/*!
 @brief パラメータ: dir。
 */
extern NSString *const DConnectNotificationProfileParamDir;

/*!
 @brief パラメータ: lang。
 */
extern NSString *const DConnectNotificationProfileParamLang;

/*!
 @brief パラメータ: tag。
 */
extern NSString *const DConnectNotificationProfileParamTag;

/*!
 @brief パラメータ: icon。
 */
extern NSString *const DConnectNotificationProfileParamIcon;

/*!
 @brief パラメータ: notificationid。
 */
extern NSString *const DConnectNotificationProfileParamNotificationId;

/*!
 @brief パラメータ: uri。
 */
extern NSString *const DConnectNotificationProfileParamUri;

/*!
 @brief 文字の向き: Unknown。
 */
extern NSString *const DConnectNotificationProfileDirectionUnknown;
/*!
 @brief 文字の向き: auto。
 */
extern NSString *const DConnectNotificationProfileDirectionAuto;
/*!
 @brief 文字の向き: rtl。
 */
extern NSString *const DConnectNotificationProfileDirectionRightToLeft;
/*!
 @brief 文字の向き: ltr。
 */
extern NSString *const DConnectNotificationProfileDirectionLeftToRight;

/*!
 @enum DConnectNotificationProfileNotificationType
 @brief 通知タイプ定数。
 */
typedef NS_ENUM(NSInteger, DConnectNotificationProfileNotificationType) {
    DConnectNotificationProfileNotificationTypeUnknown = -1,    /*!< 未定数値 */
    DConnectNotificationProfileNotificationTypePhone = 0,       /*!< 音声通話着信 */
    DConnectNotificationProfileNotificationTypeMail,            /*!< メール着信 */
    DConnectNotificationProfileNotificationTypeSMS,             /*!< SMS着信 */
    DConnectNotificationProfileNotificationTypeEvent,           /*!< イベント */
};

/*!
 @class DConnectNotificationProfile
 @brief Notification プロファイル。
 
 Notification Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectNotificationProfile : DConnectProfile

#pragma mark - Setter

/*!
 @brief メッセージに通知IDを設定する。
 
 @param[in] notificationId 通知ID
 @param[in,out] message 通知IDを格納するメッセージ
 */
+ (void) setNotificationId:(NSString *)notificationId target:(DConnectMessage *)message;

#pragma mark - Getter

/*!
 @brief リクエストから通知タイプを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 通知タイプ定数
 @retval nil 省略された場合
 */
+ (NSNumber *) typeFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから向きを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval DConnectNotificationProfileDirectionUnknown
 @retval DConnectNotificationProfileDirectionAuto
 @retval DConnectNotificationProfileDirectionRightToLeft
 @retval DConnectNotificationProfileDirectionLeftToRight
 @retval nil 省略された場合
 */
+ (NSString *) dirFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから言語を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 言語(ref. BCP47)
 @retval nil 省略された場合
 */
+ (NSString *) langFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから通知メッセージを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 通知メッセージ
 @retval nil 省略された場合
 */
+ (NSString *) bodyFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストからタグを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval タグ
 @retval nil 省略された場合
 */
+ (NSString *) tagFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストからノーティフィケーションIDを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 通知ID
 @retval nil 省略された場合
 */
+ (NSString *) notificationIdFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストからアイコンデータを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval アイコンデータ
 @retval nil 省略された場合
 */
+ (NSData *) iconFromRequest:(DConnectMessage *)request;

@end
