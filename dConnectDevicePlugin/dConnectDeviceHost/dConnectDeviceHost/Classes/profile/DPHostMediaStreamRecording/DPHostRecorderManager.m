//
//  DPHostRecorderManager.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <ImageIO/ImageIO.h>
#import "DPHostDevicePlugin.h"
#import "DPHostService.h"
#import "DPHostRecorderManager.h"
#import "DPHostRecorderContext.h"
#import "DPHostUtils.h"
#import "DPHostRecorderManager.h"
#import "DPHostSimpleHttpServer.h"

@interface DPHostRecorderManager ()

/*!
 @brief Preview用のHTTPサーバ。
 */
@property (nonatomic) DPHostSimpleHttpServer *httpServer;

/*!
 デフォルトの静止画レコーダーのID
 iOSデバイスによっては背面カメラが無かったりと差異があるので、
 ランタイム時にデフォルトのレコーダーを決定する処理を行う。
 */
@property (nonatomic) NSNumber *defaultPhotoRecorderId;
/*!
 デフォルトの動画レコーダーのID
 iOSデバイスによっては背面カメラが無かったりと差異があるので、
 ランタイム時にデフォルトのレコーダーを決定する処理を行う。
 */
@property (nonatomic) NSNumber *defaultVideoRecorderId;
/*!
 デフォルトの音声レコーダーのID
 */
@property (nonatomic) NSNumber *defaultAudioRecorderId;
/*!
 カレントのレコーダーのID
 */
@property (nonatomic) NSNumber *currentRecorderId;

/*!
 現在実行中のPreview
 */
@property (nonatomic) NSMutableArray *nowCurrentRecorders;
/// レコーダーで使用できる静止画入力データ
@property (nonatomic) NSMutableArray *photoDataSourceArr;
/// レコーダーで使用できる動画入力データ
@property (nonatomic) NSMutableArray *audioDataSourceArr;
/// レコーダーで使用できる音声入力データ
@property (nonatomic) NSMutableArray *videoDataSourceArr;

/// 使用できるレコーダー
@property (nonatomic) NSMutableArray *recorderArr;

/// TODO: PHPhotoLibraryに変更する
@property ALAssetsLibrary *library;


/*!
 @brief iOSデバイスの向き
 画面が天井や地面を向いた際は、無視して以前の向き情報を保持する。
 UIDeviceOrientationPortraitUpsideDown:
 この場合、iOSデバイスを正面に見据えて、デバイスを反時計回りに180°回転し、
 Homeボタンが上方向にある状態。
 UIDeviceOrientationLandscapeLeft:
 この場合、iOSデバイスを正面に見据えて、デバイスを反時計回りに90°回転し、
 Homeボタンが右方向にある状態。
 */
@property (nonatomic) UIDeviceOrientation referenceOrientation;

/// 前回プレビューを送った時間。
@property (nonatomic) CMTime lastPreviewTimestamp;
/// Data Available Event APIでプレビュー画像URIの配送を行うかどうか。
@property (nonatomic) BOOL sendPreview;
/// Data Available Event APIでプレビュー画像URIの配送を行うインターバル（秒）。
@property (nonatomic) CMTime secPerFrame;

/// ポーズ前最後のサンプルのタイムスタンプ
@property CMTime lastSampleTimestamp;
/// ポーズの累計期間
@property CMTime totalPauseDuration;
/// ポーズの累計期間を再計算する必要が有るかどうか
@property BOOL needRecalculationOfTotalPauseDuration;
/**
 @brief 現在のプレビュー画像の連番。
 Data Available Event APIで送るプレビュー画像は0-99までの連番を組み込んだ固定名を与えるの
 で、現在0-99までのどの連番を使ったかを管理する。
 */
@property int curPreviewImageEnumerator;
@end


@implementation DPHostRecorderManager
// 共有インスタンス
+ (instancetype)sharedManager
{
    static id sharedInstance;
    static dispatch_once_t onceSpheroToken;
    dispatch_once(&onceSpheroToken, ^{
        sharedInstance = [DPHostRecorderManager new];
        [sharedInstance initVariables];
        [sharedInstance initRecorderDataSource];
        [sharedInstance initPhotoRecorders];
        [sharedInstance initVideoRecorders];
        [sharedInstance initAudioRecorders];
    });
    return sharedInstance;
}


#pragma mark - Public method

- (NSArray*)playStatus
{
    return self.recorderArr;
}

- (void)takephotoForTarget:(NSString*)target completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler
{
    __block NSError *error = nil;
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypePhoto error:&error];
    if (error) {
        completionHandler(nil, error);
        return;
    }
    NSString *usedRecorderName = [self usedVideoContextForRecorder:recorder];
    if (usedRecorderName) {
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:[NSString stringWithFormat:@"Video device is currently used by %@.",
          usedRecorderName]];
        completionHandler(nil, error);
        return;
    }
    __weak DPHostRecorderManager *weakSelf = self;
    if (recorder.videoConnection.supportsVideoOrientation) {
        recorder.videoConnection.videoOrientation = videoOrientationFromDeviceOrientation([UIDevice currentDevice].orientation);
    }

    [recorder performWriting:
     ^{
         if (recorder.type != RecorderTypePhoto) {
             error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"target is not a video device; it is not capable of taking a photo."];
             completionHandler(nil, error);
             return;
         }
         
         if (![recorder.session isRunning]) {
             [recorder.session startRunning];
         }
         
         // ライトが点いていたら消灯する。
         [weakSelf setLightOff];
         // 写真を撮影する。
         [weakSelf takePhotoInternal:recorder];
 
         [weakSelf saveFileWithRecorder:recorder completionHandler:^(NSURL *assetURL, NSError *error) {
             
             if ([recorder.session isRunning]) {
                 [recorder.session stopRunning];
             }
             completionHandler(assetURL, error);
         }];
     }];
    return;
}

