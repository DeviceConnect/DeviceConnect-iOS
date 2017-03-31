//
//  SonyCameraPreview.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class SonyCameraRemoteApiUtil;

/*!
 @brief Sonyカメラからのプレビューを制御するためのクラス.
 */
@interface SonyCameraPreview : NSObject

- (instancetype)initWithRemoteApi:(SonyCameraRemoteApiUtil *)remoteApi;

/*!
 @brief プレビューを開始します.
 
 @retval YES プレビューの開始に成功
 @retval NO プレビューの開始に失敗
 */
- (BOOL) startPreviewWithTimeSlice:(NSNumber *)timeSlice;

/*!
 @brief プレビューを停止します.
 */
- (void) stopPreview;

/*!
 @brief プレビュー再生中フラグを取得します.
 
 @retval YSE プレビュー再生中
 @retval NO プレビュー停止中
 */
- (BOOL) isRunning;

/*!
 @brief プレビュー画像を配信するサーバへのURLを取得します.
 
 @retval プレビュー画像を配信するサーバへのURL
 @retval サーバが起動していない場合にはnil
 */
- (NSString *)getUrl;

@end
