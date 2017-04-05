//
//  DConnectPhoneProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Phoneプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名: phone。
 */
extern NSString *const DConnectPhoneProfileName;

/*!
 @brief アトリビュート: call。
 */
extern NSString *const DConnectPhoneProfileAttrCall;

/*!
 @brief アトリビュート: set。
 */
extern NSString *const DConnectPhoneProfileAttrSet;

/*!
 @brief アトリビュート: onconnect。
 */
extern NSString *const DConnectPhoneProfileAttrOnConnect;

/*!
 @brief パラメータ: phoneNumber。
 */
extern NSString *const DConnectPhoneProfileParamPhoneNumber;

/*!
 @brief パラメータ: mode。
 */
extern NSString *const DConnectPhoneProfileParamMode;

/*!
 @brief パラメータ: phoneStatus。
 */
extern NSString *const DConnectPhoneProfileParamPhoneStatus;

/*!
 @brief パラメータ: state。
 */
extern NSString *const DConnectPhoneProfileParamState;

/*!
 @enum DConnectPhoneProfilePhoneMode
 @brief 電話のモード定数。
 */
typedef NS_ENUM(NSInteger, DConnectPhoneProfilePhoneMode) {
    DConnectPhoneProfilePhoneModeUnknown = -1,  /*!< 未定義値 */
    DConnectPhoneProfilePhoneModeSilent = 0,    /*!< サイレントモード */
    DConnectPhoneProfilePhoneModeManner,        /*!< マナーモード */
    DConnectPhoneProfilePhoneModeSound,         /*!< 音あり */
};

/*!
 @enum DConnectPhoneProfileCallState
 @brief 通話状態定数。
 */
typedef NS_ENUM(NSInteger, DConnectPhoneProfileCallState) {
    DConnectPhoneProfileCallStateUnknown = -1,  /*!< 未定義値 */
    DConnectPhoneProfileCallStateStart = 0,     /*!< 通話開始 */
    DConnectPhoneProfileCallStateFailed,        /*!< 通話失敗 */
    DConnectPhoneProfileCallStateFinished,      /*!< 通話終了 */
};

/*!
 @class DConnectPhoneProfile
 @brief Phone プロファイル。
 
 Phone Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectPhoneProfile : DConnectProfile

#pragma mark - Getter

/*!
 @brief リクエストから発信先の電話番号を取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval NSString* 発信先の電話番号
 @retval nil 電話番号の指定が無い場合
 */
+ (NSString *) phoneNumberFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストから電話のモードを取得する。
 
 @param[in] request リクエストパラメータ
 
 @retval 電話のモード定数
 @retval nil 省略された場合
 */
+ (NSNumber *) modeFromRequest:(DConnectMessage *)request;

#pragma mark - Setter

/*!
 @brief メッセージに電話状態を設定する。
 
 @param[in] phoneStatus 電話状態オブジェクト
 @param[in,out] message 電話状態を格納するメッセージ
 */
+ (void) setPhoneStatus:(DConnectMessage *)phoneStatus target:(DConnectMessage *)message;

/*!
 @brief メッセージに通話状態を設定する。
 
 @param[in] state 通話状態
 @param[in,out] message 通話状態を格納するメッセージ
 */
+ (void) setState:(DConnectPhoneProfileCallState)state target:(DConnectMessage *)message;

/*!
 @brief メッセージに発信先の電話番号を設定する。
 
 @param[in] phoneNumber 電話番号
 @param[in,out] message 発信先の電話番号を格納するメッセージ
 */
+ (void) setPhoneNumber:(NSString *)phoneNumber target:(DConnectMessage *)message;

@end
