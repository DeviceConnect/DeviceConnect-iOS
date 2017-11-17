//
//  DPHostRecorderManager.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <ImageIO/ImageIO.h>
#import "DPHostRecorderManager.h"
#import "DPHostAudioRecorder.h"
#import "DPHostCameraRecorder.h"
#import "DPHostVideoRecorder.h"

@interface DPHostRecorderManager()
@property NSArray *recorders;
/*!
 デフォルトの静止画レコーダーのID
 iOSデバイスによっては背面カメラが無かったりと差異があるので、
 ランタイム時にデフォルトのレコーダーを決定する処理を行う。
 */
@property DPHostRecorder *defaultPhotoRecorder;
/*!
 デフォルトの動画レコーダーのID
 iOSデバイスによっては背面カメラが無かったりと差異があるので、
 ランタイム時にデフォルトのレコーダーを決定する処理を行う。
 */
@property DPHostRecorder *defaultVideoRecorder;
@end

@implementation DPHostRecorderManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recorders = [NSArray array];
    }
    return self;
}

- (void)createRecorders
{
    NSArray *audioDevArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    NSArray *videoDevArr = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSMutableArray *recs = [NSMutableArray array];
    NSMutableArray *videoArray = [NSMutableArray array];
    NSMutableArray *photoArray = [NSMutableArray array];
    int recorderIdCount = 0;
    for (AVCaptureDevice *videoDev in videoDevArr) {
        DPHostCameraRecorder *cRecorder = [[DPHostCameraRecorder alloc] initWithRecorderId:@(recorderIdCount)
                                                                               videoDevice:videoDev
                                                                               audioDevice:nil];
        
        [photoArray addObject:cRecorder];
        for (AVCaptureDevice *audioDev in audioDevArr) {
            DPHostVideoRecorder *vRecorder = [[DPHostVideoRecorder alloc] initWithRecorderId:@(recorderIdCount)
                                                                                 videoDevice:videoDev
                                                                                 audioDevice:audioDev];
            [videoArray addObject:vRecorder];
            recorderIdCount++;
        }
    }
    if ([photoArray count] > 0) {
        self.defaultPhotoRecorder = photoArray[0];
    }
    if ([videoArray count] > 0) {
        self.defaultVideoRecorder = videoArray[0];
    }
    [recs addObjectsFromArray:photoArray];
    [recs addObjectsFromArray:videoArray];
    for (AVCaptureDevice *audioDev in audioDevArr) {
        [recs addObject:[[DPHostAudioRecorder alloc] initWithRecorderId:@(0)
                                                            videoDevice:nil
                                                            audioDevice:audioDev]];
    }
    self.recorders = recs.mutableCopy;
}
- (void)initialize
{
    for (DPHostRecorder *recorder in self.recorders) {
        [recorder initialize];
    }
}

- (void)clean
{
    for (DPHostRecorder *recorder in self.recorders) {
        [recorder clean];
    }
}
- (NSArray*)getRecorders
{
    return self.recorders;
}
- (DPHostRecorder*)getRecorderForRecorderId:(NSString*)recorderId
{
    if (!recorderId) {
        return self.defaultPhotoRecorder;
    }
    for (DPHostRecorder *recorder in self.recorders) {
        if ([recorderId isEqualToString:recorder.recorderId]) {
            return recorder;
        }
    }
    return nil;
}

- (DPHostPhotoRecorder*)getCameraRecorderForRecorderId:(NSString*)recorderId
{
    if (!recorderId) {
        return (DPHostCameraRecorder *) self.defaultPhotoRecorder;
    }
    for (DPHostRecorder *recorder in self.recorders) {
        if ([recorderId isEqualToString:recorder.recorderId] && [recorder isKindOfClass:[DPHostPhotoRecorder class]]) {
            return (DPHostPhotoRecorder *) recorder;
        }
    }
    return nil;
}

- (DPHostStreamRecorder*)getVideoRecorderForRecorderId:(NSString*)recorderId
{
    if (!recorderId) {
        return (DPHostStreamRecorder *) self.defaultVideoRecorder;
    }
    for (DPHostRecorder *recorder in self.recorders) {
        if ([recorderId isEqualToString:recorder.recorderId] && [recorder isKindOfClass:[DPHostStreamRecorder class]]) {
            return (DPHostStreamRecorder *) recorder;
        }
    }
    return nil;
}

- (NSString *)usedRecorder
{
    for (DPHostRecorder *recorder in self.recorders) {
        if (recorder.state == DPHostRecorderStateRecording) {
            return recorder.name; //使用中
        }
    }
    return nil; //使用されていない
}
@end
