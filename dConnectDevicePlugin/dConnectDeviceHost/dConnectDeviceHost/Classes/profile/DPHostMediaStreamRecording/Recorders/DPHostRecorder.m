//
//  DPHostRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostRecorder.h"
#import "DPHostRecorderUtils.h"
@interface DPHostRecorder()
@property dispatch_queue_t captureStartQueue;
@property dispatch_queue_t captureEndQueue;
@property (nonatomic) UIDeviceOrientation referenceOrientation;
/// 録画開始時のビデオの向き
@property (nonatomic) AVCaptureVideoOrientation videoOrientation;
/// ポーズ前最後のサンプルのタイムスタンプ
@property CMTime lastSampleTimestamp;
/// ポーズの累計期間
@property CMTime totalPauseDuration;


@end

@implementation DPHostRecorder
- (instancetype)initWithRecorderId:(NSNumber*)recorderId
                       videoDevice:(AVCaptureDevice*)videoDevice
                       audioDevice:(AVCaptureDevice*)audioDevice
{
    self = [super init];
    if (self) {
        self.recorderId = [recorderId stringValue];
        self.isMuted = NO;
        self.videoCaptureDevice = videoDevice;
        self.audioCaptureDevice = audioDevice;
        self.supportedPictureSizes = [NSArray array];
        self.supportedPreviewSizes = [NSArray array];
        self.supportedMimeTypes = [NSArray array];
        self.session = [AVCaptureSession new];
        self.captureStartQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
        self.captureEndQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL);
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange)
                                   name:UIDeviceOrientationDidChangeNotification object:nil];
        self.totalPauseDuration = kCMTimeInvalid;

    }
    return self;
}

- (void)initialize
{
    // override subclass
}

- (void)clean
{
    // override subclass
}

#pragma mark - Protected Method

- (void) performReading:(void(^)(void))callback
{
    dispatch_sync(self.captureStartQueue, callback);
}

- (void) performWriting:(void(^)(void))callback
{
    dispatch_barrier_sync(self.captureEndQueue, callback);
}

- (void)startRecordingWithError:(NSError **)error {
    // ライトが点いていたら消灯する。
    [DPHostRecorderUtils setLightOnOff:NO];
    
    if (self.videoConnection.supportsVideoOrientation) {
        self.videoConnection.videoOrientation = [DPHostRecorderUtils videoOrientationFromDeviceOrientation:[UIDevice currentDevice].orientation];
    }
    self.videoOrientation = self.videoConnection.videoOrientation;
    
    [self.videoCaptureDevice lockForConfiguration:error];
    if (*error) {
        [self.videoCaptureDevice unlockForConfiguration];
        return;
    } else {
        // 画面中央に露光やフォーカスが調整される様にする。
        [self adjustExposureAndFocus:self.videoCaptureDevice];
        [self.videoCaptureDevice unlockForConfiguration];
        
        // 露光の為に少し待つ
        [NSThread sleepForTimeInterval:0.5];
    }
    
    [self setupAssetWriter];
    self.state = DPHostRecorderStateRecording;
    
    // ポーズ関連の変数を初期化
    self.totalPauseDuration = kCMTimeInvalid;
    self.needRecalculationOfTotalPauseDuration = NO;
    
    if (![self.session isRunning]) {
        [self.session startRunning];
    }
}

- (void)finishRecordingSample {
    __block DPHostRecorder *weakSelf = self;
    [self performWriting:
     ^{
         // レコーディングサンプルの配信を停止する。
         [weakSelf.session stopRunning];
         
         if (self.audioWriterInput) {
             if (self.writer.status != AVAssetWriterStatusUnknown) {
                 [self.audioWriterInput markAsFinished];
             }
         }
         if (self.videoWriterInput) {
             if (self.writer.status != AVAssetWriterStatusUnknown) {
                 [self.videoWriterInput markAsFinished];
             }
         }
         
         weakSelf.state = DPHostRecorderStateInactive;
         weakSelf.audioReady = weakSelf.videoReady = NO;
     }];
}
#pragma mark - Util
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

