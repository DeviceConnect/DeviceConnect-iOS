//
//  DConnectCanvasProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*!
 @file
 @brief Canvasプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectCanvasProfileName;

/*!
 @brief アトリビュート: drawImage。
 */
extern NSString *const DConnectCanvasProfileAttrDrawImage;

/*!
 @brief パラメータ: mimetype。
 */
extern NSString *const DConnectCanvasProfileParamMIMEType;

/*!
 @brief パラメータ: data。
 */
extern NSString *const DConnectCanvasProfileParamData;

/*!
 @brief パラメータ: url。
 */
extern NSString *const DConnectCanvasProfileParamURI;

/*!
 @brief パラメータ: X。
 */
extern NSString *const DConnectCanvasProfileParamX;

/*!
 @brief パラメータ: Y。
 */
extern NSString *const DConnectCanvasProfileParamY;

/*!
 @brief パラメータ: mode。
 */
extern NSString *const DConnectCanvasProfileParamMode;


/*!
 @brief 画像描画モード: アスペクト比を保持して画面いっぱいに表示する。
 */
extern NSString *const DConnectCanvasProfileModeScales;

/*!
 @brief 画像描画モード: 画像を並べて敷き詰める。
 */
extern NSString *const DConnectCanvasProfileModeFills;





/*!
 @class DConnectCanvasProfile
 @brief Canvasプロファイル。
 
 Canvas Profileの各APIへのリクエストを受信する。
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectCanvasProfile : DConnectProfile

#pragma mark - Setter

/*!
 @brief メッセージにマイムタイプを設定する。
 @param[in] mimeType マイムタイプ
 @param[in,out] message マイムタイプを格納するメッセージ
 */
+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message;

/*!
 @brief メッセージに画像ファイルのバイナリを設定する。
 @param[in] data 画像ファイルのバイナリ
 @param[in,out] message 画像ファイルのバイナリを格納するメッセージ
 */
+ (void) setData:(NSData *)data target:(DConnectMessage *)message;

/*!
 @brief メッセージに画像ファイルのURLを設定する。
 @param[in] uri 画像ファイルのURL
 @param[in,out] message 画像ファイルのバイナリを格納するメッセージ
 */
+ (void) setURI:(NSString *)uri target:(DConnectMessage *)message;


/*!
 @brief メッセージにX座標を設定する。
 @param[in] x X座標
 @param[in,out] message X座標を格納するメッセージ
 */
+ (void) setX:(double)x target:(DConnectMessage *)message;

/*!
 @brief メッセージにY座標を設定する。
 @param[in] y Y座標
 @param[in,out] message Y座標を格納するメッセージ
 */
+ (void) setY:(double)y target:(DConnectMessage *)message;

/*!
 @brief メッセージに画像描画モードを設定する。
 @param[in] mode 画像描画モード
 @param[in,out] message 画像描画モードを格納するメッセージ
 */
+ (void) setMode:(NSString *)mode target:(DConnectMessage *)message;



#pragma mark - Getter

/*!
 @brief リクエストデータからマイムタイプを取得する。
 @param[in] request リクエストパラメータ
 @return マイムタイプ。無い場合はnilを返す。
 */
+ (NSString *) mimeTypeFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータから画像ファイルのバイナリを取得する。
 @param[in] request リクエストパラメータ
 @return 画像ファイルのバイナリ。無い場合はnilを返す。
 */
+ (NSData *) dataFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータから画像ファイルのURLを取得する。
 @param[in] request リクエストパラメータ
 @return 画像ファイルのバイナリ。無い場合はnilを返す。
 */
+ (NSString *) uriFromRequest:(DConnectMessage *)request;


/*!
 @brief リクエストデータからX座標を取得する。
 @param[in] request リクエストパラメータ
 @return X座標。無い場合はnilを返す。
 */
+ (NSString *) xFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータからY座標を取得する。
 @param[in] request リクエストパラメータ
 @return Y座標。無い場合はnilを返す。
 */
+ (NSString *) yFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータから画像描画モードを取得する。
 @param[in] request リクエストパラメータ
 @return 画像描画モード。無い場合はnilを返す。
 */
+ (NSString *) modeFromRequest:(DConnectMessage *)request;

- (BOOL) isMimeTypeWithString: (NSString *)mimeTypeString;

- (BOOL)isFloatWithString:(NSString *)numberString;

@end
