//
//  DPHostRecorder.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectFileManager.h>

#import <AssetsLibrary/AssetsLibrary.h>

#import "DPHostSimpleHttpServer.h"

@interface DPHostRecorder : NSObject

#pragma mark - Enum
typedef NS_ENUM(NSUInteger, DPHostRecorderState) {
    DPHostRecorderStateInactive,  ///< 撮影状態「撮影していない ("inactive"))」
    DPHostRecorderStatePaused,    ///< 撮影状態「撮影一時停止中 ("paused")」
    DPHostRecorderStateRecording, ///< 撮影状態「撮影中 ("recording")」
};

#pragma mark - Field
@property AVCaptureSession *session;
@property AVCaptureDevice *videoCaptureDevice;
@property AVCaptureDevice *audioCaptureDevice;
@property (nonatomic) AVCaptureConnection *photoConnection;
@property (nonatomic) AVCaptureConnection *audioConnection;
@property (nonatomic) AVCaptureConnection *videoConnection;
@property (nonatomic) AVAssetWriter *writer;

/// <code>writer</code>へのオーディオ入力
@property (nonatomic) AVAssetWriterInput *audioWriterInput;
/// <code>writer</code>へのビデオ入力
@property (nonatomic) AVAssetWriterInput *videoWriterInput;
/// ビデオ入力デバイスのレコーディング準備が整っているかどうか
@property (nonatomic) BOOL audioReady;
/// ビデオ入力デバイスのレコーディング準備が整っているかどうか
@property (nonatomic) BOOL videoReady;
/// ポーズの累計期間を再計算する必要が有るかどうか
@property BOOL needRecalculationOfTotalPauseDuration;

// ID
@property NSString *recorderId;
// Recorder名
@property NSString *name;
// RecorderのMimeType
@property NSString *mimeType;
// Recorderの状態
@property DPHostRecorderState state;
// レコーダがミュート状態かどうか
@property BOOL isMuted;
// レコーダの解像度
@property CGSize pictureSize;
// レコーダのプレビューサイズ
@property CGSize previewSize;
// レコーダがサポートしている解像度
@property NSArray *supportedPictureSizes;
// レコーダがサポートしているプレビューのサイズ
@property NSArray *supportedPreviewSizes;
// レコードがサポートしているMimeType
@property NSArray *supportedMimeTypes;


// コンストラクタ
- (instancetype)initWithRecorderId:(NSNumber*)recorderId
                       videoDevice:(AVCaptureDevice*)videoDevice
                       audioDevice:(AVCaptureDevice*)audioDevice;

#pragma mark - Abstract
// 初期化
- (void)initialize;
// リセット
- (void)clean;

#pragma mark - Protected Util Method
/*!
 @brief このコンテキストに対して読み取り処理を行う。処理が終わるまでreturnしない。
 Read/Writeスキームに従い、特定のスレッドで読み取り処理が進行している場合、
 件のスレッド以外のスレッドから読み取り処理を実行できるが、書き込み処理は全ての読み取り処理が
 終了するまで実行されない。
 @param callback 読み取り処理を行うブロック
 */
- (void) performReading:(void(^)(void))callback;
/*!
 @brief このコンテキストに対して書き込み処理を行う。処理が終わるまでreturnしない。
 Read/Writeスキームに従い、特定のスレッドで書き込み処理が進行している場合、
 あらゆるスレッドからの追加の読み取り・書き込み処理は、件の読み取り処理が終了するまで実行されない。
 @param callback 書き込み処理を行うブロック
 */
- (void) performWriting:(void(^)(void))callback;
// レコーディングのスタート
- (void)startRecordingWithError:(NSError **)error;
// レコーディングのストップ
- (void)finishRecordingSample;
// Photo用のSourceTypeの設定
- (void)setPhotoDataSourceType;
// Video用のSourceTypeの設定
- (void)setVideoSourceTypeWithDelegate:(id)delegate;
// Audio用のSourceTypeの設定
- (void)setAudioSourceTypeWithDelegate:(id)delegate;
// AudioConnectionの初期化
- (void)initAudioConnection:(AVCaptureConnection *)connection formatDescription:(CMFormatDescriptionRef)formatDescription;
// VideoConnectionの初期化
- (void)initVideoConnection:(AVCaptureConnection * )connection formatDescription:(CMFormatDescriptionRef)formatDescription;
// 総再生時間の計算
- (void)needRecalculationOfTotalPauseDurationForIsAudio:(BOOL)isAudio
                          originalSampleBufferTimestamp:(const CMTime *)originalSampleBufferTimestamp;
// タイムスタンプの調整
- (void)adjustTimeStamp:(BOOL *)adjustTimestamp
                 buffer:(CMSampleBufferRef *)buffer
         requireRelease:(BOOL *)requireRelease
           sampleBuffer:(CMSampleBufferRef)sampleBuffer;
// バッファーをミュートにする
- (void)muteWithBuffer:(CMSampleBufferRef)buffer
        initMuteSample:(BOOL *)initMuteSample
               isAudio:(BOOL)isAudio;
//最後のタイムスタンプを更新
- (void)updateLastSampleTimestampWithBuffer:(CMSampleBufferRef)buffer
                                    isAudio:(BOOL)isAudio
                               sampleBuffer:(CMSampleBufferRef)sampleBuffer
                  updateLastSampleTimestamp:(BOOL *)updateLastSampleTimestamp;
@end