// AVAssetWriterの初期化および書き出し成功を確認した際に用いるHTTPレスポンス。
- (BOOL) setupAssetWriter
{
    NSString *fileName = [NSString stringWithFormat:@"%@_%@",
                          [[NSProcessInfo processInfo] globallyUniqueString],
                          @"movie.mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
    self.writer = [AVAssetWriter assetWriterWithURL:fileURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
    [[NSFileManager defaultManager] removeItemAtURL:self.writer.outputURL error:nil];
    
    return self.writer != nil;
}



- (void)setPhotoDataSourceType
{
    if (!self.videoCaptureDevice) {
        return;
    }
    if (![DPHostRecorderUtils containsDevice:self.videoCaptureDevice session:self.session]) {
        NSError *error;
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.videoCaptureDevice error:&error];
        if (error) {
            NSLog(@"Error encountered while trying to instantiate a video input.");
            return;
        }
        if ( [self.session canAddInput:deviceInput] ) {
            [self.session addInput:deviceInput];
        } else {
            NSLog(@"Failed to add a video input to the session.");
            return;
        }
    }
    
    AVCaptureStillImageOutput *stillImageOutput = [AVCaptureStillImageOutput new];
    [stillImageOutput setOutputSettings:
     @{
       // AVVideoCodecKey : AVVideoCodecJPEGと共存してくれない…
       //       (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInt:kCVPixelFormatType_32BGRA],
       AVVideoCodecKey : AVVideoCodecJPEG
       }];
    if ( [self.session canAddOutput:stillImageOutput] ) {
        [self.session addOutput:stillImageOutput];
    } else {
        NSLog(@"Failed to add a still image output to the session.");
        return;
    }
    
    self.photoConnection = [DPHostRecorderUtils connectionForDevice:self.videoCaptureDevice output:stillImageOutput];
    if (!self.photoConnection) {
        NSLog(@"Failed to obtain a video connection.");
    }
}

- (void)setVideoSourceTypeWithDelegate:(id)delegate
{
    if (!self.videoCaptureDevice) {
        return;
    }
    if (![DPHostRecorderUtils containsDevice:self.videoCaptureDevice session:self.session]) {
        NSError *error;
        AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:self.videoCaptureDevice error:&error];
        if (error) {
            NSLog(@"Error encountered while trying to instantiate a video input.");
            return;
        }
        if ([self.session canAddInput:videoIn]) {
            [self.session addInput:videoIn];
        } else {
            NSLog(@"Failed to add a video input to the session.");
            return;
        }
    }
    
    AVCaptureVideoDataOutput *videoOut = [AVCaptureVideoDataOutput new];
    [videoOut setAlwaysDiscardsLateVideoFrames:NO];
    [videoOut setVideoSettings:
     @{
       (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)
       }];
    [videoOut setSampleBufferDelegate:delegate queue:self.captureStartQueue];
    if ([self.session canAddOutput:videoOut]) {
        [self.session addOutput:videoOut];
    } else {
        NSLog(@"Failed to add a video output to the session.");
        return;
    }
    
    self.videoConnection = [DPHostRecorderUtils connectionForDevice:self.videoCaptureDevice output:videoOut];
    if (!self.videoConnection) {
        NSLog(@"Failed to obtain a video connection.");
    }
}

- (void)setAudioSourceTypeWithDelegate:(id)delegate
{
    if (!self.audioCaptureDevice) {
        return;
    }
    if (![DPHostRecorderUtils containsDevice:self.audioCaptureDevice session:self.session]) {
        NSError *error;
        AVCaptureDeviceInput *audioIn =
        [AVCaptureDeviceInput deviceInputWithDevice:self.audioCaptureDevice error:&error];
        if (error) {
            NSLog(@"Error encountered while trying to instantiate an audio input.");
            return;
        }
        if ( [self.session canAddInput:audioIn] ) {
            [self.session addInput:audioIn];
        } else {
            NSLog(@"Failed to add an audio input to the session.");
            return;
        }
    }
    
    AVCaptureAudioDataOutput *audioOut = [AVCaptureAudioDataOutput new];
    [audioOut setSampleBufferDelegate:delegate queue:self.captureStartQueue];
    if ([self.session canAddOutput:audioOut]) {
        [self.session addOutput:audioOut];
    } else {
        NSLog(@"Failed to add an audio output to the session.");
        return;
    }
    
    self.audioConnection = [DPHostRecorderUtils connectionForDevice:self.audioCaptureDevice output:audioOut];
    if (!self.audioConnection) {
        NSLog(@"Failed to obtain an audio connection.");
    }
}