// POST /mediastreamrecording/record
- (void)recordForTarget:(NSString*)target timeSlice:(NSNumber*)timeSlice completionHandler:(void (^)(NSError *))completionHandler
{
    __block NSError *error = nil;
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:&error];
    if (error) {
        completionHandler(error);
        return;
    }
    
    if (recorder.state == RecorderStateRecording) {
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"target is already recording."];
        completionHandler(error);
        return;
    }
    // 入力デバイスが既に他のレコーダーで使われていないかをチェックする
    NSString *usedVideoRecorderName = [self usedVideoContextForRecorder:recorder];
    if (usedVideoRecorderName) {
        // ビデオ入力デバイスが既に他のコンテキストで使われている。
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:
         [NSString stringWithFormat:@"Video device is currently used by %@.",
          usedVideoRecorderName]];
        completionHandler(error);
        return;
    }
    NSString *usedAudioRecorderName = [self usedAudioContextForRecorder:recorder];
    if (usedAudioRecorderName) {
        // オーディオ入力デバイスが既に他のコンテキストで使われている。
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:
         [NSString stringWithFormat:@"Audio device is currently used by %@.",
          usedAudioRecorderName]];
        completionHandler(error);
        return;
    }
    __weak DPHostRecorderManager *weakSelf = self;
    [recorder performWriting:
     ^{
         [weakSelf startRecordingForRecorder:recorder error:&error];
         completionHandler(error);
     }];
    return;
}

// PUT /mediastreamrecording/stop
- (void)stopForTarget:(NSString*)target completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler
{
    NSError *error = nil;
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:&error];
    if (error) {
        completionHandler(nil, error);
        return;
    }
    if (recorder.state == RecorderStateInactive) {
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"target is not recording."];
        completionHandler(nil, error);
        return;
    }
    
    [self finishRecordingSampleForRecorder:recorder];
    
    if (!recorder.writer) {
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"Writer is non exist."];
        completionHandler(nil, error);
        return;
    }
    if (recorder.writer.status == AVAssetWriterStatusUnknown) {
        error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"Unknown Failed to finishing an aseet writer"];
        completionHandler(nil, error);
        return;
    }
    __weak DPHostRecorderManager *weakSelf = self;
    [self saveMovieFileForRecorder:recorder completionHandler:^(NSURL *assetURL, NSError *error) {
        weakSelf.currentRecorderId = nil;
        recorder.writer = nil;
        recorder.audioWriterInput = recorder.videoWriterInput = nil;
        completionHandler(assetURL, error);
    }];
}

// PUT /mediastreamrecording/pause
- (void)pauseForTarget:(NSString*)target error:(NSError**)error
{
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];
    if (*error) {
        return;
    }
    
    if (recorder.state == RecorderStatePaused) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"target is already pausing."];
        return;
    }
    
    if (recorder.state == RecorderStateRecording) {
        if ([recorder.session isRunning]) {
            [recorder.session stopRunning];
            if ([recorder.session isRunning]) {
                *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
                 @"Failed to pause the specified recorder; failed to stop capture session."];
                return;
            }
        }
        
        recorder.state = RecorderStatePaused;
        
        [self setNeedRecalculationOfTotalPauseDuration: YES];
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:
         @"The specified recorder is not recording; no need for pause."];
    }
}

// PUT /mediastreamrecording/resume
- (void)resumeForTarget:(NSString*)target error:(NSError**)error
{
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];
    if (*error) {
        return;
    }
    if (recorder.state == RecorderStateRecording) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"target is not pausing."];
        return;
    }
    if (recorder.state == RecorderStatePaused) {
        if (![recorder.session isRunning]) {
            [recorder.session startRunning];
            if (![recorder.session isRunning]) {
                *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
                 @"Failed to resume the specified recorder; failed to start capture session."];
                return;
            }
        }
        recorder.state = RecorderStateRecording;
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:
         @"The specified recorder is not recording; no need for pause."];
    }
}

// PUT /mediastreamrecording/mutetrack
- (void)muteTrackForTarget:(NSString*)target error:(NSError**)error
{
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];
    if (*error) {
        return;
    }
    
    if (!recorder.audioDevice) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:
         @"The specified target does not capture audio and can not be muted."];
        return;
    }
    
    if (!recorder.isMuted) {
        recorder.isMuted = YES;
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"The specified recorder is already muted."];
    }
    
}

// PUT /mediastreamrecording/unmutetrack
- (void)unmuteTrackForTarget:(NSString*)target error:(NSError**)error
{
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];
    if (*error) {
        return;
    }
    
    if (!recorder.audioDevice) {
         *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:
         @"The specified target does not capture audio and can not be unmuted."];
        return;
    }
    
    if (recorder.isMuted) {
        recorder.isMuted = NO;
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"The specified recorder is not muted."];
    }
}

// PUT /mediaStreamRecording/preview
- (NSString*)startPreviewForTarget:(NSString*)target error:(NSError**)error
{
    if (self.httpServer) {
        [self.httpServer stop];
        self.httpServer = nil;
    }
    
    self.httpServer = [DPHostSimpleHttpServer new];
    self.httpServer.listenPort = 10000;
    BOOL result = [self.httpServer start];
    if (!result) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"MJPEG Server cannot running."];
        return nil;
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5);
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];
    // Recording startはMovie用のtargetを指定しなければならないため、置き換える必要がある。
    NSRange photoBackRange = [recorder.name rangeOfString:@"photo_back"];
    NSRange photoFrontRange = [recorder.name rangeOfString:@"photo_front"];
    if (photoBackRange.location != NSNotFound && photoFrontRange.location == NSNotFound) {
        target = @"2";  // movie_audio_video_back_0
    } else if (photoBackRange.location == NSNotFound && photoFrontRange.location != NSNotFound) {
        target = @"3"; // movie_audio_video_front_0
    } else if (!target) {
        target = @"2"; //指定されていない場合はデフォルト
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"This target does not support preview."];
        return nil;
    }
    __block NSError *blockError = nil;
    [self recordForTarget:target timeSlice:nil completionHandler:^(NSError *err) {
        if (err) {
            blockError = [DPHostUtils throwsErrorCode:err.code message:err.localizedDescription];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, timeout);
    *error = blockError;
    [self.nowCurrentRecorders addObject:target];
    // プレビュー画像URIの配送処理が開始されていないのなら、開始する。
    self.sendPreview = YES;
    NSString *url = [self.httpServer getUrl];
    if (!url) {
        [self.httpServer stop];
        self.httpServer = nil;
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"MJPEG Server cannot running."];
        return nil;
    }
    return url;
}

