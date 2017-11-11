//
//  DPHostIPodAudioPlayer.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostIPodAudioPlayer.h"
#import "DPHostUtils.h"
@interface DPHostIPodAudioPlayer()
// iPodプレイヤー
@property MPMusicPlayerController *musicPlayer;

// iPodプレイヤークエリー
@property MPMediaQuery *defaultMediaQuery;

// 再生中のMediaItem
@property MPMediaItem *currentItem;

@end

@implementation DPHostIPodAudioPlayer

- (instancetype)initWithMediaContext:(DPHostMediaContext *)ctx plugin:(DPHostDevicePlugin *)plugin error:(NSError **)error
{
    self = [super initWithMediaContext:ctx plugin:plugin error:error];
    if (self) {
        // iPodプレイヤーを取得
        self.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        self.musicPlayer.shuffleMode = MPMusicShuffleModeOff;
        self.musicPlayer.repeatMode = MPMusicRepeatModeOne;
        self.defaultMediaQuery = [MPMediaQuery songsQuery];
        [self.defaultMediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:TargetMPMediaType]
                                                                                    forProperty:MPMediaItemPropertyMediaType]];
        NSNumber *persistentId = [DPHostMediaContext persistentIdWithMediaIdURL:[NSURL URLWithString:ctx.mediaId]];
        MPMediaQuery *mediaQuery = self.defaultMediaQuery.copy;
        [mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:persistentId forProperty:MPMediaItemPropertyPersistentID]];
        NSArray *items = [mediaQuery items];
        if (items.count == 0) {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"Media specified by mediaId does not found"];
            return nil;
        }
        self.currentItem = items[0];
        self.defaultMediaQuery = mediaQuery;
        [self setIpodMusicMediaWithItem:self.currentItem];
    }
    return self;
}

- (NSString*)playStatus
{
    NSString *status;
    // iPodミュージックプレイヤー
    switch (self.musicPlayer.playbackState) {
        case MPMusicPlaybackStateStopped:
            status = DConnectMediaPlayerProfileStatusStop;
            break;
        case MPMusicPlaybackStatePlaying:
            status = DConnectMediaPlayerProfileStatusPlay;
            break;
        case MPMusicPlaybackStatePaused:
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
    MPMediaItem *mediaItem = self.musicPlayer.nowPlayingItem;
    if (self.currentItem && self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        [self setIpodMusicMediaWithItem:self.currentItem];
    }
    NSNumber *isCloudItem = [mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem];
    if (isCloudItem) {
        DPHostReachability *networkReachability
        = [DPHostReachability reachabilityForInternetConnection];
        NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
        if ([isCloudItem boolValue] && networkStatus == NotReachable) {
            // iCloud上の音楽項目
            // （つまりiOSデバイス側にまだダウンロードされていない）で、
            // 尚かつインターネット接続が無い場合は
            // 再生できない。
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
             @"Internet is not reachable; the specified audio media item "
             "is an iClould item and its playback requires an Internet connection."];
            return block;
        }
    }
    __weak DPHostIPodAudioPlayer *weakSelf = self;
    block = ^{
        DConnectMessage *mediaPlayer = [DConnectMessage message];
        NSString *status = DConnectMediaPlayerProfileStatusPlay;
        [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
        [weakSelf sendEventMusicWithMessage:mediaPlayer];
        [[weakSelf musicPlayer] setCurrentPlaybackTime:0.0f];
        [[weakSelf musicPlayer] play];
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        // 現在再生中の曲が変わった時の通知
        [notificationCenter addObserver:weakSelf
                               selector:@selector(nowPlayingItemChangedInIPod:)
                                   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                 object:weakSelf.musicPlayer];
        
        // 通知開始
        [weakSelf.musicPlayer beginGeneratingPlaybackNotifications];
    };
    return block;
}


- (DPHostPlayerBlock)stopWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        return block;
    }
    __weak DPHostIPodAudioPlayer *weakSelf = self;
    block = ^{
        // iTunes関連の通知の削除
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        
        [notificationCenter removeObserver:weakSelf
                                      name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                    object:weakSelf.musicPlayer];
        // 通知終了
        [weakSelf.musicPlayer endGeneratingPlaybackNotifications];
        
        DConnectMessage *mediaPlayer = [DConnectMessage message];
        NSString *status = DConnectMediaPlayerProfileStatusStop;
        [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
        [weakSelf sendEventMusicWithMessage:mediaPlayer];
        [weakSelf.musicPlayer stop];
    };
    return block;
}

