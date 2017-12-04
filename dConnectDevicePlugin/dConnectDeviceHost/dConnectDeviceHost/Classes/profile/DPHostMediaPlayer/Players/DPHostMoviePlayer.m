//
//  DPHostMoviePlayer.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "DPHostMoviePlayer.h"
#import "DPHostUtils.h"
@interface DPHostMoviePlayer()
// 動画再生用ビューコントローラー
@property AVPlayerViewController *playerController;
@property AVPlayer *player;
@property AVAudioSession *session;
// iPodプレイヤーのクエリー
@property MPMediaQuery *defaultMediaQuery;

// Currentの動画URL
@property NSURL *currentContentURL;
@end

@implementation DPHostMoviePlayer
- (instancetype)initWithMediaContext:(DPHostMediaContext *)ctx plugin:(DPHostDevicePlugin *)plugin error:(NSError **)error
{
    self = [super initWithMediaContext:ctx plugin:plugin error:error];
    if (self) {
        self.defaultMediaQuery = [MPMediaQuery songsQuery];
        [self.defaultMediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:TargetMPMediaType]
                                                                                    forProperty:MPMediaItemPropertyMediaType]];
        NSURL *url = [NSURL URLWithString:ctx.mediaId];
        MPMediaItem *mediaItem;
        
        BOOL isIPodMovieMedia = [url.scheme isEqualToString:MediaContextMediaIdSchemeIPodMovie];
        NSNumber *persistentId = [DPHostMediaContext persistentIdWithMediaIdURL:url];
        if (isIPodMovieMedia) {
            MPMediaQuery *mediaQuery = self.defaultMediaQuery.copy;
            
            [mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID]];
            NSArray *items = [mediaQuery items];
            if (items.count == 0) {
                *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"Media specified by mediaId does not found."];
                return nil;
            }
            mediaItem = items[0];
        }
        
        self.currentContentURL = url;
        [self setIpodMovieMediaWithUrl:url mediaItem:mediaItem isIPodMovieMedia:isIPodMovieMedia error:error];
    }
    return self;
}
- (NSString*)playStatus
{
    NSString *status;
    switch (self.playerController.player.timeControlStatus) {
        case AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate:
            status = DConnectMediaPlayerProfileStatusStop;
            break;
        case AVPlayerTimeControlStatusPlaying:
            status = DConnectMediaPlayerProfileStatusPlay;
            break;
        case AVPlayerTimeControlStatusPaused:
            status = DConnectMediaPlayerProfileStatusPause;
            break;
        default:
            status = DConnectMediaPlayerProfileStatusStop;
    }
    return status;
}

- (DPHostPlayerBlock)playWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (![self moviePlayerViewControllerIsPresented] && self.currentContentURL) {
        NSURL *contentURL = self.currentContentURL;
        BOOL isIPodMovieMedia = [contentURL.scheme isEqualToString:MediaContextMediaIdSchemeIPodMovie];
        MPMediaItem *mediaItem;
        if (isIPodMovieMedia) {
            MPMediaQuery *mediaQuery = [self defaultMediaQuery].copy;
            NSNumber *persistentId = [DPHostMediaContext persistentIdWithMediaIdURL:contentURL];
            
            [mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID]];
            NSArray *items = [mediaQuery items];
            if (items.count == 0) {
                *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter
                                                    message:@"Media specified by mediaId does not found."];
                return block;
            }
            mediaItem = items[0];
        }
        [self setIpodMovieMediaWithUrl:contentURL mediaItem:mediaItem isIPodMovieMedia:isIPodMovieMedia error:error];
        return block;
    }
    if (self.playerController.player.timeControlStatus != AVPlayerTimeControlStatusPlaying) {
      if (self.currentContentURL) {
            __weak DPHostMoviePlayer *weakSelf = self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusPlay;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                CMTimeScale playerScale = weakSelf.playerController.player.currentTime.timescale;
                [weakSelf.playerController.player seekToTime:CMTimeMake(0, playerScale)];
                [weakSelf.playerController.player play];
            };
            return block;
        }
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannot be played; media is not specified."];
    }
    return block;
}