// DELETE /mediaStreamRecording/preview
- (void)stopPreviewForTarget:(NSString*)target error:(NSError**)error
{
    if (self.httpServer) {
        [self.httpServer stop];
        self.httpServer = nil;
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5);
    DPHostRecorderContext *recorder = [self recorderForTarget:target recorderType:RecorderTypeMovie error:error];

    // Recording startはMovie用のtargetを指定しなければならないため、置き換える必要がある。
    NSRange photoBackRange = [recorder.name rangeOfString:@"photo_back"];
    NSRange photoFrontRange = [recorder.name rangeOfString:@"photo_front"];
    if (photoBackRange.location != NSNotFound && photoFrontRange.location == NSNotFound) {
        target = @"2";  // movie_audio_video_back_0
    } else if (photoBackRange.location == NSNotFound && photoFrontRange.location != NSNotFound) {
        target = @"3"; // movie_audio_video_front_0
    } else if (!target) {
        target = @"2"; //指定されていない場合はデフォルト
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeIllegalDeviceState message:@"This target does not support preview."];
        return;
    }
    __block NSError *blockError = nil;
    [self stopForTarget:target completionHandler:^(NSURL *assetURL, NSError *err) {
        if (err) {
            blockError = [DPHostUtils throwsErrorCode:err.code message:err.localizedDescription];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, timeout);
    *error = blockError;
    [self.nowCurrentRecorders removeObject:target];

    // イベント受領先が存在しないなら、プレビュー画像URIの配送処理を停止する。
    self.sendPreview = NO;
    // 次回プレビュー開始時に影響を与えない為に、初期値（無効値）を設定する。
    self.lastPreviewTimestamp = kCMTimeInvalid;
}



#pragma mark - MediaStreamRecording Profile Init Internal
- (void)initVariables
{
    self.httpServer = nil;
    self.nowCurrentRecorders = [NSMutableArray array];
    self.recorderArr = [NSMutableArray array];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange)
                               name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    self.curPreviewImageEnumerator = 0;
    self.currentRecorderId = nil;
    self.secPerFrame = CMTimeMake(2, 1000);
    self.lastPreviewTimestamp = kCMTimeInvalid;
    self.lastSampleTimestamp = kCMTimeInvalid;
    self.totalPauseDuration = kCMTimeInvalid;
    self.needRecalculationOfTotalPauseDuration = NO;
    self.library = [ALAssetsLibrary new];
    self.photoDataSourceArr = [NSMutableArray array];
    self.audioDataSourceArr = [NSMutableArray array];
    self.videoDataSourceArr = [NSMutableArray array];
    self.sendPreview = NO;
}
- (void)initRecorderDataSource
{
    AVCaptureSession *session;
    NSArray *audioDevArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    NSArray *videoDevArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    DPHostRecorderDataSource *recCtx;
    session = [AVCaptureSession new];
    for (AVCaptureDevice *audioDev in audioDevArr) {
        // 出力：音声
        recCtx = [DPHostRecorderDataSource recorderDataSourceForAudioWithAudioDevice:audioDev];
        
        if (recCtx) {
            recCtx.position = audioDev.position;
            [self.audioDataSourceArr addObject:recCtx];
        }
    }
    for (AVCaptureDevice *videoDev in videoDevArr) {
        recCtx = [DPHostRecorderDataSource recorderDataSourceForPhotoWithVideoDevice:videoDev];
        
        if (recCtx) {
            recCtx.position = videoDev.position;
            [self.photoDataSourceArr addObject:recCtx];
        }
        session = [AVCaptureSession new];
        recCtx = [DPHostRecorderDataSource recorderDataSourceForVideoWithVideoDevice:videoDev];
        
        if (recCtx) {
            recCtx.position = videoDev.position;
            NSMutableArray *dimensionArr =
            @[
              AVCaptureSessionPreset352x288,
              AVCaptureSessionPreset640x480,
              AVCaptureSessionPreset1280x720,
              AVCaptureSessionPreset1920x1080
              ].mutableCopy;
            for (size_t i = 0; i < dimensionArr.count; ++i) {
                if (![session canSetSessionPreset:dimensionArr[i]]) {
                    [dimensionArr removeObjectAtIndex:i];
                }
            }
            NSDictionary *(^getDimension)(NSString *) = ^ NSDictionary *(NSString *preset) {
                if ([preset isEqualToString:AVCaptureSessionPreset352x288]) {
                    return @{@"h":@352 ,@"w":@288};
                } else if ([preset isEqualToString:AVCaptureSessionPreset640x480]) {
                    return @{@"h":@640 ,@"w":@480};
                } else if ([preset isEqualToString:AVCaptureSessionPreset1280x720]) {
                    return @{@"h":@1280 ,@"w":@720};
                } else if ([preset isEqualToString:AVCaptureSessionPreset1920x1080]) {
                    return @{@"h":@1920 ,@"w":@1080};
                }
                return nil;
            };
            NSDictionary *minDim = getDimension([dimensionArr firstObject]);
            NSDictionary *maxDim = getDimension([dimensionArr lastObject]);
            recCtx.imageHeight = recCtx.minImageHeight = minDim[@"h"];
            recCtx.imageWidth = recCtx.minImageWidth = minDim[@"w"];
            recCtx.maxImageHeight = maxDim[@"h"];
            recCtx.maxImageWidth = maxDim[@"w"];
            
            [self.videoDataSourceArr addObject:recCtx];
        }
    }
}