- (DPHostPlayerBlock)pauseWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
        __weak DPHostIPodAudioPlayer *weakSelf = self;
        block = ^{
            DConnectMessage *mediaPlayer = [DConnectMessage message];
            NSString *status = DConnectMediaPlayerProfileStatusPause;
            [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
            [weakSelf sendEventMusicWithMessage:mediaPlayer];
            [weakSelf.musicPlayer pause];
        };
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannnot be paused; media is not playing."];
    }
    return block;
}

- (DPHostPlayerBlock)resumeWithError:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    if (self.musicPlayer.playbackState == MPMusicPlaybackStatePaused) {
        MPMediaItem *mediaItem = self.musicPlayer.nowPlayingItem;
        NSNumber *isCloudItem = [mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem];
        if (isCloudItem) {
            DPHostReachability *networkReachability
            = [DPHostReachability reachabilityForInternetConnection];
            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
            if ([isCloudItem boolValue] && networkStatus == NotReachable) {
                // iCloud上の音楽項目
                //（つまりiOSデバイス側にまだダウンロードされていない）で、
                //尚かつインターネット接続が無い場合は
                // 再生できない。
                *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:
                 @"Internet is not reachable;"
                 " the specified audio media item is an iClould "
                 "item and its playback requires an Internet connection."];
                return block;
            }
        }
        __weak DPHostIPodAudioPlayer *weakSelf = self;
        block = ^{
            DConnectMessage *mediaPlayer = [DConnectMessage message];
            NSString *status = DConnectMediaPlayerProfileStatusResume;
            [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
            [weakSelf sendEventMusicWithMessage:mediaPlayer];
            [weakSelf.musicPlayer play];
        };
    } else {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeUnknown message:@"Media cannot be resumed; media is not paused."];
    }
    return block;
}

- (NSTimeInterval)seekStatusWithError:(NSError **)error
{
    return self.musicPlayer.currentPlaybackTime;
}

- (DPHostPlayerBlock)seekPosition:(NSNumber *)position error:(NSError **)error
{
    DPHostPlayerBlock block = ^{};
    MPMediaItem *nowPlayingItem = self.musicPlayer.nowPlayingItem;
    NSNumber *playbackDuration = [nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    if ([playbackDuration unsignedIntegerValue] < [position unsignedIntegerValue]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"pos exceeds the playback duration."];
        return block;
    }
    __weak DPHostIPodAudioPlayer *weakSelf = self;
    block = ^{
        weakSelf.musicPlayer.currentPlaybackTime = position.doubleValue;
    };
    return block;
}

#pragma mark - Private Method
- (void)setIpodMusicMediaWithItem:(MPMediaItem *)mediaItem
{
    __weak typeof(self) weakSelf = self;
    void(^block)(void) = ^{
        [weakSelf.musicPlayer setQueueWithQuery:weakSelf.defaultMediaQuery];
        weakSelf.musicPlayer.nowPlayingItem = mediaItem;
        
        DConnectMessage *mediaPlayer = [DConnectMessage message];
        NSString *status = DConnectMediaPlayerProfileStatusMedia;
        [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
        [weakSelf.self sendEventMusicWithMessage:mediaPlayer];
        
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

// 現在再生中の曲が変わった時の通知
-(void)sendEventMusicWithMessage:(DConnectMessage*)message
{
    
    // イベントの取得
    NSArray *evts = [super.eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaPlayerProfileName
                                           attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    MPMediaItem *mediaItem = self.musicPlayer.nowPlayingItem;
    if (mediaItem) {
        DPHostMediaContext *mediaCtx = [DPHostMediaContext contextWithMediaItem:mediaItem];
        if (mediaCtx.mediaId) {
            [DConnectMediaPlayerProfile setMediaId:mediaCtx.mediaId target:message];
        }
        if (mediaCtx.mimeType) {
            [DConnectMediaPlayerProfile setMIMEType:mediaCtx.mimeType target:message];
        }
        [DConnectMediaPlayerProfile setPos:self.musicPlayer.currentPlaybackTime target:message];
    }
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:message target:eventMsg];
        [SUPER_PLUGIN sendEvent:eventMsg];
    }
}

#pragma mark - Ipod Music Notification

// 現在再生中の曲が変わった時の通知
-(void) nowPlayingItemChangedInIPod:(NSNotification *)notification
{
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    // 再生コンテンツ変更
    NSString *status;
    if (self.musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        status = DConnectMediaPlayerProfileStatusComplete;
    } else {
        status = DConnectMediaPlayerProfileStatusComplete;
        [self.musicPlayer stop];
        
    }
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMusicWithMessage:mediaPlayer];
}
@end
