//
//  DConnectSystemProfile.h
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief Systemプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>
#import <DConnectSDK/DConnectServiceProvider.h>
#import <UIKit/UIKit.h>

/*!
 
 @brief プロファイル名: system。
 */
extern NSString *const DConnectSystemProfileName;


/*!
 @brief インターフェース: device。
 */
extern NSString *const DConnectSystemProfileInterfaceDevice;

/*!
 @brief アトリビュート: wakeup。
 */
extern NSString *const DConnectSystemProfileAttrWakeUp;

/*!
 @brief アトリビュート: keyword。
 */
extern NSString *const DConnectSystemProfileAttrKeyword;
/*!
 
 @brief アトリビュート: events。
 */
extern NSString *const DConnectSystemProfileAttrEvents;

/*!
 @brief パラメータ: supports。
 */
extern NSString *const DConnectSystemProfileParamSupports;

/*!
 @brief パラメータ: plugins。
 */
extern NSString *const DConnectSystemProfileParamPlugins;

/*!
 @brief パラメータ: pluginId。
 */
extern NSString *const DConnectSystemProfileParamPluginId;

/*!
 @brief パラメータ: id。
 */
extern NSString *const DConnectSystemProfileParamId;

/*!
 @brief パラメータ: name。
 */
extern NSString *const DConnectSystemProfileParamName;

/*!
 @brief パラメータ: uuid。
 */
extern NSString *const DConnectSystemProfileParamUUID;

/*!
 @brief パラメータ: version。
 */
extern NSString *const DConnectSystemProfileParamVersion;

@class DConnectSystemProfile;

/*!
 @protocol DConnectSystemProfileDelegate
 @brief Systemプロファイルのデリゲート。
 */
@protocol DConnectSystemProfileDelegate <NSObject>

/*!
 @brief サービス管理機能のインスタンスを取得する。
 @return DConnectServiceProviderのインスタンス。
 */
- (DConnectServiceProvider *) serviceProvider;

/*!
 @brief 設定画面のUI管理クラスのインスタンスを取得する。
 @return UIViewControllerのインスタンス。
 */
- (UIViewController *) settingViewController;

@optional

/*!
 @brief サービスが選択された時に呼び出される。
 @param[in] service 選択されたサービス
 */
- (void) didSelectService: (DConnectService *) service;

/*!
 @brief サービスが削除された時に呼び出される。
 @param[in] service 削除されたサービス
 */
- (void) didRemovedService:(DConnectService *) service;

/*!
 @brief サービス一覧画面が表示された時に呼び出される。
 */
- (void) serviceListViewControllerDidWillAppear;

/*!
 @brief 指定されたサービス一覧をフィルタリングし、画面中に表示するサービスの配列を返す。
 @param[in] サービスの配列
 @return 実際に画面上に表示するサービスの配列
 */
- (NSArray *) displayServiceFilter: (NSArray *) services;

@end

/*!
 @protocol DConnectSystemProfileDataSource
 @brief Systemプロファイルのデータソース。

 DConnectSystemProfileにシステム情報を提供するデータソース。
 */

@protocol DConnectSystemProfileDataSource <NSObject>
@required

/*!
 @brief データソースにデバイスプラグインの設定画面用のUIViewControllerを要求する。
 @attention このメソッドはUIスレッドで呼び出される。
 
 @param[in] sender プロファイル
 @param[in] request リクエスト
 
 @retval UIViewController* 設定画面用のUIViewController
 */
- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request;

@end

/*!
 @class DConnectSystemProfile
 @brief Systemプロファイル。
 
 System Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 */
@interface DConnectSystemProfile : DConnectProfile

@property (nonatomic, weak) id<DConnectSystemProfileDelegate> delegate;

/*!
 @brief DConnectSystemProfileのデータソースオブジェクト。
 
 データソースは @link DConnectSystemProfileDataSource @endlink を実装しなくてはならない。
 データソースはretainされない。
 */
@property (nonatomic, weak) id<DConnectSystemProfileDataSource> dataSource;

#pragma mark - Setter

/*!
 @brief メッセージにサポートしているI/Fの一覧を格納する。
 
 @param[in] supports サポートしているI/F一覧
 @param[in,out] message I/Fの一覧を格納するメッセージ
 */
+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message;

/*!
 @brief メッセージにサポートしているデバイスプラグインの一覧を格納する。
 
 @param[in] plugins サポートしているデバイスプラグイン一覧
 @param[in,out] message デバイスプラグインの一覧を格納するメッセージ
 */
+ (void) setPlugins:(DConnectArray *)plugins target:(DConnectMessage *)message;

/*!
 @brief メッセージにデバイスプラグインIDを格納する。
 
 @param[in] pluginId デバイスプラグインID
 @param[in,out] message デバイスプラグインIDを格納するメッセージ
 */
+ (void) setId:(NSString *)pluginId target:(DConnectMessage *)message;

/*!
 @brief メッセージにデバイスプラグイン名を格納する。
 DeviceConnectManagerの名前も兼ねている。
 
 @param[in] name デバイスプラグイン名、あるいはDevice Connect Manager名
 @param[in,out] message デバイスプラグイン名を格納するメッセージ
 */
+ (void) setName:(NSString *)name target:(DConnectMessage *)message;

/*!
 @brief メッセージにDeviceConnectManagerのUUIDを格納する。
 
 @param[in] uuid DeviceConnectManagerのUUID
 @param[in,out] message デバイスプラグイン名を格納するメッセージ
 */
+ (void) setUUID:(NSString *)uuid target:(DConnectMessage *)message;
#pragma mark - Getter

/*!
 @brief リクエストからpluginIdを取得する。
 
 @param[in] request リクエストパラメータ
 @retval NSString* デバイスプラグインID
 @retval nil pluginIdが指定されていない場合
 */
+ (NSString *) pluginIdFromRequest:(DConnectMessage *)request;

#pragma mark - Private


/*!
 @brief PutWakeupRequestを受信した時に実行する処理。設定画面表示を行う。
 @param[in] request リクエストパラメータ
 @param[in,out] response レスポンスパラメータ
 @retval YES レスポンスパラメータを返却する。
 @retval NO レスポンスパラメータを返却しないので、@link DConnectManager::sendResponse: @endlinkで返却すること。
 */
- (BOOL) didReceivePutWakeupRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response;

@end
