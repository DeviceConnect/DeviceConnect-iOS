//
//  DPHostStreamRecorder.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHostRecorder.h"

@interface DPHostStreamRecorder : DPHostRecorder
// Recordingを開始する
- (void)startRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *fileName))successCompletion
                             failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
// Recordingを停止する
- (void)stopRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *fileName))successCompletion
                            failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
// Recordingを中断する
- (void)pauseRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                             failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
// Recordingを再開する
- (void)resumeRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                              failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
// RecordingをMuteする
- (void)muteRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                              failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
// RecordingをUnmuteする
- (void)unMuteRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                            failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;

// 録画データの統合
- (BOOL) appendSampleBuffer:(CMSampleBufferRef)sampleBuffer
                    isAudio:(BOOL)isAudio;
@end