- (void)initPhotoRecorders
{
    unsigned long videoNormalCount = 0;
    unsigned long videoBackCount = 0;
    unsigned long videoFrontCount = 0;
    for (DPHostRecorderDataSource *dataSrc in self.photoDataSourceArr) {
        if ([dataSrc.uniqueId isEqualToString:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].uniqueID]) {
            self.defaultPhotoRecorderId = [NSNumber numberWithUnsignedInteger:self.recorderArr.count];
        }
        
        DPHostRecorderContext *recorder = [[DPHostRecorderContext alloc] init];
        recorder.type = RecorderTypePhoto;
        recorder.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"jpg"];
        recorder.state = RecorderStateInactive;
        
        [recorder setRecorderDataSource:dataSrc delegate:self];
        
        NSMutableString *name = @"photo_".mutableCopy;
        switch (dataSrc.position) {
            case AVCaptureDevicePositionBack:
                [name appendString:@"back_"];
                [name appendString:[NSString stringWithFormat:@"%lu", videoBackCount]];
                ++videoBackCount;
                break;
            case AVCaptureDevicePositionFront:
                [name appendString:@"front_"];
                [name appendString:[NSString stringWithFormat:@"%lu", videoFrontCount]];
                ++videoFrontCount;
                break;
            case AVCaptureDevicePositionUnspecified:
            default:
                [name appendString:[NSString stringWithFormat:@"%lu", videoNormalCount]];
                ++videoNormalCount;
                break;
        }
        recorder.name = [NSString stringWithString:name];
        
        [self.recorderArr addObject:recorder];
    }
}

- (void)initVideoRecorders
{
    unsigned long audioVideoNormalCount = 0;
    unsigned long audioVideoBackCount = 0;
    unsigned long audioVideoFrontCount = 0;
    for (DPHostRecorderDataSource *videoDataSrc in self.videoDataSourceArr) {
        // 動画（ビデオのみ）
        if (self.audioDataSourceArr.count == 0
            && [videoDataSrc.uniqueId isEqualToString:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].uniqueID]) {
            self.defaultVideoRecorderId = [NSNumber numberWithUnsignedInteger:self.recorderArr.count];
        }
        DPHostRecorderContext *recorder;
        NSMutableString *name;
        
        for (DPHostRecorderDataSource *audioDataSrc in self.audioDataSourceArr) {
            // 動画（動画・音声）
            if ([videoDataSrc.uniqueId isEqualToString:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].uniqueID]) {
                self.defaultVideoRecorderId = [NSNumber numberWithUnsignedInteger:self.recorderArr.count];
            }
            
            recorder = [[DPHostRecorderContext alloc] init];
            recorder.type = RecorderTypeMovie;
            recorder.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
            recorder.state = RecorderStateInactive;
            
            [recorder setRecorderDataSource:audioDataSrc delegate:self];
            [recorder setRecorderDataSource:videoDataSrc delegate:self];
            
            name = @"movie_audio_video_".mutableCopy;
            switch (videoDataSrc.position) {
                case AVCaptureDevicePositionBack:
                    [name appendString:@"back_"];
                    [name appendString:[NSString stringWithFormat:@"%lu", audioVideoBackCount]];
                    ++audioVideoBackCount;
                    break;
                case AVCaptureDevicePositionFront:
                    [name appendString:@"front_"];
                    [name appendString:[NSString stringWithFormat:@"%lu", audioVideoFrontCount]];
                    ++audioVideoFrontCount;
                    break;
                case AVCaptureDevicePositionUnspecified:
                default:
                    [name appendString:[NSString stringWithFormat:@"%lu", audioVideoNormalCount]];
                    ++audioVideoNormalCount;
                    break;
            }
            recorder.name = [NSString stringWithString:name];
            
            [self.recorderArr addObject:recorder];
        }
    }
}

- (void)initAudioRecorders
{
    unsigned long audioCount = 0;
    for (DPHostRecorderDataSource *audioDataSrc in self.audioDataSourceArr) {
        DPHostRecorderContext *recorder;
        NSMutableString *name;
        
        // 動画（音声のみ）
        recorder = [[DPHostRecorderContext alloc] init];
        recorder.type = RecorderTypeMovie;
        recorder.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
        recorder.state = RecorderStateInactive;
        
        [recorder setRecorderDataSource:audioDataSrc delegate:self];
        
        name = @"movie_audio_".mutableCopy;
        [name appendString:[NSString stringWithFormat:@"%lu", audioCount]];
        ++audioCount;
        recorder.name = [NSString stringWithString:name];
        
        [self.recorderArr addObject:recorder];
    }
    self.defaultAudioRecorderId = [NSNumber numberWithUnsignedInteger:self.recorderArr.count - 1];
}


#pragma mark - MediaStreamRecordingProfile Common Internal
- (DPHostRecorderContext*)recorderForTarget:(NSString *)target recorderType:(RecorderType)recorderType error:(NSError**)error {
    unsigned long long idx;
    if (target || (target && target.length > 0)) {
        BOOL success = [[NSScanner scannerWithString:target] scanUnsignedLongLong:&idx];
        if (!success) {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"target is invalid."];
            return nil;
        }
    } else if (self.defaultPhotoRecorderId && recorderType == RecorderTypePhoto) {        // target省略時はデフォルトのレコーダーを指定する。
        idx = [self.defaultPhotoRecorderId unsignedLongLongValue];
    } else if (self.currentRecorderId && recorderType == RecorderTypeMovie) {
        idx = [self.currentRecorderId unsignedLongLongValue];
    } else if (self.defaultVideoRecorderId && recorderType == RecorderTypeMovie) {
        idx = [self.defaultVideoRecorderId unsignedLongLongValue];
    } else if (self.defaultAudioRecorderId && recorderType == RecorderTypeMovie) {
        idx = [self.defaultAudioRecorderId unsignedLongLongValue];
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:
                  @"target was not specified, and no default target was set; please specify an existing target."];
        return nil;
    }
    unsigned long long count = (unsigned)self.recorderArr.count;
    
    if (!_recorderArr || count < idx) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:
                  @"target was not specified, and no default target was set; please specify an existing target."];
        return nil;
    }
    
    if (recorderType == RecorderTypeMovie) {
        self.currentRecorderId = [NSNumber numberWithUnsignedLongLong:idx];
    }
    return self.recorderArr[(NSUInteger)idx];
}

- (void)setLightOff
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    [captureDevice lockForConfiguration:NULL];
    if (captureDevice.torchMode == AVCaptureTorchModeOn) {
        captureDevice.torchMode = AVCaptureTorchModeOff;
    }
    [captureDevice unlockForConfiguration];
}