#pragma mark - CaptureOutput Internal
- (void)initAudioConnection:(AVCaptureConnection * )connection formatDescription:(CMFormatDescriptionRef)formatDescription {
    if (self.audioConnection != connection) {
        return;
    }
    if (!self.audioReady &&
        ![self setupAssetWriterAudioInputForDescription:formatDescription]) {
        // キャプチャーセッションを停止する。
        [self.session stopRunning];
        self.state = DPHostRecorderStateInactive;
        self.audioReady = self.videoReady = NO;
        self.writer = nil;
        self.audioWriterInput = self.videoWriterInput = nil;
    }
}

- (void)initVideoConnection:(AVCaptureConnection *)connection formatDescription:(CMFormatDescriptionRef)formatDescription {
    if (self.videoConnection != connection) {
        return;
    }
    if (!self.videoReady &&
        ![self setupAssetWriterVideoInputForDescription:formatDescription]) {
        
        // キャプチャーセッションを停止する。
        [self.session stopRunning];
        self.state = DPHostRecorderStateInactive;
        self.audioReady = self.videoReady = NO;
        self.writer = nil;
        self.audioWriterInput = self.videoWriterInput = nil;
    }
}

- (void)needRecalculationOfTotalPauseDurationForIsAudio:(BOOL)isAudio originalSampleBufferTimestamp:(const CMTime *)originalSampleBufferTimestamp {
    if (self.needRecalculationOfTotalPauseDuration) {
        if (!isAudio) {
            return;
        }
        
        if (CMTIME_IS_NUMERIC(self.lastSampleTimestamp)) {
            CMTime sampleBufferTimestamp = *originalSampleBufferTimestamp;
            if (CMTIME_IS_NUMERIC(self.totalPauseDuration)) {
                sampleBufferTimestamp = CMTimeSubtract(sampleBufferTimestamp, self.totalPauseDuration);
            }
            CMTime pauseDuration = CMTimeSubtract(sampleBufferTimestamp, self.lastSampleTimestamp);
            
            if (CMTIME_IS_NUMERIC(_totalPauseDuration) && _totalPauseDuration.value != 0) {
                self.totalPauseDuration = CMTimeAdd(self.totalPauseDuration, pauseDuration);
            } else {
                self.totalPauseDuration = pauseDuration;
            }
        }
        CMTime tempTimeStamp = self.lastSampleTimestamp;
        tempTimeStamp.flags = 0;
        self.lastSampleTimestamp = tempTimeStamp;
        self.needRecalculationOfTotalPauseDuration = NO;
    }
}

- (void)adjustTimeStamp:(BOOL *)adjustTimestamp buffer:(CMSampleBufferRef *)buffer requireRelease:(BOOL *)requireRelease sampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if (*adjustTimestamp) {
        CFRetain(*buffer);
        
        // ポーズの累計期間に応じたサンプルのタイミング修正を行う。
        if (CMTIME_IS_NUMERIC(self.totalPauseDuration) && self.totalPauseDuration.value != 0) {
            // タイムスタンプのタイムスタンプをポーズの累計期間に応じて調整する
            CMSampleBufferRef tmp = [self sampleBufferByAdjustingTimestamp:sampleBuffer by:self.totalPauseDuration];
            CFRelease(sampleBuffer);
            *buffer = tmp;
        }
        *adjustTimestamp = NO;
        *requireRelease = YES;
    }
}

