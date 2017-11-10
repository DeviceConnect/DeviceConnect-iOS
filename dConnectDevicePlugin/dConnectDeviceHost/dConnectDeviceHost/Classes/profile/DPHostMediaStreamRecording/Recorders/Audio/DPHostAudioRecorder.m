//
//  DPHostAudioRecorder.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostAudioRecorder.h"

@interface DPHostAudioRecorder()
@end
@implementation DPHostAudioRecorder


- (void)initialize
{
    [super initialize];
    self.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
    self.state = DPHostRecorderStateInactive;
    [self setAudioSourceTypeWithDelegate:self];
    self.name = @"movie_audio_0";
}

#pragma mark - AVCapture{Audio,Video}DataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CMSampleBufferRef buffer = sampleBuffer;
    CMTime originalSampleBufferTimestamp = CMSampleBufferGetPresentationTimeStamp(buffer);
    if (!CMTIME_IS_NUMERIC(originalSampleBufferTimestamp)) {
        return;
    }
    
    BOOL updateLastSampleTimestamp = YES;
    BOOL initMuteSample = YES;
    BOOL requireRelease = NO;
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(buffer);
    if (self.state != DPHostRecorderStateRecording) {
        return;
    }
    
    [self initAudioConnection:connection formatDescription:formatDescription];

    if (self.audioReady) {
        [self needRecalculationOfTotalPauseDurationForIsAudio:YES originalSampleBufferTimestamp:&originalSampleBufferTimestamp];
        [self muteWithBuffer:buffer initMuteSample:&initMuteSample isAudio:YES];
        [self updateLastSampleTimestampWithBuffer:buffer isAudio:YES sampleBuffer:sampleBuffer updateLastSampleTimestamp:&updateLastSampleTimestamp];
        
        [self appendSampleBuffer:sampleBuffer isAudio:YES];
    }
    if (requireRelease) {
        CFRelease(buffer);
    }
}

@end
