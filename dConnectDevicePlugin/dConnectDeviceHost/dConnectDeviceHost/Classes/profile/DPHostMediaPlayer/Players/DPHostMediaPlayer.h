//
//  DPHostMediaPlayer.h
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import <ImageIO/CGImageProperties.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import <DConnectSDK/DConnectSDK.h>

#import "DPHostDevicePlugin.h"
#import "DPHostMediaPlayerProfile.h"
#import "DPHostMediaContext.h"
#import "DPHostReachability.h"
#import "DPHostService.h"
#import "DPHostUtil.h"

@interface DPHostMediaPlayer : NSObject
// @brief メディア処理の実行用Block
typedef void (^DPHostPlayerBlock)(void);

// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

// @brief DevicePlugin
@property DPHostDevicePlugin *plugin;

// PUT /mediaPlayer/media
- (instancetype)initWithMediaContext:(DPHostMediaContext*)ctx
                              plugin:(DPHostDevicePlugin*)plugin
                               error:(NSError**)error;

// GET /mediaPlayer/status
- (NSString*)playStatus;

// PUT /mediaPlayer/play
- (DPHostPlayerBlock)playWithError:(NSError**)error;

// PUT /mediaPlayer/stop
- (DPHostPlayerBlock)stopWithError:(NSError**)error;

// PUT /mediaPlayer/pause
- (DPHostPlayerBlock)pauseWithError:(NSError**)error;

// PUT /mediaPlayer/resume
- (DPHostPlayerBlock)resumeWithError:(NSError**)error;

// GET /mediaPlayer/seek
- (NSTimeInterval)seekStatusWithError:(NSError**)error;

// PUT /mediaPlayer/seek
- (DPHostPlayerBlock)seekPosition:(NSNumber*)position error:(NSError**)error;



@end
