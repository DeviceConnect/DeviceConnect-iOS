//
//  DPHostStreamRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Photos/Photos.h>
#import "DPHostStreamRecorder.h"
#import "DPHostUtils.h"

@implementation DPHostStreamRecorder

- (void)initialize
{
    // override subclass
}

// Recordingを開始する
- (void)startRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *fileName))successCompletion
                             failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion
{
    if (self.state == DPHostRecorderStateRecording) {
        failCompletion(self, @"target is already recording.");
        return;
    }
    __block DPHostStreamRecorder *weakSelf = self;
    __block NSError *error = nil;
    [self performWriting:
     ^{
         [weakSelf startRecordingWithError:&error];
         if (error){
             failCompletion(self, error.localizedDescription);
         } else {
             successCompletion(self, nil); // iOSでは、STOP後でないと保存したファイルのURIがわからない
         }
     }];
}
// Recordingを停止する
- (void)stopRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *fileName))successCompletion
                            failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
{
    
    if (self.state == DPHostRecorderStateInactive) {
        failCompletion(self, @"target is not recording.");
        return;
    }
    [self finishRecordingSample];
    
    if (!self.writer) {
        failCompletion(self, @"Writer is non exist.");
        return;
    }
    if (self.writer.status == AVAssetWriterStatusUnknown) {
        failCompletion(self, @"Unknown Failed to finishing an aseet writer");
        return;
    }
    __weak DPHostStreamRecorder *weakSelf = self;
    [self saveMovieFileForCompletionHandler:^(NSURL *assetURL, NSError *error) {
        self.writer = nil;
        self.audioWriterInput = self.videoWriterInput = nil;
        if (error) {
            failCompletion(weakSelf, error.localizedDescription);
        } else {
            successCompletion(weakSelf, [assetURL absoluteString]);
        }
    }];
}
// Recordingを中断する
- (void)pauseRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                             failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
{
    if (self.state == DPHostRecorderStatePaused) {
        failCompletion(self, @"target is already pausing.");
        return;
    }
    if (self.state == DPHostRecorderStateRecording) {
        if ([self.session isRunning]) {
            [self.session stopRunning];
            if ([self.session isRunning]) {
                failCompletion(self, @"Failed to pause the specified recorder; failed to stop capture session.");
                return;
            }
        }
    } else {
        failCompletion(self, @"The specified recorder is not recording; no need for pause.");
        return;
    }
    self.state = DPHostRecorderStatePaused;
    [self setNeedRecalculationOfTotalPauseDuration: YES];
    successCompletion(self);
}
// Recordingを再開する
- (void)resumeRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                              failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion;
{
    if (self.state == DPHostRecorderStateRecording) {
        failCompletion(self, @"target is not pausing.");
        return;
    }
    if (self.state == DPHostRecorderStatePaused) {
        if (![self.session isRunning]) {
            [self.session startRunning];
            if (![self.session isRunning]) {
                failCompletion(self, @"Failed to resume the specified recorder; failed to start capture session.");
                return;
            }
        }
        self.state = DPHostRecorderStateRecording;
        successCompletion(self);
    } else {
        failCompletion(self, @"The specified recorder is not recording; no need for pause.");
    }
}

- (void)muteRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                            failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion
{
    if (!self.audioCaptureDevice) {
        failCompletion(self, @"The specified target does not capture audio and can not be muted.");
        return;
    }
    
    if (!self.isMuted) {
        self.isMuted = YES;
        successCompletion(self);
    } else {
        failCompletion(self, @"The specified recorder is already muted.");
    }
}

- (void)unMuteRecordingWithSuccessCompletion:(void (^)(DPHostStreamRecorder *recorder))successCompletion
                              failCompletion:(void (^)(DPHostStreamRecorder *recorder, NSString *errorMessage))failCompletion
{
    if (!self.audioCaptureDevice) {
        failCompletion(self, @"The specified target does not capture audio and can not be unmuted.");
        return;
    }
    
    if (self.isMuted) {
        self.isMuted = NO;
        successCompletion(self);
    } else {
        failCompletion(self, @"The specified recorder is not muted.");
    }
}

