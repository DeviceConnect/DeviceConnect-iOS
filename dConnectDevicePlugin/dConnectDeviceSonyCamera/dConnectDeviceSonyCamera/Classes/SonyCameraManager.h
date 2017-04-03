//
//  SonyCameraManager.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "SampleLiveviewManager.h"
#import "SonyCameraRemoteApiUtil.h"
#import "SonyCameraDevicePlugin.h"


@class SonyCameraService;


/*!
 @brief Sonyカメラへの命令の結果を通知するブロック定義.
 */
typedef void (^SonyCameraBlock)(int errorCode, NSString *errorMessage);

/*!
 @brief 写真撮影の結果を通知するブロック定義.
 */
typedef void (^SonyCameraTakePictureBlock)(NSString *uri);

/*!
 @brief プレビューの結果を通知するブロック定義.
 */
typedef void (^SonyCameraPreviewBlock)(NSString *uri);

/*!
 @brief カメラ状態の取得を通知するブロック定義.
 */
typedef void (^SonyCameraStateBlock)(NSString *state, int width, int height);


/*!
 @brief SonyCameraデバイスプラグインのデリゲート。
 */
@protocol SonyCameraManagerDelegate <NSObject>
@optional

/*!
 @brief デバイスの検索結果を通知.
 
 @param[in] discovery YESの場合は発見、NOの場合は未発見
 */
- (void) didDiscoverDeviceList:(BOOL)discovery;

/*!
 @brief 写真撮影が行われた時の通知.
 
 @param[in] postImageUrl 撮影された画像へのURL
 */
- (void) didTakePicture:(NSString *)postImageUrl;

/*!
 @brief デバイスの発見通知。
 @param[in] service 発見されたサービス
 */
- (void) didAddedService:(SonyCameraService *)service;

/*!
 @brief Wifiの状態が更新されたことを通知.
 */
- (void) didReceiveWiFiStatus;

@end




/*!
 @brief Sonyカメラを制御するためのクラス.
 */
@interface SonyCameraManager : NSObject

/*!
 @brief Sonyカメラからのイベントを通知するデリゲート.
 */
@property (nonatomic, weak) id<SonyCameraManagerDelegate> delegate;

/*!
 @brief Service生成時に登録するプロファイル(DConnectProfile *)の配列
 */
@property (nonatomic, weak) SonyCameraDevicePlugin *plugin;

/*!
 @brief SonyRemoteApi操作用.
 */
@property (nonatomic, strong) SonyCameraRemoteApiUtil *remoteApi;

/*!
 @brief ファイル管理クラス。
 */
@property (nonatomic, strong) DConnectFileManager *mFileManager;

/*!
 @brief Sonyカメラサービスのリスト.
 */
@property (nonatomic, strong) NSMutableArray *sonyCameraServices;

/*!
 @brief サーチフラグ.
 */
@property (nonatomic) BOOL searchFlag;

/*!
 @brief SonyCameraを初期化します.
 
 @param[in] plugin SonyCameraデバイスプラグインのインスタンス
 */
- (instancetype)initWithPlugin:(SonyCameraDevicePlugin *) plugin;

/*!
 @brief 指定されたURLからデータをダウンロードする。
 
 Sony Cameraのデバイスに対してHTTP通信でデータをダウンロードする。
 @param[in] requestURL データが置いてあるURL
 @return データ
 */
- (NSData *) download:(NSString *)requestURL;

/*!
 @brief ファイルを保存する。
 
 ファイル名は、「sony_201408_011500.png」のようにsonyのプレフィックスに時刻が入る。
 
 @param[in] data 保存するデータ
 
 @retval 保存したファイルへのURL
 @retval nil 保存に失敗した場合
 */
- (NSString *) saveFile:(NSData *)data;

/*!
 @brief 現在接続されているWiFiアクセスポイントがSonyカメラのSSIDか確認を行う.
 
 @retval YES Sonyカメラのアクセスポイントの場合
 @retval NO Sonyカメラ以外のアクセスポイントの場合
 */
- (BOOL) checkSSID;

/*!
 @brief 現在接続されているWiFiのSSIDを取得します.
 
 @retval 接続中のWiFiのSSID
 @retval nil 取得に失敗した場合
 */
- (NSString *)getCurrentWifiName;

/*!
 @brief 指定されたサービスを削除します.
 
 @param[in] service 削除するサービス
 */
- (void) removeSonyCamera:(SonyCameraService *)service;

/*!
 @brief Sonyカメラに接続を行います.
 */
- (void) connectSonyCamera;

/*!
 @brief Sonyカメラから切断します.
 */
- (void) disconnectSonyCamera;

/*!
 @brief 指定されたサービスIDに接続されているか確認を行う.
 
 @param serviceId サービスID
 @retval YES 接続されている
 @retval NO 接続されていない
 */
- (BOOL) isConnectedService:(NSString *)serviceId;

/*!
 @brief Sonyカメラの撮影中か確認を行う.
 
 @retval YES 撮影中
 @retval NO IDLE
 */
- (BOOL) isRecording;

/*!
 @brief Sonyカメラがプレビューを表示中か確認を行う.
 
 @retval YES 撮影中
 @retval NO IDLE
 */
- (BOOL) isPreview;

/*!
 @brief ズームをサポートしているかを確認します.
 
 @retval YES サポートしている
 @retval NO サポートしていない
 */
- (BOOL) isSupportedZoom;

/*!
 @brief 写真撮影をサポートしているか確認します.
 
 @retval YES サポートしている
 @retval NO サポートしていない
 */
- (BOOL) isSupportedPicture;

/*!
 @brief 動画撮影をサポートしているか確認します.
 
 @retval YES サポートしている
 @retval NO サポートしていない
 */
- (BOOL) isSupportedRecording;

/*!
 @brief カメラ状態の取得を要求します.
 
 @param block カメラ状態の取得の結果を通知するブロック.
 */
- (void) getCameraState:(SonyCameraStateBlock)block;

/*!
 @brief 写真撮影を要求します.
 
 写真撮影の結果をブロックに通知します.
 @param block 写真撮影の結果を通知するブロック.
 */
- (void) takePicture:(SonyCameraTakePictureBlock)block;

/*!
 @brief プレビューを開始します.
 
 @param timeSlice タイムスライス
 @param block プレビューの通知を行うブロック
 */
- (void) startPreviewWithTimeSlice:(NSNumber *)timeSlice block:(SonyCameraPreviewBlock)block;

/*!
 @brief プレビューを停止します.
 */
- (void) stopPreview;

/*!
 @brief 動画撮影を開始要求を行います.
 
 @param block 動画撮影開始要求の結果を通知するブロック
 */
- (void) startMovieRec:(SonyCameraBlock)block;

/*!
 @brief 動画撮影を停止要求を行います.
 
 @param block 動画撮影停止要求の結果を通知するブロック
 */
- (void) stopMovieRec:(SonyCameraBlock)block;

/*!
 @brief ズームを要求します.
 
 @param direction ズームイン・ズームアウト(in,out)
 @param movement ズームする単位 (max, 1shot, min)
 @param block 結果を通知するブロック
 */
- (void) setZoomByDirection:(NSString *)direction
                   movement:(NSString *)movement
                      block:(SonyCameraBlock)block;

- (double) getZoom;

@end


