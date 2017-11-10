//
//  DPHostSimpleHttpServer.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


/*!
 @brief iOS端末からの画像を配信するための簡易サーバ.
 */
@interface DPHostSimpleHttpServer : NSObject

/*!
 @brief ポート番号
 */
@property (nonatomic) NSInteger listenPort;

/*!
 @brief プレビューを送信するためのタイムスライス.
 */
@property (nonatomic) NSInteger timeSlice;

/*!
 @brief サーバを起動します.
 
 @retval YSE サーバの起動に成功
 @retval NO サーバの起動に失敗
 */
- (BOOL) start;

/*!
 @brief サーバを停止します.
 */
- (void) stop;

/*!
 @brief サーバのURLを取得します.
 
 @retval サーバのURL
 */
- (NSString *) getUrl;


/*!
 @brief 配信する画像を設定します.
 
 @param[in] data 画像データ
 */
- (void) offerData:(NSData *)data;

@end