- (NSString *)usedVideoContextForRecorder:(DPHostRecorderContext *)recorder
{
    for (DPHostRecorderContext *recorderItr in self.recorderArr) {
        if (recorderItr == recorder) {
            continue;
        }
        if ((recorderItr.state == RecorderStateRecording)
            && recorder.videoDevice && recorderItr.videoDevice &&
            [recorder.videoDevice.uniqueId isEqualToString:recorderItr.videoDevice.uniqueId]) {
            return recorderItr.name; //使用中
        }
    }
    return nil; //使用されていない
}


#pragma mark - TakePhoto Internal
- (void)takePhotoInternal:(DPHostRecorderContext *)recorder
{
    __block AVCaptureDevice *captureDevice = [AVCaptureDevice deviceWithUniqueID:recorder.videoDevice.uniqueId];
    NSError *error;
    [captureDevice lockForConfiguration:&error];
    
    if (error) {
        NSLog(@"Failed to acquire a configuration lock for %@.", captureDevice.uniqueID);
    } else {
        
        if (captureDevice.focusMode != AVCaptureFocusModeContinuousAutoFocus &&
            [captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            captureDevice.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        } else if (captureDevice.focusMode != AVCaptureFocusModeAutoFocus &&
                   [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
        } else if (captureDevice.focusMode != AVCaptureFocusModeLocked &&
                   [captureDevice isFocusModeSupported:AVCaptureFocusModeLocked]) {
            captureDevice.focusMode = AVCaptureFocusModeLocked;
        }
        if (captureDevice.exposureMode != AVCaptureExposureModeContinuousAutoExposure &&
            [captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
            captureDevice.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
        } else if (captureDevice.exposureMode != AVCaptureExposureModeAutoExpose &&
                   [captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            captureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
        } else if (captureDevice.exposureMode != AVCaptureExposureModeLocked &&
                   [captureDevice isExposureModeSupported:AVCaptureExposureModeLocked]) {
            captureDevice.exposureMode = AVCaptureExposureModeLocked;
        }
        if (captureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance &&
            [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        } else if (captureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeAutoWhiteBalance &&
                   [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeAutoWhiteBalance;
        } else if (captureDevice.whiteBalanceMode != AVCaptureWhiteBalanceModeLocked &&
                   [captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            captureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeLocked;
        }
        if (captureDevice.automaticallyEnablesLowLightBoostWhenAvailable != NO &&
            captureDevice.lowLightBoostSupported) {
            captureDevice.automaticallyEnablesLowLightBoostWhenAvailable = YES;
        }
        [captureDevice unlockForConfiguration];
        
        [NSThread sleepForTimeInterval:0.5];
    }
}


- (void)saveFileWithRecorder:(DPHostRecorderContext *)recorder completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler
{
    AVCaptureStillImageOutput *stillImageOutput = (AVCaptureStillImageOutput *)recorder.videoConnection.output;
    __weak DPHostRecorderManager *weakSelf = self;
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:recorder.videoConnection
                                                  completionHandler:
     ^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
         __block NSError *err = nil;
         if (!imageDataSampleBuffer || error) {
             err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to take a photo."];
             completionHandler(nil, err);
             return;
         }
         NSData *jpegData;
         @try {
             jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
         }
         @catch (NSException *exception) {
             NSString *message;
             if ([[exception name] isEqualToString:NSInvalidArgumentException]) {
                 message = @"Non-JPEG data was given.";
             } else {
                 message = [NSString stringWithFormat:@"%@ encountered.", [exception name]];
             }
             err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:message];
             completionHandler(nil, err);
             return;
         }
         
         // EXIF情報を水平に統一する。ブラウザによってはEXIF情報により画像の向きが変わるため。
         CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpegData, NULL);
         NSDictionary *metadata = (__bridge NSDictionary*) CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
         NSMutableDictionary *meta = [NSMutableDictionary dictionaryWithDictionary:metadata];
         NSMutableDictionary *tiff = meta[(NSString*) kCGImagePropertyTIFFDictionary];
         tiff[(NSString*) kCGImagePropertyTIFFOrientation] = @(kCGImagePropertyOrientationUp);
         meta[(NSString*) kCGImagePropertyTIFFDictionary] = tiff;
         meta[(NSString*) kCGImagePropertyOrientation] = @(kCGImagePropertyOrientationUp);
         UIImage *jpeg = [[UIImage alloc] initWithData:jpegData];
         UIImage *fixJpeg = [weakSelf fixOrientationWithImage:jpeg position:recorder.videoDevice.position];
         [[weakSelf library] writeImageToSavedPhotosAlbum:fixJpeg.CGImage metadata:meta completionBlock:
          ^(NSURL *assetURL, NSError *error) {
              if (!assetURL || error) {
                  err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to save a photo to camera roll."];
                  completionHandler(nil, err);
                  return;
              }
              completionHandler(assetURL, err);
          }];
     }];
}
- (UIImage *)fixOrientationWithImage:(UIImage *)image position:(AVCaptureDevicePosition) position{
    
    if (image.imageOrientation == UIImageOrientationUp && position != AVCaptureDevicePositionFront) return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (position) {
        case AVCaptureDevicePositionFront:
            switch (image.imageOrientation) {
                    
                case UIImageOrientationLeft:
                case UIImageOrientationLeftMirrored:
                case UIImageOrientationRight:
                case UIImageOrientationRightMirrored:
                    transform = CGAffineTransformTranslate(transform, 0, image.size.width);
                    transform = CGAffineTransformScale(transform, 1, -1);
                    break;
                case UIImageOrientationDown:
                case UIImageOrientationDownMirrored:
                case UIImageOrientationUp:
                case UIImageOrientationUpMirrored:
                default:
                    transform = CGAffineTransformTranslate(transform, image.size.width, 0);
                    transform = CGAffineTransformScale(transform, -1, 1);
                    break;
            }
            
            break;
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionBack:
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

#pragma mark - Record Internal
AVCaptureVideoOrientation videoOrientationFromDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
    AVCaptureVideoOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationUnknown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}
- (NSString *)usedAudioContextForRecorder:(DPHostRecorderContext *)recorder
{
    for (DPHostRecorderContext *recorderItr in self.recorderArr) {
        if (recorderItr == recorder) {
            continue;
        }
        if (recorderItr.state == RecorderStateRecording) {
            if (recorder.audioDevice && recorderItr.audioDevice &&
                [recorder.audioDevice.uniqueId isEqualToString:recorderItr.audioDevice.uniqueId]) {
                return recorderItr.name; // 使用中
            }
        }
    }
    return nil; //使用されていない
}

- (void)adjustExposureAndFocus:(AVCaptureDevice *)captureDevice {
    CGPoint pointOfInterest = CGPointMake(.5, .5);
    if ([captureDevice isFocusPointOfInterestSupported] &&
        [captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        captureDevice.focusPointOfInterest = pointOfInterest;
        captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
    }
    if ([captureDevice isExposurePointOfInterestSupported] &&
        [captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        captureDevice.exposurePointOfInterest = pointOfInterest;
        captureDevice.exposureMode =
        AVCaptureExposureModeContinuousAutoExposure;
    }
}

- (void)startRecordingForRecorder:(DPHostRecorderContext *)recorder error:(NSError **)error {
    if (recorder.type != RecorderTypeMovie) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
                  @"target is not an audiovisual device; it is not capable of taking a movie."];
        return;
    }
    
    // ライトが点いていたら消灯する。
    [self setLightOff];
    
    if (recorder.videoConnection.supportsVideoOrientation) {
        recorder.videoConnection.videoOrientation = videoOrientationFromDeviceOrientation([UIDevice currentDevice].orientation);
    }
    recorder.videoOrientation = [recorder.videoConnection videoOrientation];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice deviceWithUniqueID:recorder.videoDevice.uniqueId];
    NSError *err = nil;
    [captureDevice lockForConfiguration:&err];
    if (err) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:[NSString stringWithFormat:@"Failed to acquire a configuration lock for %@.", captureDevice.uniqueID]];
        return;
    } else {
        
        // 画面中央に露光やフォーカスが調整される様にする。
        [self adjustExposureAndFocus:captureDevice];
        [captureDevice unlockForConfiguration];
        
        // 露光の為に少し待つ
        [NSThread sleepForTimeInterval:0.5];
    }
    
    [recorder setupAssetWriter];
    recorder.state = RecorderStateRecording;
    
    // ポーズ関連の変数を初期化
    self.lastPreviewTimestamp = kCMTimeInvalid;
    self.totalPauseDuration = kCMTimeInvalid;
    self.needRecalculationOfTotalPauseDuration = NO;
    
    if (![recorder.session isRunning]) {
        [recorder.session startRunning];
    }
}
#pragma mark - Stop Internal
- (void)finishRecordingSampleForRecorder:(DPHostRecorderContext *)recorder {
    [recorder performWriting:
     ^{
         // レコーディングサンプルの配信を停止する。
         [recorder.session stopRunning];
         
         if (recorder.audioWriterInput) {
             if (recorder.writer.status != AVAssetWriterStatusUnknown) {
                 [recorder.audioWriterInput markAsFinished];
             }
         }
         if (recorder.videoWriterInput) {
             if (recorder.writer.status != AVAssetWriterStatusUnknown) {
                 [recorder.videoWriterInput markAsFinished];
             }
         }
         
         recorder.state = RecorderStateInactive;
         recorder.audioReady = recorder.videoReady = NO;
     }];
}

- (void)saveMovieFileForRecorder:(DPHostRecorderContext *)recorder completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler {
    __block NSError *err = nil;
    __weak DPHostRecorderManager *weakSelf = self;
    [recorder.writer finishWritingWithCompletionHandler:
     ^{
         
         if (recorder.writer.status == AVAssetWriterStatusFailed) {
             err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to finishing an aseet writer"];
             completionHandler(nil, err);
             return;
         }
         NSURL *fileUrl = recorder.writer.outputURL;
         
         // 動画をカメラロールに追加。
         [weakSelf.library writeVideoAtPathToSavedPhotosAlbum:fileUrl
                                              completionBlock:
          ^(NSURL *assetURL, NSError *error) {
              if (error) {
                  err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:[NSString stringWithFormat:@"Failed to save a movie to camera roll:%@.", error.localizedDescription]];
                  completionHandler(nil, err);
                  return;
              } else if (!assetURL) {
                  err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to save a movie to camera roll; aseetURL is nil."];
                  completionHandler(nil, err);
                  return;
              }
              NSFileManager *fileMgr = [NSFileManager defaultManager];
              if ([fileMgr fileExistsAtPath:[fileUrl path]]
                  && ![fileMgr removeItemAtURL:fileUrl error:&err]) {
                  if (!err) {
                      err = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Failed to remove a movie file."];
                  }
                  completionHandler(nil, err);
                  return;
              }
              completionHandler(assetURL, nil);
          }];
     }];
}
#pragma mark - Preview Internal

