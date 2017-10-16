//
//  DPHostMoviePlayer.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPHostMoviePlayer.h"
#import "DPHostUtils.h"
@interface DPHostMoviePlayer()
// 動画再生用ビューコントローラー
@property MPMoviePlayerViewController *viewController;
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
    // MoviePlayer
    switch (self.viewController.moviePlayer.playbackState) {
        case MPMoviePlaybackStateStopped:
            status = DConnectMediaPlayerProfileStatusStop;
            break;
        case MPMoviePlaybackStatePlaying:
            status = DConnectMediaPlayerProfileStatusPlay;
            break;
        case MPMoviePlaybackStatePaused:
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
    if (self.viewController.moviePlayer.playbackState != MPMoviePlaybackStatePlaying) {
        if (self.viewController.moviePlayer.contentURL) {
            __weak DPHostMoviePlayer *weakSelf = self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusPlay;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                [weakSelf.viewController.moviePlayer setCurrentPlaybackRate:0.0f];
                [weakSelf.viewController.moviePlayer play];
                
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
    if (self.viewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
        return block;
    }
    if (![self moviePlayerViewControllerIsPresented]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         "please perform Media PUT API first to present the view controller."];
    } else {
        __weak DPHostMoviePlayer *weakSelf = self;
        block = ^{
            DConnectMessage *mediaPlayer = [DConnectMessage message];
            NSString *status = DConnectMediaPlayerProfileStatusStop;
            [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
            [weakSelf sendEventMovieWithMessage:mediaPlayer];
            // ムービープレイヤーを閉じる。
            [weakSelf.viewController.moviePlayer stop];
            [weakSelf.viewController dismissMoviePlayerViewControllerAnimated];
            weakSelf.viewController = nil;
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
        if (self.viewController.moviePlayer.playbackState == MPMusicPlaybackStatePlaying) {
            __weak DPHostMoviePlayer *weakSelf =self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusPause;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                [weakSelf.viewController.moviePlayer pause];
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
        if (self.viewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
            __weak DPHostMoviePlayer *weakSelf = self;
            block = ^{
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                NSString *status = DConnectMediaPlayerProfileStatusResume;
                [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                [weakSelf sendEventMovieWithMessage:mediaPlayer];
                [weakSelf.viewController.moviePlayer play];
            };
        } else {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannot be resumed; media is not paused."];
        }
    }
    return block;
}

- (NSTimeInterval)seekStatusWithError:(NSError **)error
{
    if (!self.viewController) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
         @"Movie player view controller is not presented;"
         "please perform Media PUT API first to present the view controller."];
        return -1.0f;
    }
    return self.viewController.moviePlayer.playableDuration;
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
    NSTimeInterval playbackDuration = self.viewController.moviePlayer.duration;
    if (playbackDuration < [position unsignedIntegerValue]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"pos exceeds the playback duration."];
        return block;
    }
    __weak DPHostMoviePlayer *weakSelf = self;
    block = ^{
        weakSelf.viewController.moviePlayer.currentPlaybackTime = [position doubleValue];
    };
    return block;
}

#pragma mark - ETC public method
- (void)closeMoviePlayerViewController
{
    [self.viewController dismissMoviePlayerViewControllerAnimated];
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
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
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 5);
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
    __weak DPHostMoviePlayer *weakSelf = self;
    [asset loadValuesAsynchronouslyForKeys:@[@"hasProtectedContent", @"playable"] completionHandler:
     ^{
         void(^block)(void) = ^{
             weakSelf.viewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
             // 再生項目変更は、2度目以降ではprepareToPlayする
             [weakSelf.viewController.moviePlayer prepareToPlay];
             DConnectMessage *mediaPlayer = [DConnectMessage message];
             NSString *status = DConnectMediaPlayerProfileStatusMedia;
             [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
             [weakSelf sendEventMovieWithMessage:mediaPlayer];

         };
         if ([weakSelf moviePlayerViewControllerIsPresented]) {
             block();
         } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.viewController = [weakSelf viewControllerWithURL:movieURL];
                 self.viewController.moviePlayer.shouldAutoplay = YES;
                 block();
                 [[DPHostUtils topViewController] presentMoviePlayerViewControllerAnimated:weakSelf.viewController];
             });
         }
         dispatch_semaphore_signal(semaphore);
     }];
    dispatch_semaphore_wait(semaphore, timeout);
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
    return (rootView && [rootView isKindOfClass:[MPMoviePlayerViewController class]]);
}
-(void)sendEventMovieWithMessage:(DConnectMessage*)message
{
    
    // イベントの取得
    NSArray *evts = [super.eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaPlayerProfileName
                                           attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    NSURL *contentURL = self.viewController.moviePlayer.contentURL;
    if (contentURL) {
        DPHostMediaContext *mediaCtx = [DPHostMediaContext contextWithURL:contentURL];
        if (mediaCtx.mediaId) {
            [DConnectMediaPlayerProfile setMediaId:mediaCtx.mediaId target:message];
            
        }
        if (mediaCtx.mimeType) {
            [DConnectMediaPlayerProfile setMIMEType:mediaCtx.mimeType target:message];
        }
        
        [DConnectMediaPlayerProfile setPos:_viewController.moviePlayer.currentPlaybackTime target:message];
    }
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:message target:eventMsg];
        [SUPER_PLUGIN sendEvent:eventMsg];
    }
}

