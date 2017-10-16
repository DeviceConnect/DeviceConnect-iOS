//
//  DPHostRecorderManager.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPHostRecorderManager : NSObject<AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
/*!
 @brief DPHostRecorderManagerの共有インスタンスを返す。
 @return DPHostRecorderManagerの共有インスタンス。
 */
+ (instancetype)sharedManager;

// GET /mediastreamrecording/playstatus
- (NSArray*)playStatus;

// POST /mediastreamrecording/takePhoto
- (void)takephotoForTarget:(NSString*)target completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler;

// POST /mediastreamrecording/record
- (void)recordForTarget:(NSString*)target timeSlice:(NSNumber*)timeSlice response:(DConnectResponseMessage *)response completionHandler:(void (^)(NSError *error))completionHandler;;

// PUT /mediastreamrecording/stop
- (void)stopForTarget:(NSString*)target completionHandler:(void (^)(NSURL *assetURL, NSError *error))completionHandler;

// PUT /mediastreamrecording/pause
- (void)pauseForTarget:(NSString*)target error:(NSError**)error;

// PUT /mediastreamrecording/resume
- (void)resumeForTarget:(NSString*)target error:(NSError**)error;

// PUT /mediastreamrecording/mutetrack
- (void)muteTrackForTarget:(NSString*)target error:(NSError**)error;

// PUT /mediastreamrecording/unmutetrack
- (void)unmuteTrackForTarget:(NSString*)target error:(NSError**)error;

// PUT /mediaStreamRecording/preview
- (NSString*)startPreviewForTarget:(NSString*)target;

// DELETE /mediaStreamRecording/preview
- (void)stopPreviewForTarget:(NSString*)target;
@end