- (BOOL) setupAssetWriterAudioInputForRecorderContext:(DPHostRecorderContext *)recorderCtx
                                          description:(CMFormatDescriptionRef)currentFormatDescription
{
    if (!recorderCtx.writer) {
        NSLog(@"assetWriter must be specified.");
        return NO;
    }
    
    const AudioStreamBasicDescription *currentASBD
    = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
    size_t aclSize = 0;
    const AudioChannelLayout *currentChannelLayout
    = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    NSData *currentChannelLayoutData = nil;
    
    if ( currentChannelLayout && aclSize > 0 ) {
        currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
    } else {
        currentChannelLayoutData = [NSData data];
    }
    NSDictionary *audioCompressionSettings =
    @{
      AVFormatIDKey : @(kAudioFormatMPEG4AAC),
      AVSampleRateKey : @(currentASBD->mSampleRate),
      AVEncoderBitRatePerChannelKey : @64000,
      AVNumberOfChannelsKey : @(currentASBD->mChannelsPerFrame),
      AVChannelLayoutKey : currentChannelLayoutData
      };
    if ([recorderCtx.writer canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
        AVAssetWriterInput *assetWriterAudioIn = recorderCtx.audioWriterInput
        = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
        assetWriterAudioIn.expectsMediaDataInRealTime = YES;
        
        if ([recorderCtx.writer canAddInput:assetWriterAudioIn]) {
            [recorderCtx.writer addInput:assetWriterAudioIn];
            recorderCtx.audioReady = YES;
        }
        else {
            NSLog(@"Could not add asset writer audio input.");
            return NO;
        }
    }
    else {
        NSLog(@"Could not apply audio output settings.");
        return NO;
    }
    
    return YES;
}
- (BOOL) setupAssetWriterVideoInputForRecorderContext:(DPHostRecorderContext *)recorderCtx
                                          description:(CMFormatDescriptionRef)currentFormatDescription
{
    if (!recorderCtx.writer) {
        NSLog(@"assetWriter must be specified.");
        return NO;
    }
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    
    // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
    if ( numPixels < (640 * 480) )
        bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
    else
        bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
    
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *videoCompressionSettings =
    @{
      AVVideoCodecKey : AVVideoCodecH264,
      AVVideoWidthKey : @(dimensions.width),
      AVVideoHeightKey : @(dimensions.height),
      AVVideoCompressionPropertiesKey : @{
              AVVideoAverageBitRateKey : @(bitsPerSecond),
              AVVideoMaxKeyFrameIntervalKey : @30,
              },
      };
    if ([recorderCtx.writer canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        AVAssetWriterInput *assetWriterVideoIn = recorderCtx.videoWriterInput
        = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        assetWriterVideoIn.expectsMediaDataInRealTime = YES;
        
        assetWriterVideoIn.transform =
        [self transformVideoOrientation:recorderCtx.videoOrientation position:recorderCtx.videoDevice.position];
        if ([recorderCtx.writer canAddInput:assetWriterVideoIn]) {
            [recorderCtx.writer addInput:assetWriterVideoIn];
            recorderCtx.videoReady = YES;
        }
        else {
            NSLog(@"Couldn't add asset writer video input.");
            return NO;
        }
    }
    else {
        NSLog(@"Couldn't apply video output settings.");
        return NO;
    }
    
    return YES;
}

- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(UIDeviceOrientation)orientation
                                                  position:(AVCaptureDevicePosition)position
{
    CGFloat angle = 0.0;
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            angle = 0.0;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = position == AVCaptureDevicePositionBack ? -M_PI_2 : M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = position == AVCaptureDevicePositionBack ? M_PI_2 : -M_PI_2;
            break;
        default:
            break;
    }
    
    return angle;
}

- (CGAffineTransform)transformVideoOrientation:(AVCaptureVideoOrientation)orientation
                                      position:(AVCaptureDevicePosition)position
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // iOSデバイスの向きが、ポートレート状態から角度的に何度の差があるか算出。
    CGFloat orientationAngleOffset =
    [self angleOffsetFromPortraitOrientationToOrientation:_referenceOrientation
                                                 position:position];
    CGFloat videoOrientationAngleOffset =
    [self angleOffsetFromPortraitOrientationToOrientation:(UIDeviceOrientation)orientation
                                                 position:position];
    
    // Find the difference in angle between the passed in orientation and the current video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    
    return transform;
}