- (DPHostPlayerBlock)stopWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (self.playerController.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
        return block;
    }
    if (![self moviePlayerViewControllerIsPresented]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         "please perform Media PUT API first to present the view controller."];
    } else {
        __weak DPHostMoviePlayer *weakSelf = self;
        block = ^{
            // ムービープレイヤーを閉じる。
            [weakSelf.playerController.player pause];
            [weakSelf closeMoviePlayerViewController];
            weakSelf.playerController = nil;
        };
    }
    return block;
}

- (DPHostPlayerBlock)pauseWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (![self moviePlayerViewControllerIsPresented]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         " please perform Media PUT API first to present the view controller."];
    } else {
        if (self.playerController.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
            __weak DPHostMoviePlayer *weakSelf =self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusPause;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                [weakSelf.playerController.player pause];
            };
        } else {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannnot be paused; media is not playing."];
        }
    }
    return block;
}

- (DPHostPlayerBlock)resumeWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (![self moviePlayerViewControllerIsPresented]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         "please perform Media PUT API first to present the view controller."];
    } else {
        if (self.playerController.player.timeControlStatus == AVPlayerTimeControlStatusPaused) {
            __weak DPHostMoviePlayer *weakSelf = self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusResume;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                [weakSelf.playerController.player play];
            };
        } else {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannot be resumed; media is not paused."];
        }
    }
    return block;
}

- (NSTimeInterval)seekStatusWithError:(NSError **)error
{
    if (!self.playerController) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         "please perform Media PUT API first to present the view controller."];
        return -1.0f;
    }
    Float64 dur = CMTimeGetSeconds(self.playerController.player.currentTime);
    Float64 durInMiliSec = 1000 * dur;
    return durInMiliSec;
}

- (DPHostPlayerBlock)seekPosition:(NSNumber *)position error:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (![self moviePlayerViewControllerIsPresented]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented; "
         "please perform Media PUT API first to present the view controller."];
        return block;
    }
    __weak DPHostMoviePlayer *weakSelf = self;
    block = ^{
        CMTimeScale timeScale = weakSelf.playerController.player.currentTime.timescale;
        [weakSelf.playerController.player seekToTime:CMTimeMake([position intValue], timeScale)];
    };
    return block;
}

#pragma mark - ETC public method
- (void)closeMoviePlayerViewController
{
    [self.playerController dismissViewControllerAnimated:YES completion:nil];
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    NSString *status = DConnectMediaPlayerProfileStatusStop;
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMovieWithMessage:mediaPlayer];
}

