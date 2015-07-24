//
//  DPThetaManager.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "PtpIpObjectInfo.h"
#import "DPThetaDevicePlugin.h"
#import <UIKit/UIKit.h>

// 接続確認用マクロ
#define CONNECT_CHECK()  BOOL isConnected = [[DPThetaManager sharedManager] connect]; \
if (!isConnected) { \
[response setErrorToTimeoutWithMessage:@"Not Connected to Theta"]; \
return YES; \
} \

// イベント送信用のマクロ
#define SELF_PLUGIN ((DPThetaDevicePlugin *)self.provider)


/*!
 @class DPThetaManager
 @brief Thetaのマネージャクラス。
 
 Thetaの機能を管理する。
 */
@interface DPThetaManager : NSObject

/*!
 @brief DConnectのFileManager。
 */
@property DConnectFileManager *fileMgr;



/*!
 @brief uriとpathを返すブロック。
 @param[out] uri 画像のURI。
 @param[out] path 画像のpath。
 */
typedef void (^DPThetaBlock)(NSString *uri, NSString* path);

/*!
 @brief OnPhotoのイベントを返すためのブロック。
 @param[out] path 画像のpath
 */
typedef void (^DPThetaOnPhotoBlock)(NSString *path);

/*!
 @brief OnStatusChangeのイベントを返すためのブロック。
 @param[out] object Thetaの画像データを保持するオブジェクト
 @param[out] status 動画撮影中のステータス
 @param[out] message エラーメッセージがある場合
 */
typedef void (^DPThetaOnStatusChangeCallback)(PtpIpObjectInfo *object, NSString *status, NSString *message);

/*!
 @brief DPSpheroManagerの共有インスタンスを返す。
 @return DPSpheroManagerの共有インスタンス。
 */
+ (instancetype)sharedManager;

/*!
 @brief Thetaと接続する。
 @return 接続に成功するかどうか
 */
- (BOOL)connect;

/*!
 @brief Thetaとの接続を切断する。
 */
- (void)disconnect;

/*!
 @brief Thetaと接続されているかどうか。
 @return 接続状態
 */
- (BOOL)isConnected;

/*!
 @brief 天球画像を撮影する。
 @param[out] completion レスポンスを返す
 @param[in] fileMgr FileManager
 @return 撮影の成功。
 */
- (BOOL)takePictureWithCompletion:(void(^)(NSString *uri, NSString* path))completion
                          fileMgr:(DConnectFileManager*)fileMgr;

/*!
 @brief 天球動画を撮影する。
 @return 撮影の成功。
 */
- (BOOL)recordingMovie;

/*!
 @brief 天球動画を撮影停止する。
 @return 停止の成功。
 */
- (BOOL)stopMovie;

/*!
 @brief Thetaの電池残量を返す。
 @return 電池残量
 */
- (NSUInteger)getBatteryLevel;

/*!
 @brief ThetaのシリアルNo。
 @return シリアルNo
 */
- (NSString*)getSerialNo;

/*!
 @brief Thetaのステータスを取得する。
 @return ステータス
 */
- (NSUInteger)getCameraStatus;

/*!
 @brief 取得する天球画像のサイズを指定する。
 @param[in] imageSize 画像サイズ
 */
- (void)setImageSize:(CGSize)imageSize;


/*!
 @brief onPhotoイベントを追加する。
 @param[in] serviceId サービスID
 @param[in] fileMgr FileManager
 @param[in] callback イベントを送信する
 */
- (void)addOnPhotoEventCallbackWithID:(NSString*)serviceId
                              fileMgr:(DConnectFileManager*)fileMgr
                             callback:(void (^)(NSString *path))callback;

/*!
 @brief onStatusChangeイベントを追加する。
 @param[in] serviceId サービスID
 @param[in] callback イベントを送信する
 */
- (void)addOnStatusEventCallbackWithID:(NSString*)serviceId
                              callback:(void (^)(PtpIpObjectInfo *object, NSString *status, NSString *message))callback;

/*!
 @brief OnPhotoのイベントを解除する。
 @param[in] serviceId サービスID
 */
- (void)removeOnPhotoEventCallbackWithID:(NSString*)serviceId;


/*!
 @brief OnStatusChangeイベントを解除する。
 @param[in] serviceId サービスID
 */
- (void)removeOnStatusEventCallbackWithID:(NSString*)serviceId;


/*!
 @brief ファイルを削除する。
 @param[in] fileName 削除するファイル名
 @return 削除成功
 */
- (BOOL)removeFileWithName:(NSString*)fileName
                   fileMgr:(DConnectFileManager*)fileMgr;

/*!
 @brief 画像ファイルを取得する。
 @param[in] fileName ファイル名
 @return ファイルのパス
 */
- (NSString*)receiveImageFileWithFileName:(NSString *)fileName
                                  fileMgr:(DConnectFileManager*)fileMgr;


/*!
 @brief 画像リストを取得する。
 @return 画像のファイル名リスト
 */
- (NSMutableArray*)getAllFiles;


/*!
 @brief アプリがバックグラウンドに入った。
 */
- (void)applicationDidEnterBackground ;

/*!
 @brief アプリがフォアグラウンドに入った
 */
- (void)applicationWillEnterForeground;

/*
 数値判定。
 */
+ (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex;
// 整数かどうかを判定する。 true:存在する
+(BOOL)existDigitWithString:(NSString*)digit;
// 少数かどうかを判定する。
+(BOOL)existDecimalWithString:(NSString*)decimal;
@end
