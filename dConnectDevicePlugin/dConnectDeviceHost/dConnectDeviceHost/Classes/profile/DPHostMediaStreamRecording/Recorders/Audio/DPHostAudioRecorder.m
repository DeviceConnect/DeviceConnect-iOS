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

- (instancetype)initWithRecorderId:(NSNumber*)recorderId
                       videoDevice:(AVCaptureDevice*)videoDevice
                       audioDevice:(AVCaptureDevice*)audioDevice
{
    self = [super initWithRecorderId:recorderId videoDevice:videoDevice audioDevice:audioDevice];
    if (self) {
        self.recorderId = [NSString stringWithFormat:@"audio_%d", [recorderId intValue]];
    }
    return self;
}
- (void)initialize
{
    [super initialize];
    self.mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
    self.state = DPHostRecorderStateInactive;
    [self setAudioSourceTypeWithDelegate:self];
    self.name = @"iOSHost Audio Recorder";
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