#pragma mark - Protected Method
- (BOOL) appendSampleBuffer:(CMSampleBufferRef)sampleBuffer
                    isAudio:(BOOL)isAudio
{
    @synchronized(self) {
        if (!self.writer) {
            return NO;
        }
        
        if (CMSampleBufferDataIsReady(sampleBuffer)) {
            if (self.writer.status == AVAssetWriterStatusUnknown) {
                if ([self.writer startWriting]) {
                    [self.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                } else {
                    // ライターの書き出し失敗
                    
                    // キャプチャーセッションを停止する。
                    [self.session stopRunning];
                    // TODO: レコーダーの初期化コードを関数化
                    self.state = DPHostRecorderStateInactive;
                    self.audioReady = self.videoReady = NO;
                    self.writer = nil;
                    self.audioWriterInput = self.videoWriterInput = nil;
                    
                    return NO;
                }
            }
            
            if (self.writer.status == AVAssetWriterStatusFailed) {
                self.state = DPHostRecorderStateInactive;
                self.audioReady = self.videoReady = NO;
                self.writer = nil;
                self.audioWriterInput = self.videoWriterInput = nil;
                
                // TODO: エラーイベントを配送する
                
                return NO;
            }
            
            if (self.writer.status == AVAssetWriterStatusWriting) {
                AVAssetWriterInput *writerInput =
                isAudio ? self.audioWriterInput : self.videoWriterInput;
                if (writerInput || sampleBuffer) {
                    if (!writerInput.readyForMoreMediaData) {
                        return NO;
                    }
                    if ([writerInput appendSampleBuffer:sampleBuffer]) {
                        return YES;
                    } else if (self.writer.status == AVAssetWriterStatusFailed) {
                        return NO;
                    }
                }
            }
            
            // TODO: エラーイベントを配送する
            NSLog(@"Failed to append a sample data.");
            return NO;
        }
        
        // TODO: エラーイベントを配送する
        NSLog(@"Sample data is not ready.");
        return NO;
    }
}

#pragma mark - Private Method
// 動画データの保存
- (void)saveMovieFileForCompletionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler {

    void (^recordBlock) (void) = ^(void){
        [self.writer finishWritingWithCompletionHandler:
         ^{
             
             if (self.writer.status == AVAssetWriterStatusFailed) {
                 completionHandler(nil,  [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to finishing an aseet writer"]);
                 return;
             }
             __block NSURL *fileUrl = self.writer.outputURL;
             __block PHObjectPlaceholder *placeHolder;
             [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                 PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
                 placeHolder = [assetRequest placeholderForCreatedAsset];
             }   completionHandler:^(BOOL success, NSError *error) {
                 if (error) {
                     completionHandler(nil, [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:error.localizedDescription]);
                     return;
                 }
                 NSError *err = nil;
                 [[NSFileManager defaultManager] removeItemAtURL:fileUrl error:&err];
                 completionHandler([NSURL URLWithString:placeHolder.localIdentifier], err);
             }];
         }];
    };
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
        default:
            break;
        case PHAuthorizationStatusNotDetermined:
        case PHAuthorizationStatusRestricted:
        case PHAuthorizationStatusDenied:
            dispatch_async(dispatch_get_main_queue(), ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                    switch (status) {
                        case PHAuthorizationStatusNotDetermined:
                        case PHAuthorizationStatusRestricted:
                        case PHAuthorizationStatusDenied:
                            completionHandler(nil, [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Not Authorized to Record."]);
                            return;
                        case PHAuthorizationStatusAuthorized:
                        default:
                            break;
                    }
                    recordBlock();
                }];

            });
            return;

    }
    recordBlock();
}
@end