- (void) sendPreviewDataWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
                             orientation:(AVCaptureDevicePosition)orientation
{
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!imageBuffer) {
            return;
        }
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        if (!ciImage) {
            return;
        }
        
        UIImage *image = [UIImage imageWithCIImage:ciImage];
        CGSize size = image.size;
        double scale = 320000.0 / (size.width * size.height);
        size = CGSizeMake((int)(size.width * scale), (int)(size.height * scale));
        UIGraphicsBeginImageContext(size);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);

        [self.httpServer offerData:jpegData];
    }

}


#pragma mark - AVCapture{Audio,Video}DataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CMSampleBufferRef buffer = sampleBuffer;
    // オーディオ・ビデオのどちらからデータが来たかのフラグ
    BOOL isAudio;
    if ([captureOutput isKindOfClass:[AVCaptureAudioDataOutput class]]) {
        isAudio = YES;
    } else if ([captureOutput isKindOfClass:[AVCaptureVideoDataOutput class]]) {
        isAudio = NO;
    } else {
        NSLog(@"Capture output \"%s\" is not supported.", object_getClassName([captureOutput class]));
        return;
    }
    
    CMTime originalSampleBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer);
    if (!CMTIME_IS_NUMERIC(originalSampleBufferTimestamp)) {
        NSLog(@"Invalid %@ timestamp; could not append the sample.", isAudio ? @"audio" : @"video");
        return;
    }
    
    BOOL updateLastSampleTimestamp = YES;
    BOOL adjustTimestamp = YES;
    BOOL initMuteSample = YES;
    BOOL requireRelease = NO;
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(buffer);
    for (DPHostRecorderContext *recorder in _recorderArr) {
        if (recorder.state != RecorderStateRecording) {
            continue;
        }
        
        if (isAudio) {
            // オーディオ
            if (recorder.audioConnection != connection) {
                continue;
            }
            if (!recorder.audioReady &&
                ![self setupAssetWriterAudioInputForRecorderContext:recorder
                                                        description:formatDescription])
            {
                // キャプチャーセッションを停止する。
                [recorder.session stopRunning];
                recorder.state = RecorderStateInactive;
                recorder.audioReady = recorder.videoReady = NO;
                recorder.writer = nil;
                recorder.audioWriterInput = recorder.videoWriterInput = nil;
                
                continue;
            }
        } else {
            // ビデオ
            if (recorder.videoConnection != connection) {
                continue;
            }
            if (!recorder.videoReady &&
                ![self setupAssetWriterVideoInputForRecorderContext:recorder
                                                        description:formatDescription])
            {
                
                // キャプチャーセッションを停止する。
                [recorder.session stopRunning];

                
                // TODO: レコーダーの初期化コードを関数化
                recorder.state = RecorderStateInactive;
                recorder.audioReady = recorder.videoReady = NO;
                recorder.writer = nil;
                recorder.audioWriterInput = recorder.videoWriterInput = nil;
                
                continue;
            }
        }
        
        if ((!recorder.audioDevice || recorder.audioReady) &&
            (!recorder.videoDevice || recorder.videoReady)) {
            if (_needRecalculationOfTotalPauseDuration) {
                if (!isAudio) {
                    return;
                }
                
                if (CMTIME_IS_NUMERIC(_lastSampleTimestamp)) {
                    CMTime sampleBufferTimestamp = originalSampleBufferTimestamp;
                    if (CMTIME_IS_NUMERIC(_totalPauseDuration)) {
                        sampleBufferTimestamp = CMTimeSubtract(sampleBufferTimestamp, _totalPauseDuration);
                    }
                    CMTime pauseDuration = CMTimeSubtract(sampleBufferTimestamp, _lastSampleTimestamp);
                    
                    if (CMTIME_IS_NUMERIC(_totalPauseDuration) && _totalPauseDuration.value != 0) {
                        _totalPauseDuration = CMTimeAdd(_totalPauseDuration, pauseDuration);
                    } else {
                        _totalPauseDuration = pauseDuration;
                    }
                }
                _lastSampleTimestamp.flags = 0;
                _needRecalculationOfTotalPauseDuration = NO;
            }
            
            if (adjustTimestamp) {
                CFRetain(buffer);
                
                // ポーズの累計期間に応じたサンプルのタイミング修正を行う。
                if (CMTIME_IS_NUMERIC(_totalPauseDuration) && _totalPauseDuration.value != 0) {
                    // タイムスタンプのタイムスタンプをポーズの累計期間に応じて調整する
                    CMSampleBufferRef tmp = [self sampleBufferByAdjustingTimestamp:sampleBuffer by:_totalPauseDuration];
                    CFRelease(sampleBuffer);
                    buffer = tmp;
                }
                adjustTimestamp = NO;
                requireRelease = YES;
            }
            
            if (isAudio && recorder.isMuted && initMuteSample) {
                CMBlockBufferRef buf = CMSampleBufferGetDataBuffer(buffer);
                size_t length;
                size_t totalLength;
                char* data;
                if (CMBlockBufferGetDataPointer(buf, 0, &length, &totalLength, &data) != noErr) {
                    NSLog(@"Failed to set audio amplitude to 0 for muting.");
                } else {
                    for (size_t i = 0; i < length; ++i) {
                        data[i] = 0;
                    }
                }
                initMuteSample = NO;
            }
            
            if (!isAudio && _sendPreview) {
                for (NSString *previewId in self.nowCurrentRecorders) {
                    if (recorder == self.recorderArr[[previewId intValue]]) {
                        if (CMTIME_IS_INVALID(_lastPreviewTimestamp)) {
                            // まだプレビューの配送を行っていないのであれば、プレビューを配信する。
                            [self sendPreviewDataWithSampleBuffer:sampleBuffer orientation:recorder.videoDevice.position];
                        } else if (CMTIME_IS_NUMERIC(_lastPreviewTimestamp)) {
                            CMTime elapsedTime =
                            CMTimeSubtract(_lastPreviewTimestamp, originalSampleBufferTimestamp);
                            if (CMTIME_COMPARE_INLINE(elapsedTime, >=, _secPerFrame)) {
                                // 規定時間が経過したのであれば、プレビューを配信する。
                                [self sendPreviewDataWithSampleBuffer:sampleBuffer orientation:recorder.videoDevice.position];
                            }
                        } else {
                            self.lastPreviewTimestamp = originalSampleBufferTimestamp;
                        }
                    }
                }
            }
            
            if (isAudio && updateLastSampleTimestamp) {
                // サンプルのタイムスタンプを保持しておく
                CMTime sampleBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer);
                CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
                if (duration.value > 0) {
                    _lastSampleTimestamp = CMTimeAdd(sampleBufferTimestamp, duration);
                } else {
                    // 「サンプルの開始時間（タイムスタンプ）」と「サンプルの終了時間」が同義。
                    _lastSampleTimestamp = sampleBufferTimestamp;
                }
                updateLastSampleTimestamp = NO;
            }
            
            [self appendSampleBuffer:sampleBuffer recorderContext:recorder isAudio:isAudio];
        }
    }
    if (requireRelease) {
        CFRelease(buffer);
    }
}