- (void)muteWithBuffer:(CMSampleBufferRef)buffer initMuteSample:(BOOL *)initMuteSample isAudio:(BOOL)isAudio
{
    if (isAudio && self.isMuted && *initMuteSample) {
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
        *initMuteSample = NO;
    }
}

- (void)updateLastSampleTimestampWithBuffer:(CMSampleBufferRef)buffer isAudio:(BOOL)isAudio sampleBuffer:(CMSampleBufferRef)sampleBuffer updateLastSampleTimestamp:(BOOL *)updateLastSampleTimestamp
{
    if (isAudio && *updateLastSampleTimestamp) {
        // サンプルのタイムスタンプを保持しておく
        CMTime sampleBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer);
        CMTime duration = CMSampleBufferGetDuration(sampleBuffer);
        if (duration.value > 0) {
            _lastSampleTimestamp = CMTimeAdd(sampleBufferTimestamp, duration);
        } else {
            // 「サンプルの開始時間（タイムスタンプ）」と「サンプルの終了時間」が同義。
            self.lastSampleTimestamp = sampleBufferTimestamp;
        }
        *updateLastSampleTimestamp = NO;
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

- (BOOL) setupAssetWriterAudioInputForDescription:(CMFormatDescriptionRef)currentFormatDescription
{
    if (!self.writer) {
        NSLog(@"assetWriter must be specified.");
        return NO;
    }
    
    const AudioStreamBasicDescription *currentASBD
    = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
    
    size_t aclSize = 0;
    const AudioChannelLayout *currentChannelLayout
    = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
    NSData *currentChannelLayoutData = nil;
    
    if (currentChannelLayout && aclSize > 0 ) {
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
    if ([self.writer canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
        AVAssetWriterInput *assetWriterAudioIn = self.audioWriterInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio
                                                                                                        outputSettings:audioCompressionSettings];
        assetWriterAudioIn.expectsMediaDataInRealTime = YES;
        
        if ([self.writer canAddInput:assetWriterAudioIn]) {
            [self.writer addInput:assetWriterAudioIn];
            self.audioReady = YES;
        } else {
            NSLog(@"Could not add asset writer audio input.");
            return NO;
        }
    } else {
        NSLog(@"Could not apply audio output settings.");
        return NO;
    }
    
    return YES;
}

- (BOOL) setupAssetWriterVideoInputForDescription:(CMFormatDescriptionRef)currentFormatDescription
{
    if (!self.writer) {
        NSLog(@"assetWriter must be specified.");
        return NO;
    }
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    
    // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
    if (numPixels < (640 * 480)) {
        bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
    } else {
        bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
    }
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
    if ([self.writer canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
        AVAssetWriterInput *assetWriterVideoIn = self.videoWriterInput
        = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
        assetWriterVideoIn.expectsMediaDataInRealTime = YES;
        
        assetWriterVideoIn.transform = [self transformVideoOrientation:self.videoOrientation position:self.videoCaptureDevice.position];
        if ([self.writer canAddInput:assetWriterVideoIn]) {
            [self.writer addInput:assetWriterVideoIn];
            self.videoReady = YES;
        } else {
            NSLog(@"Couldn't add asset writer video input.");
            return NO;
        }
    } else {
        NSLog(@"Couldn't apply video output settings.");
        return NO;
    }
    
    return YES;
}

- (CGAffineTransform)transformVideoOrientation:(AVCaptureVideoOrientation)orientation
                                      position:(AVCaptureDevicePosition)position
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // iOSデバイスの向きが、ポートレート状態から角度的に何度の差があるか算出。
    CGFloat orientationAngleOffset =
    [self angleOffsetFromPortraitOrientationToOrientation:self.referenceOrientation
                                                 position:position];
    CGFloat videoOrientationAngleOffset =
    [self angleOffsetFromPortraitOrientationToOrientation:(UIDeviceOrientation)orientation
                                                 position:position];
    
    // Find the difference in angle between the passed in orientation and the current video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation(angleOffset);
    
    return transform;
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



#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)deviceOrientationDidChange
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    // 縦か横の時だけ更新する。
    if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) ) {
        self.referenceOrientation = orientation;
    }
}
@end
