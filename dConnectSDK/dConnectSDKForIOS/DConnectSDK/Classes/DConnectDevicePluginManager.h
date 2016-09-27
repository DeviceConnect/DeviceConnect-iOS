//
//  DConnectDevicePluginManager.h
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectDevicePlugin.h"

/**
 * デバイスプラグインを管理するクラス.
 */
@interface DConnectDevicePluginManager : NSObject

/*! dConnectManagerのドメイン名. */
@property(nonatomic, weak) NSString *dConnectDomain;

/**
 * デバイスプラグイン一覧を探索する.
 * クラス名一式を取得して、特定の名前が付いているクラスをデバイスプラグインとして認識する。
 */
- (void) searchDevicePlugin;

/**
 * 指定されたサービスIDのデバイスプラグインを取得する.
 *
 * ここで指定されるserviceIdは、appendDevicePluginで作成された
 * [device].[deviceplugin].dconnect
 * の形のサービスIDになる。
 *
 * この関数では、[deviceplugin]の部分を抜き出して、デバイスプラグインを見つけ出す。
 *
 * 指定されたサービスIDのデバイスプラグインが存在しない場合にはnilを返却する。
 *
 * @param[in] serviceId サービスID
 * @return DConnectDevicePluginのインスタンス
 */
- (DConnectDevicePlugin *) devicePluginForServiceId:(NSString *)serviceId;


/**
 * 指定されたプラグインIDのデバイスプラグインを取得する.
 * 指定されたサービスIDのデバイスプラグインが存在しない場合にはnilを返却する。
 *
 * @param[in] pluginId プラグインID
 * @return DConnectDevicePluginのインスタンス
 */
- (DConnectDevicePlugin *) devicePluginForPluginId:(NSString *)pluginId;

/**
 * 登録されているすべてのデバイスプラグインを取得する.
 * @return 登録されているすべてのデバイスプラグインの配列
 */
- (NSArray *) devicePluginList;

/**
 * サービスIDにデバイスプラグインのIDを付加する.
 *
 * [device].[deviceplugin].dconnect
 *
 * @param[in] plugin プラグイン
 * @param[in] serviceId オリジナルのサービスID
 * @return デバイスプラグインのIDが付加されたサービスID
 */
- (NSString *) serviceIdByAppedingPluginIdWithDevicePlugin:(DConnectDevicePlugin *)plugin serviceId:(NSString *)serviceId;

/**
 * サービスIDからデバイスプラグインのIDを削除する.
 * @param[in] serviceId デバイスプラグインのIDが付加されたサービスID
 * @param[in] plugin プラグイン
 * @return オリジナルのサービスID
 */
- (NSString *) spliteServiceId:(NSString *)serviceId byDevicePlugin:(DConnectDevicePlugin *)plugin;


/*!
 * @brief サービスIDを分解して、Device Connect Managerのドメイン名を省いた本来のサービスIDにする.
 * Device Connect Managerのドメインを省いたときに、何もない場合には空文字を返します。
 * @param[in] plugin デバイスプラグイン
 * @param[in] serviceId サービスID
 * @retval Device Connect Managerのドメインが省かれたサービスID
 */
+ (NSString *) splitServiceId: (DConnectDevicePlugin *) plugin serviceId:(NSString *) serviceId;

/*!
 * @brief サービスIDにDevice Connect Managerのドメイン名を追加する.
 *
 * サービスIDがnullのときには、サービスIDは無視します。
 *
 * @param[in] plugin デバイスプラグイン
 * @param[in] serviceId サービスID
 * @retval Device Connect Managerのドメインなどが追加されたサービスID
 */
- (NSString *) appendServiceId: (DConnectDevicePlugin *) plugin serviceId:(NSString *) serviceId;
@end