- (BOOL) appendSampleBuffer:(CMSampleBufferRef)sampleBuffer
            recorderContext:(DPHostRecorderContext *)recorderCtx
                    isAudio:(BOOL)isAudio
{
    @synchronized(recorderCtx) {
        if (!recorderCtx.writer) {
            return NO;
        }
        
        if (CMSampleBufferDataIsReady(sampleBuffer)) {
            if (recorderCtx.writer.status == AVAssetWriterStatusUnknown) {
                if ([recorderCtx.writer startWriting]) {
                    [recorderCtx.writer startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
                }
                else {
                    // ライターの書き出し失敗
                    
                    // キャプチャーセッションを停止する。
                    [recorderCtx.session stopRunning];

                    
                    // TODO: レコーダーの初期化コードを関数化
                    recorderCtx.state = RecorderStateInactive;
                    recorderCtx.audioReady = recorderCtx.videoReady = NO;
                    recorderCtx.writer = nil;
                    recorderCtx.audioWriterInput = recorderCtx.videoWriterInput = nil;
                    
                    return NO;
                }
            }
            
            if (recorderCtx.writer.status == AVAssetWriterStatusFailed) {
                recorderCtx.state = RecorderStateInactive;
                recorderCtx.audioReady = recorderCtx.videoReady = NO;
                recorderCtx.writer = nil;
                recorderCtx.audioWriterInput = recorderCtx.videoWriterInput = nil;
                
                // TODO: エラーイベントを配送する
                
                return NO;
            }
            
            if (recorderCtx.writer.status == AVAssetWriterStatusWriting) {
                AVAssetWriterInput *writerInput =
                isAudio ? recorderCtx.audioWriterInput : recorderCtx.videoWriterInput;
                if (writerInput || sampleBuffer) {
                    if (!writerInput.readyForMoreMediaData) {
                        return NO;
                    }
                    if ([writerInput appendSampleBuffer:sampleBuffer]) {
                        return YES;
                    } else if (recorderCtx.writer.status == AVAssetWriterStatusFailed) {
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

- (CMSampleBufferRef) sampleBufferByAdjustingTimestamp:(CMSampleBufferRef)sample by:(CMTime)offset
{
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; ++i)
    {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    // 縦か横の時だけ更新する。
    if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) ) {
        _referenceOrientation = orientation;
    }
}
@end
