//
//  DConnectManager+Private.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectManager.h"
#import "DConnectDevicePluginManager.h"
#import "DConnectServerManager.h"
#import "DConnectEventBroker.h"

/*!
 @brief Manager-プラグイン間のデバイス検索APIのプロファイル名。
 */
extern NSString *const DConnectProfileNameNetworkServiceDiscovery;

/*!
 @brief Manager-プラグイン間のデバイス検索APIのアトリビュート名。
 */
extern NSString *const DConnectAttributeNameGetNetworkServices;

/*!
 @brief Manager-プラグイン間のクライアント作成APIのアトリビュート名。
 */
extern NSString *const DConnectAttributeNameCreateClient;

/*
 @brief Manager-プラグイン間のアクセストークン取得APIのアトリビュート名。
 */
extern NSString *const DConnectAttributeNameRequestAccessToken;

/*!
 @brief DConnectManagerの非公開用APIを定義する。
 */
@interface DConnectManager ()

/**
 * デバイスプラグインを管理するクラス.
 */
@property (nonatomic) DConnectDevicePluginManager *mDeviceManager;

/**
 * Webサーバを管理するクラス.
 */
@property (nonatomic) DConnectServerManager *webServer;



/**
 * dConnectManagerから相手にイベントを送信する.
 * @param[in] event イベント
 * @return 送信に成功した場合はYES、それ以外はNO
 */
- (BOOL) sendEvent:(DConnectMessage *)event;

/**
 * dConnectManagerから相手にイベントを送信する.
 * @param[in] event イベント
 * @param[in] authorized プラグインのLocal OAuthがONの場合はYES、それ以外はNO
 * @return 送信に成功した場合はYES、それ以外はNO
 */
- (BOOL) sendEvent:(DConnectMessage *)event authorized:(BOOL) authorized;

/**
 * リクエストへのコールバックを登録する.
 *
 * @param[in] callback コールバックblock
 * @param[in] key キー文字列
 */
- (void) addCallback:(DConnectResponseBlocks)callback forKey:(NSString *)key;

/**
 * リクエストへのコールバックを登録する.
 *
 * @param[in] callback コールバックblock
 * @param[in] semaphore 同期管理用のセマフォ
 * @param[in] key キー文字列
 */
- (void) addCallback:(DConnectResponseBlocks)callback semaphore:(dispatch_semaphore_t)semaphore
              forKey:(NSString *)key;

/**
 * リクエストへのコールバックを解除する.
 *
 * @param[in] key キー文字列
 */
- (void) removeCallbackForKey:(NSString *)key;

/*!
 @brief DConnectManagerに非同期的にリクエストを送信する。
 
 DConnectManagerでは、リクエストを非同期的に実行し、対応するレスポンスをcallbackに通知する。<br/>
 このメソッドの実行には時間がかかる場合がある。<br/>
 その場合でも問題が発生しないように注意する必要が有る。<br/>
 
 @param[in] request リクエスト
 @param[in] isHttp HTTPリクエストの場合はYES、ネイティブからのリクエストの場合はNOを指定する
 @param[in] callback コールバック
 */
- (void) sendRequest:(DConnectRequestMessage *) request isHttp:(BOOL)isHttp callback:(DConnectResponseBlocks)callback;

@end
