//
//  DConnectFileDescriptorProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! 
 @file
 @brief FileDescriptorプロファイルを実装するための機能を提供する。
 @author NTT DOCOMO
 */
#import <DConnectSDK/DConnectProfile.h>

/*!
 @brief プロファイル名。
 */
extern NSString *const DConnectFileDescriptorProfileName;

/*!
 @brief アトリビュート: open。
 */
extern NSString *const DConnectFileDescriptorProfileAttrOpen;

/*!
 @brief アトリビュート: close。
 */
extern NSString *const DConnectFileDescriptorProfileAttrClose;

/*!
 @brief アトリビュート: read。
 */
extern NSString *const DConnectFileDescriptorProfileAttrRead;

/*!
 @brief アトリビュート: write。
 */
extern NSString *const DConnectFileDescriptorProfileAttrWrite;

/*!
 @brief アトリビュート: onwatchfile。
 */
extern NSString *const DConnectFileDescriptorProfileAttrOnWatchFile;

/*!
 @brief パラメータ: flag。
 */
extern NSString *const DConnectFileDescriptorProfileParamFlag;

/*!
 @brief パラメータ: length。
 */
extern NSString *const DConnectFileDescriptorProfileParamPosition;

/*!
 @brief パラメータ: size。
 */
extern NSString *const DConnectFileDescriptorProfileParamSize;

/*!
 @brief パラメータ: length。
 */
extern NSString *const DConnectFileDescriptorProfileParamLength;

/*!
 @brief パラメータ: binary。
 */
extern NSString *const DConnectFileDescriptorProfileParamFileData;

/*!
 @brief パラメータ: media。
 */
extern NSString *const DConnectFileDescriptorProfileParamMedia;

/*!
 @brief パラメータ: file。
 */
extern NSString *const DConnectFileDescriptorProfileParamFile;

/*!
 @brief パラメータ: curr。
 */
extern NSString *const DConnectFileDescriptorProfileParamCurr;

/*!
 @brief パラメータ: prev。
 */
extern NSString *const DConnectFileDescriptorProfileParamPrev;

/*!
 @brief パラメータ: path。
 */
extern NSString *const DConnectFileDescriptorProfileParamPath;

/*!
 @class DConnectFileDescriptorProfile
 @brief File Descriptorプロファイル。
 
 File Descriptor Profileの各APIへのリクエストを受信する｡
 受信したリクエストは各API毎にデリゲートに通知される。
 
 @deprecated
 本クラスで定義していた定数はSwagger形式の定義ファイルで管理することになったので、このクラスは使用しないこととする。
 プロファイルを実装する際は本クラスではなく、@link DConnectProfile @endlink クラスを継承すること。
 */
@interface DConnectFileDescriptorProfile : DConnectProfile

#pragma mark - Setter

/*!
 @brief メッセージに現在の更新時間を設定する。
 @param[in] curr 現在の更新時間
 @param[in,out] message 現在の更新時間を格納するメッセージ
 */
+ (void) setCurr:(NSString *)curr target:(DConnectMessage *)message;

/*!
 @brief メッセージに以前の更新時間を設定する。
 @param[in] prev 以前の更新時間
 @param[in,out] message 以前の更新時間を格納するメッセージ
 */
+ (void) setPrev:(NSString *)prev target:(DConnectMessage *)message;

/*!
 @brief メッセージに読み込んだファイルのサイズを設定する。
 @param[in] size 読み込んだファイルのサイズ
 @param[in,out] message 読み込んだファイルのサイズを格納するメッセージ
 */
+ (void) setSize:(long long)size target:(DConnectMessage *)message;

/*!
 @brief メッセージにファイルデータを設定する。
 @param[in] fileData ファイルデータ
 @param[in,out] message ファイルデータを格納するメッセージ
 */
+ (void) setFileData:(NSString *)fileData target:(DConnectMessage *)message;

/*!
 @brief メッセージにパスを設定する。
 @param[in] path パス
 @param[in,out] message ファイルデータを格納するメッセージ
 */
+ (void) setPath:(NSString *)path target:(DConnectMessage *)message;

/*!
 @brief メッセージにファイル情報を設定する。
 @param[in] file ファイル情報
 @param[in,out] message ファイル情報を格納するメッセージ
 */
+ (void) setFile:(DConnectMessage *)file target:(DConnectMessage *)message;

#pragma mark - Getter

/*!
 @brief リクエストデータからファイルパスを取得する。
 @param[in] request リクエストパラメータ
 @return ファイルパス。無い場合はnilを返す。
 */
+ (NSString *) pathFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータからフラグを取得する。
 @param[in] request リクエストパラメータ
 @return フラグ文字列。無い場合はnilを返す。
 */
+ (NSString *) flagFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータからファイル長を取得する。
 @param[in] request リクエストパラメータ
 @return ファイル長。無い場合はnilを返す。
 */
+ (NSNumber *) lengthFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータから読み込み/書き込み位置を取得する。
 @param[in] request リクエストパラメータ
 @return 読み込み/書き込み位置。無い場合はnilを返す。
 */
+ (NSNumber *) positionFromRequest:(DConnectMessage *)request;

/*!
 @brief リクエストデータからバイナリを取得する。
 @param[in] request リクエストパラメータ
 @return バイナリ。無い場合はnilを返す。
 */
+ (NSData *) mediaFromRequest:(DConnectMessage *)request;

@end
