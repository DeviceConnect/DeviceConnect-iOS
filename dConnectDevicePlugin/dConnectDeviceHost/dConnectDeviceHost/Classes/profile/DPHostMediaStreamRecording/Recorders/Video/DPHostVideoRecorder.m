//
//  DPHostVideoRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostVideoRecorder.h"
#import "DPHostRecorderUtils.h"

@interface DPHostVideoRecorder()
@end
@implementation DPHostVideoRecorder

- (instancetype)initWithRecorderId:(NSNumber*)recorderId
                       videoDevice:(AVCaptureDevice*)videoDevice
                       audioDevice:(AVCaptureDevice*)audioDevice
{
    self = [super initWithRecorderId:recorderId videoDevice:videoDevice audioDevice:audioDevice];
    if (self) {
        self.recorderId = [NSString stringWithFormat:@"video_%d", [recorderId intValue]];
    }
    return self;
}

- (void)initialize
{
    [super initialize];
    self.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
    self.state = DPHostRecorderStateInactive;
    [self setVideoSourceTypeWithDelegate:self];
    [self setAudioSourceTypeWithDelegate:self];
    NSMutableString *name = @"iOSHost Video Recorder-".mutableCopy;
    
    switch (self.videoCaptureDevice.position) {
        case AVCaptureDevicePositionBack:
            [name appendString:@"back"];
            break;
        case AVCaptureDevicePositionFront:
            [name appendString:@"front"];
            break;
        case AVCaptureDevicePositionUnspecified:
        default:
             [name appendString:@"unknown"];
            break;
    }
    self.name = [NSString stringWithString:name];
    NSArray *cameraSizes = [DPHostRecorderUtils getRecorderSizesForSession:self.session];
    self.supportedPictureSizes = cameraSizes.mutableCopy;
    self.supportedPreviewSizes = cameraSizes.mutableCopy;
    self.pictureSize = [DPHostRecorderUtils getDimensionForPreset:AVCaptureSessionPreset640x480];
    self.previewSize = [DPHostRecorderUtils getDimensionForPreset:AVCaptureSessionPreset640x480];
    self.supportedMimeTypes = @[self.mimeType];
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
    if (self.state != DPHostRecorderStateRecording) {
        return;
    }
    
    if (isAudio) {
        // オーディオ
        [self initAudioConnection:connection formatDescription:formatDescription];
    } else {
        // ビデオ
        [self initVideoConnection:connection formatDescription:formatDescription];
    }
    
    if ((!self.audioCaptureDevice || self.audioReady) && (!self.videoCaptureDevice || self.videoReady)) {
        [self needRecalculationOfTotalPauseDurationForIsAudio:isAudio originalSampleBufferTimestamp:&originalSampleBufferTimestamp];
        [self adjustTimeStamp:&adjustTimestamp buffer:&buffer requireRelease:&requireRelease sampleBuffer:sampleBuffer];
        [self muteWithBuffer:buffer initMuteSample:&initMuteSample isAudio:isAudio];
        
        [self updateLastSampleTimestampWithBuffer:buffer isAudio:isAudio sampleBuffer:sampleBuffer updateLastSampleTimestamp:&updateLastSampleTimestamp];
        
        [self appendSampleBuffer:sampleBuffer isAudio:isAudio];
    }


    if (requireRelease) {
        CFRelease(buffer);
    }
}

@end