#pragma mark - Private Method
- (void)setIpodMovieMediaWithUrl:(NSURL *)url
                       mediaItem:(MPMediaItem *)mediaItem
                isIPodMovieMedia:(BOOL)isIPodMovieMedia
                           error:(NSError**)error
{
    NSURL *movieURL = url;
    if (isIPodMovieMedia) {
        NSNumber *isCloudItem = [mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem];
        if ([isCloudItem boolValue]) {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
             @"Media item specified is an iTunes movie item,"
             "and it must be downloaded into the iOS device before playing."];
            return;
        }
        
        // iPodライブラリの動画メディアはMoviePlayerを使う。
        // MoviePlayerではメディアのURLが必要なので、MPMediaItemからAssetURLを取得する。
        movieURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        if (!movieURL) {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
             @"Failed to pass the specified media item to the movie player;"
             "perhaps this media item is a protected media only playable "
             "in the official apps like \"Music\" and \"Videos\"."];
            return;
        }
    }
    

    __weak DPHostMoviePlayer *weakSelf = self;
    void(^block)(void) = ^{
        DConnectMessage *mediaPlayer = [DConnectMessage message];
        NSString *status = DConnectMediaPlayerProfileStatusMedia;
        [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
        [weakSelf sendEventMovieWithMessage:mediaPlayer];
    };
    if ([self moviePlayerViewControllerIsPresented]) {
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:movieURL];
        [self.playerController.player replaceCurrentItemWithPlayerItem:item];
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf viewControllerWithURL:movieURL];
            block();
            [[DPHostUtils topViewController] presentViewController:weakSelf.playerController animated:YES completion:nil];
        });
    }
}
- (BOOL)moviePlayerViewControllerIsPresented
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 3);
    __block UIViewController *rootView = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        rootView = [DPHostUtils topViewController];
        [DPHostUtils topViewController:rootView];
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, timeout);
    return (rootView && [rootView isKindOfClass:[AVPlayerViewController class]]);
}
-(void)sendEventMovieWithMessage:(DConnectMessage*)message
{
    
    // イベントの取得
    NSArray *evts = [super.eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaPlayerProfileName
                                           attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    if (self.currentContentURL) {
        DPHostMediaContext *mediaCtx = [DPHostMediaContext contextWithURL:self.currentContentURL];
        if (mediaCtx.mediaId) {
            [DConnectMediaPlayerProfile setMediaId:mediaCtx.mediaId target:message];
            
        }
        if (mediaCtx.mimeType) {
            [DConnectMediaPlayerProfile setMIMEType:mediaCtx.mimeType target:message];
        }
        Float64 dur = CMTimeGetSeconds(self.playerController.player.currentTime);
        Float64 durInMiliSec = 1000*dur;

        [DConnectMediaPlayerProfile setPos:durInMiliSec target:message];
    }
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:message target:eventMsg];
        [SUPER_PLUGIN sendEvent:eventMsg];
    }
}


- (void)viewControllerWithURL:(NSURL *)url
{
    self.session = [AVAudioSession sharedInstance];
    [self.session setCategory:AVAudioSessionCategoryPlayback error:nil];
    if (!url.scheme) {
        PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[url.absoluteString] options:nil];
        if (assets.count == 0) {
            return;
        }
        __weak DPHostMoviePlayer *weakSelf = self;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        // 30秒経ったらタイムアウト
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            PHVideoRequestOptions *options = [PHVideoRequestOptions new];
            [[PHImageManager defaultManager] requestPlayerItemForVideo:asset
                                                                options:options
                                                          resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                                                              [weakSelf showPlayerForPlayerItem:playerItem];
                                                              dispatch_semaphore_signal(semaphore);
                                                          }];
        }];
        // ライブラリのクエリー（非同期）が終わる、もしくはタイムアウトするまで待つ
        dispatch_semaphore_wait(semaphore, timeout);
    } else {
        [self showPlayerForPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    }
}
- (void)showPlayerForPlayerItem:(AVPlayerItem *)item {
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerController = [AVPlayerViewController new];
    self.playerController.player = self.player;
    self.playerController.videoGravity = AVLayerVideoGravityResizeAspect;
    self.playerController.allowsPictureInPicturePlayback = NO;
    self.playerController.showsPlaybackControls = YES;
    // 再生完了通知をさせない様にする
    // 再生完了時に閉じる処理を実行させたくないので、再生完了通知を一旦消す。
    __weak DPHostMoviePlayer *weakSelf = self;
     dispatch_async(dispatch_get_main_queue(), ^{
         [[NSNotificationCenter defaultCenter] removeObserver:weakSelf
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:item];
         // 再生完了の通知；独自の再生完了時に処理を行わせる。
         [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                  selector:@selector(videoFinished:)
                                                      name:AVPlayerItemDidPlayToEndTimeNotification
                                                    object:item];

    });
}

#pragma mark - Movie Notification

- (void) videoFinished:(NSNotification*)notification
{
    __weak DPHostMoviePlayer *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf closeMoviePlayerViewController];
        weakSelf.playerController = nil;
        // 一度閉じたら次回動画再生時には
        // オブザーバーを削除しておく。
        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
    });
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    NSString *status = DConnectMediaPlayerProfileStatusComplete;
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMovieWithMessage:mediaPlayer];

}
@end