- (MPMoviePlayerViewController *)viewControllerWithURL:(NSURL *)url
{
    MPMoviePlayerViewController *viewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    viewController.moviePlayer.shouldAutoplay = NO;
    
    // 再生完了通知をさせない様にする
    // MPMoviePlayerViewControllerの初期動作だと、再生完了時に閉じる。
    // 再生完了時に閉じる処理を実行させたくないので、再生完了通知を一旦消す。
    [[NSNotificationCenter defaultCenter] removeObserver:self.viewController
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:self.viewController.moviePlayer];
    // 再生完了の通知；独自の再生完了時に処理を行わせる。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.viewController.moviePlayer];
    // 再生項目変更の通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChangedInMoviePlayer:)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
                                               object:self.viewController.moviePlayer];
    
    return viewController;
}

#pragma mark - Movie Notification
- (void) videoFinished:(NSNotification*)notification
{
    
    int value = [[notification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        __weak DPHostMoviePlayer *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.viewController.moviePlayer stop];
            [weakSelf.viewController dismissMoviePlayerViewControllerAnimated];
            weakSelf.viewController = nil;
            [weakSelf nowPlayingItemChangedInMoviePlayer:notification];
            
            // 一度閉じたら次回動画再生時には
            // 別のMPMoviePlayerViewControllerインスタンスを使うので、
            // オブザーバーを削除しておく。
            [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
        });
    }
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    NSString *status = DConnectMediaPlayerProfileStatusComplete;
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMovieWithMessage:mediaPlayer];
    
}

- (void) nowPlayingItemChangedInMoviePlayer:(NSNotification *)notification
{
    // イベントの取得
    NSArray *evts = [super.eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaPlayerProfileName
                                           attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    
    // 再生コンテンツ変更
    NSString *status;
    NSURL *contentURL = [notification.object contentURL];
    MPMoviePlaybackState playbackState = self.viewController.moviePlayer.playbackState;
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
            status = DConnectMediaPlayerProfileStatusStop;
            break;
        case MPMoviePlaybackStatePlaying:
            status = DConnectMediaPlayerProfileStatusPlay;
            break;
        case MPMoviePlaybackStatePaused:
            status = DConnectMediaPlayerProfileStatusPause;
            break;
        default:
            status = DConnectMediaPlayerProfileStatusMedia;
            break;
    }
    
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    
    if (contentURL) {
        DPHostMediaContext *mediaCtx = [DPHostMediaContext contextWithURL:contentURL];
        if (mediaCtx) {
            if (mediaCtx.mediaId) {
                [DConnectMediaPlayerProfile setMediaId:mediaCtx.mediaId target:mediaPlayer];
            }
            if (mediaCtx.mimeType) {
                [DConnectMediaPlayerProfile setMIMEType:mediaCtx.mimeType target:mediaPlayer];
            }
        }
        
        [DConnectMediaPlayerProfile setPos:self.viewController.moviePlayer.currentPlaybackTime target:mediaPlayer];
    }
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:mediaPlayer target:eventMsg];
        
        [SUPER_PLUGIN sendEvent:eventMsg];
    }
}
@end
