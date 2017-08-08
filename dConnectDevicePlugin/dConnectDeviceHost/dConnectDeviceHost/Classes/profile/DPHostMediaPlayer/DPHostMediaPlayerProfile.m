//
//  DPHostMediaPlayerProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

// MARK: ファイルシステムやWeb上のメディアコンテンツも参照できる様にする？
// MARK: UIScreenの+screensを使って、別ディスプレイで動画表示できると良いかも？

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
#import "DPHostUtils.h"

@interface DPHostMediaPlayerProfile()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@property MediaPlayerType currentMediaPlayer; ///< 現在使われているメディアプレイヤー

/// 動画再生用ビューコントローラー
@property MPMoviePlayerViewController *viewController;
/// iPodプレイヤー
@property MPMusicPlayerController *musicPlayer;
/// iPodプレイヤーのクエリー
@property MPMediaQuery *defaultMediaQuery;

/// アセットライブラリ検索用のロック
@property NSObject *lockAssetsLibraryQuerying;
/// iPodライブラリ検索用のロック
@property NSObject *lockIPodLibraryQuerying;
@property NSString *nowPlayingMediaId;
@property ALAssetsLibrary *library;

-(void) nowPlayingItemChangedInIPod:(NSNotification *)notification;
- (void) nowPlayingItemChangedInMoviePlayer:(NSNotification *)notification;

/**
 @brief アセットライブラリ（カメラロール等）
        にあるアセット群からメディアコンテキスト群を生成する。
 @param query 文字列クエリー
 @param mimeType MIMEタイプに対するクエリー
 @return カメラロールなどのアセットライブラリにあるメディア群
 */
- (NSArray *)contextsBySearchingAssetsLibraryWithQuery:(NSString *)query
                                              mimeType:(NSString *)mimeType;

/**
 @brief iPodライブラリにあるメディア群からメディアコンテキスト群を生成する。
 @param query 文字列クエリー
 @param mimeType MIMEタイプに対するクエリー
 @return iPodライブラリにあるメディア群
 */
- (NSArray *)contextsBySearchingIPodLibraryWithQuery:(NSString *)query
                                            mimeType:(NSString *)mimeType;

- (MPMoviePlayerViewController *)viewControllerWithURL:(NSURL *)url;

/**
 @brief ムービープレイヤー（MPMoviePlayerViewController）
        が表示されている場合はYESを返却する。
 @return MPMoviePlayerViewControllerが表示されているかどうか。
 */
- (BOOL)moviePlayerViewControllerIsPresented;

/**
 MPMoviePlayerPlaybackDidFinishNotification通知の際に呼び出されるセレクター。
 @param[in] notification 受け取った通知
 */
- (void) videoFinished:(NSNotification*)notification;

@end

@implementation DPHostMediaPlayerProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak DPHostMediaPlayerProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        
        // iPodプレイヤーを取得
        self.musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        self.musicPlayer.shuffleMode = MPMusicShuffleModeDefault;
        self.musicPlayer.repeatMode = MPMusicRepeatModeDefault;
        self.defaultMediaQuery = [MPMediaQuery songsQuery];
        [self.defaultMediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:TargetMPMediaType]
                                          forProperty:MPMediaItemPropertyMediaType]];
        self.library = [ALAssetsLibrary new];
        // 初期はiPodミュージックプレイヤーを設定しておく。
        _currentMediaPlayer = MediaPlayerTypeIPod;
        
        // API登録(didReceiveGetPlayStatusRequest相当)
        NSString *getPlayStatusRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaPlayerProfileAttrPlayStatus];
        [self addGetPath: getPlayStatusRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *status;
                         switch ([weakSelf currentMediaPlayer]) {
                             case MediaPlayerTypeMoviePlayer:
                                 // MoviePlayer
                                 switch ([weakSelf viewController].moviePlayer.playbackState) {
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
                                         break;
                                 }
                                 break;
                             case MediaPlayerTypeIPod:
                                 // iPodミュージックプレイヤー
                                 switch ([weakSelf musicPlayer].playbackState) {
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
                                         break;
                                 }
                                 break;
                         }
                         
                         if (status) {
                             [DConnectMediaPlayerProfile setStatus:status target:response];
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToUnknownWithMessage:@"Status is unknown."];
                         }
                         return YES;
                     }];
        
        // API登録(didReceiveGetMediaRequest相当)
        NSString *getMediaRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addGetPath: getMediaRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
                         
                         if (!mediaId) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
                             return YES;
                         }
                         NSURL *url = [NSURL URLWithString:mediaId];
                         DPHostMediaContext *ctx = [DPHostMediaContext contextWithURL:url];
                         if (ctx) {
                             [ctx setVariousMetadataToMessage:response omitMediaId:YES];
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToUnknownWithMessage:@"Failed to obtain a media context."];
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveGetMediaListRequest相当)
        NSString *getMediaListRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectMediaPlayerProfileAttrMediaList];
        [self addGetPath: getMediaListRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *query = [DConnectMediaPlayerProfile queryFromRequest:request];
                         NSString *mimeType = [DConnectMediaPlayerProfile mimeTypeFromRequest:request];
                         NSString *orderStr = [DConnectMediaPlayerProfile orderFromRequest:request];
                         NSArray *order = nil;
                         if (orderStr) {
                             order = [orderStr componentsSeparatedByString:@","];
                         }
                         NSNumber *offset = [DConnectMediaPlayerProfile offsetFromRequest:request];
                         NSNumber *limit = [DConnectMediaPlayerProfile limitFromRequest:request];
                         
                         NSString *sortTarget;
                         NSString *sortOrder;
                         [weakSelf checkOrder:&sortOrder sortTarget:&sortTarget response:response order:order];
                         if ([response integerForKey:DConnectMessageResult] == DConnectMessageResultTypeError) {
                             return YES;
                         }
                         NSComparator comp;
                         [weakSelf compareOrderWithResponse:response sortTarget:sortTarget sortOrder:sortOrder comparator:&comp];
                         if ([response integerForKey:DConnectMessageResult] == DConnectMessageResultTypeError) {
                             return YES;
                         }
                         
                         if (offset && offset.integerValue < 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset must be a non-negative value."];
                             return YES;
                         }
                         if (limit && limit.integerValue < 0) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"limit must be a positive value."];
                             return YES;
                         }
                         NSString *limitString = [request stringForKey:DConnectMediaPlayerProfileParamLimit];
                         NSString *offsetString = [request stringForKey:DConnectMediaPlayerProfileParamOffset];
                         if (![DPHostUtils existDigitWithString:limitString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"limit must be a digit number."];
                             return YES;
                         }
                         if (![DPHostUtils existDigitWithString:offsetString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset must be a digit number."];
                             return YES;
                         }
                         NSMutableArray *ctxArr = [NSMutableArray array];
                         [ctxArr addObjectsFromArray:[weakSelf contextsBySearchingAssetsLibraryWithQuery:query mimeType:mimeType]];
                         [ctxArr addObjectsFromArray:[weakSelf contextsBySearchingIPodLibraryWithQuery:query mimeType:mimeType]];
                         
                         if (offset && offset.integerValue >= ctxArr.count) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset exceeds the size of the media list."];
                             return YES;
                         }
                         
                         // 並び替えを実行
                         NSArray *tmpArr = [ctxArr sortedArrayUsingComparator:comp];
                         
                         // ページングのために配列の一部分だけ抜き出し
                         if (offset || limit) {
                             NSUInteger offsetVal = offset ? offset.unsignedIntegerValue : 0;
                             NSUInteger limitVal = limit ? limit.unsignedIntegerValue : ctxArr.count;
                             tmpArr = [tmpArr subarrayWithRange:
                                       NSMakeRange(offset.unsignedIntegerValue,
                                                   MIN(ctxArr.count - offsetVal, limitVal))];
                         }
                         
                         [DConnectMediaPlayerProfile setCount:(int)tmpArr.count target:response];
                         DConnectArray *media = [DConnectArray array];
                         for (DPHostMediaContext *ctx in tmpArr) {
                             DConnectMessage *medium = [DConnectMessage message];
                             [ctx setVariousMetadataToMessage:medium omitMediaId:NO];
                             [media addMessage:medium];
                         }
                         [DConnectMediaPlayerProfile setMedia:media target:response];
                         
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];
        
        // API登録(didReceiveGetSeekRequest相当)
        NSString *getSeekRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addGetPath: getSeekRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         __block NSTimeInterval pos;
                         void(^block)(void) = nil;
                         if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                             block = ^{
                                 pos = _musicPlayer.currentPlaybackTime;
                             };
                         } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                             if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                 [response setErrorToUnknownWithMessage:
                                  @"Movie player view controller is not presented;"
                                  "please perform Media PUT API first to present the view controller."];
                                 return YES;
                             }
                             block = ^{
                                 pos = _viewController.moviePlayer.playableDuration;
                             };
                         } else {
                             [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                             return YES;
                         }
                         if ([NSThread isMainThread]) {
                             block();
                         } else {
                             dispatch_sync(dispatch_get_main_queue(), block);
                         }
                         [DConnectMediaPlayerProfile setPos:pos target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];

        // API登録(didReceivePutMediaRequest相当)
        NSString *putMediaRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addPutPath: putMediaRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         @synchronized (weakSelf) {
                             NSString *serviceId = [request serviceId];
                             NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
                             if (!mediaId) {
                                 [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
                                 return YES;
                             }
                             return [weakSelf putMediaRequest: request
                                                     response: response
                                                    serviceId: serviceId
                                                      mediaId: mediaId];
                         }
                     }];
        
        // API登録(didReceivePutPlayRequest相当)
        NSString *putPlayRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrPlay];
        [self addPutPath: putPlayRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         @synchronized (weakSelf) {
                             NSString *serviceId = [request serviceId];
                             
                             if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                                 MPMediaItem *mediaItem = [weakSelf musicPlayer].nowPlayingItem;
                                 if ((!mediaItem || _nowPlayingMediaId) && [_musicPlayer playbackState] == MPMusicPlaybackStateStopped) {
                                     
                                     [weakSelf putMediaRequest:request
                                                      response:response
                                                     serviceId:serviceId
                                                       mediaId:[weakSelf nowPlayingMediaId]];
                                     mediaItem = _musicPlayer.nowPlayingItem;
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
                                         [response setErrorToUnknownWithMessage:
                                          @"Internet is not reachable; the specified audio media item "
                                          "is an iClould item and its playback requires an Internet connection."];
                                         return YES;
                                     }
                                 }
                                 void(^block)(void) = ^{
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
                                                              object:[weakSelf musicPlayer]];
                                     
                                     // 通知開始
                                     [[weakSelf musicPlayer] beginGeneratingPlaybackNotifications];
                                     
                                 };
                                 if ([NSThread isMainThread]) {
                                     block();
                                 } else {
                                     dispatch_sync(dispatch_get_main_queue(), block);
                                 }
                                 [response setResult:DConnectMessageResultTypeOk];
                             } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                                 if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                     [response setErrorToUnknownWithMessage:
                                      @"Movie player view controller is not presented;"
                                      " please perform Media PUT API first to present the view controller."];
                                 } else {
                                     if ([weakSelf viewController].moviePlayer.playbackState != MPMoviePlaybackStatePlaying) {
                                         if ([weakSelf viewController].moviePlayer.contentURL) {
                                             void(^block)(void) = ^{
                                                 DConnectMessage *mediaPlayer = [DConnectMessage message];
                                                 NSString *status = DConnectMediaPlayerProfileStatusPlay;
                                                 [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                                 [weakSelf sendEventMovieWithMessage:mediaPlayer];
                                                 [[weakSelf viewController].moviePlayer setCurrentPlaybackTime:0.0f];
                                                 [[weakSelf viewController].moviePlayer play];
                                                 [response setResult:DConnectMessageResultTypeOk];
                                                 [[DConnectManager sharedManager] sendResponse:response];

                                             };
                                             if ([NSThread isMainThread]) {
                                                 block();
                                             } else {
                                                dispatch_sync(dispatch_get_main_queue(), block);
                                             }
                                              return NO;
                                         }
                                         [response setErrorToUnknownWithMessage:
                                          @"Media cannot be played; media is not specified."];
                                     } else {
                                         [response setErrorToUnknownWithMessage:
                                          @"Media cannot be played; it is already playing."];
                                     }
                                 }
                             } else {
                                 [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                             }
                             
                             return YES;
                         }
                     }];

        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         @synchronized(weakSelf) {
                             void(^block)(void) = nil;
                             if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                                 if (_musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
                                     //[response setErrorToIllegalServerState];
                                     [response setResult:DConnectMessageResultTypeOk];
                                     return YES;
                                 }
                                 block = ^{
                                     // iTunes関連の通知の削除
                                     NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                                     
                                     [notificationCenter removeObserver:weakSelf
                                                                   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                                 object:_musicPlayer];
                                     // 通知終了
                                     [_musicPlayer endGeneratingPlaybackNotifications];
                                     
                                     DConnectMessage *mediaPlayer = [DConnectMessage message];
                                     NSString *status = DConnectMediaPlayerProfileStatusStop;
                                     [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                     [weakSelf sendEventMusicWithMessage:mediaPlayer];
                                     [[weakSelf musicPlayer] stop];
                                     [response setResult:DConnectMessageResultTypeOk];
                                 };
                             } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                                 if (_viewController.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
                                     //[response setErrorToIllegalServerState];
                                     [response setResult:DConnectMessageResultTypeOk];
                                     return YES;
                                 }
                                 if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                     [response setErrorToUnknownWithMessage:
                                      @"Movie player view controller is not presented;"
                                      "please perform Media PUT API first to present the view controller."];
                                 } else {
                                     block = ^{
                                         DConnectMessage *mediaPlayer = [DConnectMessage message];
                                         NSString *status = DConnectMediaPlayerProfileStatusStop;
                                         [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                         [weakSelf sendEventMovieWithMessage:mediaPlayer];
                                         // ムービープレイヤーを閉じる。
                                         [_viewController.moviePlayer stop];
                                         [_viewController dismissMoviePlayerViewControllerAnimated];
                                         [response setResult:DConnectMessageResultTypeOk];
                                     };
                                 }
                             } else {
                                 [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                                 return YES;
                             }
                             
                             if (block) {
                                 if ([NSThread isMainThread]) {
                                     block();
                                 } else {
                                     dispatch_sync(dispatch_get_main_queue(), block);
                                 }
                                 // ViewControllerが閉じるのを待つ
                                 [NSThread sleepForTimeInterval:0.5];

                             }
                             
                             return YES;
                         }
                     }];
        
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         void(^block)(void) = nil;
                         if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                             if ([_musicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
                                 block = ^{
                                     DConnectMessage *mediaPlayer = [DConnectMessage message];
                                     NSString *status = DConnectMediaPlayerProfileStatusPause;
                                     [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                     [self sendEventMusicWithMessage:mediaPlayer];
                                     
                                     
                                     [_musicPlayer pause];
                                     [response setResult:DConnectMessageResultTypeOk];
                                 };
                             } else {
                                 [response setErrorToUnknownWithMessage:@"Media cannnot be paused; media is not playing."];
                                 return YES;
                             }
                         } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                             if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                 [response setErrorToUnknownWithMessage:
                                  @"Movie player view controller is not presented;"
                                  " please perform Media PUT API first to present the view controller."];
                             } else {
                                 if (_viewController.moviePlayer.playbackState == MPMusicPlaybackStatePlaying) {
                                     block = ^{
                                         DConnectMessage *mediaPlayer = [DConnectMessage message];
                                         NSString *status = DConnectMediaPlayerProfileStatusPause;
                                         [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                         [weakSelf sendEventMovieWithMessage:mediaPlayer];
                                         
                                         
                                         [_viewController.moviePlayer pause];
                                         [response setResult:DConnectMessageResultTypeOk];
                                     };
                                 } else {
                                     [response setErrorToUnknownWithMessage:@"Media cannnot be paused; media is not playing."];
                                     return YES;
                                 }
                             }
                         } else {
                             [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                             return YES;
                         }
                         
                         if (block) {
                             if ([NSThread isMainThread]) {
                                 block();
                             } else {
                                 dispatch_sync(dispatch_get_main_queue(), block);
                             }
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaPlayerProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                             if ([_musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
                                 MPMediaItem *mediaItem = [weakSelf musicPlayer].nowPlayingItem;
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
                                         [response setErrorToUnknownWithMessage:
                                          @"Internet is not reachable;"
                                          " the specified audio media item is an iClould "
                                          "item and its playback requires an Internet connection."];
                                         return YES;
                                     }
                                 }
                                 
                                 void(^block)(void) = ^{
                                     DConnectMessage *mediaPlayer = [DConnectMessage message];
                                     NSString *status = DConnectMediaPlayerProfileStatusResume;
                                     [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                     [weakSelf sendEventMusicWithMessage:mediaPlayer];
                                     
                                     
                                     [[weakSelf musicPlayer] play];
                                     [response setResult:DConnectMessageResultTypeOk];
                                 };
                                 if (block) {
                                     if ([NSThread isMainThread]) {
                                         block();
                                     } else {
                                         dispatch_sync(dispatch_get_main_queue(), block);
                                     }
                                 }
                                 
                                 [response setResult:DConnectMessageResultTypeOk];
                             } else {
                                 [response setErrorToUnknownWithMessage:@"Media cannot be resumed; media is not paused."];
                             }
                         } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                             if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                 [response setErrorToUnknownWithMessage:
                                  @"Movie player view controller is not presented;"
                                  "please perform Media PUT API first to present the view controller."];
                             } else {
                                 if (_viewController.moviePlayer.playbackState == MPMoviePlaybackStatePaused) {
                                     void(^block)(void) = ^{
                                         DConnectMessage *mediaPlayer = [DConnectMessage message];
                                         NSString *status = DConnectMediaPlayerProfileStatusResume;
                                         [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
                                         [weakSelf sendEventMovieWithMessage:mediaPlayer];
                                         
                                         
                                         [[weakSelf viewController].moviePlayer play];
                                         [response setResult:DConnectMessageResultTypeOk];
                                     };
                                     if ([NSThread isMainThread]) {
                                         block();
                                     } else {
                                         dispatch_sync(dispatch_get_main_queue(), block);
                                     }
                                 } else {
                                     [response setErrorToUnknownWithMessage:@"Media cannot be resumed; media is not paused."];
                                 }
                             }
                         } else {
                             [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                         }
                         return YES;
                     }];
        
        // API登録(didReceivePutSeekRequest相当)
        NSString *putSeekRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addPutPath: putSeekRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSNumber *pos = [DConnectMediaPlayerProfile posFromRequest:request];
                         
                         NSString *posString = [request stringForKey:DConnectMediaPlayerProfileParamPos];
                         if ((posString && ![DPHostUtils existDigitWithString:posString])) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"pos must be specified."];
                             return YES;
                         }
                         
                         void(^block)(void) = nil;
                         if (_currentMediaPlayer == MediaPlayerTypeIPod) {
                             MPMediaItem *nowPlayingItem = [weakSelf musicPlayer].nowPlayingItem;
                             NSNumber *playbackDuration = [nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
                             if ([playbackDuration unsignedIntegerValue] < [pos unsignedIntegerValue]) {
                                 [response setErrorToInvalidRequestParameterWithMessage:@"pos exceeds the playback duration."];
                                 return YES;
                             }
                             
                             block = ^{
                                 _musicPlayer.currentPlaybackTime = pos.doubleValue;
                             };
                         } else if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
                             if (![weakSelf moviePlayerViewControllerIsPresented]) {
                                 [response setErrorToUnknownWithMessage:
                                  @"Movie player view controller is not presented; "
                                  "please perform Media PUT API first to present the view controller."];
                                 return YES;
                             }
                             NSTimeInterval playbackDuration = [weakSelf viewController].moviePlayer.duration;
                             if (playbackDuration < [pos unsignedIntegerValue]) {
                                 [response setErrorToInvalidRequestParameterWithMessage:@"pos exceeds the playback duration."];
                                 return YES;
                             }
                             
                             block = ^{
                                 _viewController.moviePlayer.currentPlaybackTime = [pos doubleValue];
                             };
                         } else {
                             [response setErrorToUnknownWithMessage:@"Unknown player type; this must be a bug."];
                             return YES;
                         }
                         
                         if ([NSThread isMainThread]) {
                             block();
                         } else {
                             dispatch_sync(dispatch_get_main_queue(), block);
                         }
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnStatusChangeRequest相当)
        NSString *putOnStatusChangeRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addPutPath: putOnStatusChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnStatusChangeRequest相当)
        NSString *deleteOnStatusChangeRequestApiPath = [self apiPath: nil
                                                       attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addDeletePath: deleteOnStatusChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
    }
    return self;
}

- (void)dealloc
{
	// iTunes関連の通知の削除
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	// 通知終了
	[_musicPlayer endGeneratingPlaybackNotifications];
}

// 現在再生中の曲が変わった時の通知
-(void)sendEventMusicWithMessage:(DConnectMessage*)message
{

    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectMediaPlayerProfileName
                                          attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    MPMediaItem *mediaItem = _musicPlayer.nowPlayingItem;
    if (mediaItem) {
        DPHostMediaContext *mediaCtx = [DPHostMediaContext contextWithMediaItem:mediaItem];
        if (mediaCtx.mediaId) {
            [DConnectMediaPlayerProfile setMediaId:mediaCtx.mediaId target:message];
        }
        if (mediaCtx.mimeType) {
            [DConnectMediaPlayerProfile setMIMEType:mediaCtx.mimeType target:message];
        }
        [DConnectMediaPlayerProfile setPos:_musicPlayer.currentPlaybackTime target:message];
    }
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:message target:eventMsg];
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

-(void)sendEventMovieWithMessage:(DConnectMessage*)message
{

    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectMediaPlayerProfileName
                                          attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    NSURL *contentURL = _viewController.moviePlayer.contentURL;
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
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

// 現在再生中の曲が変わった時の通知
-(void) nowPlayingItemChangedInIPod:(NSNotification *)notification
{
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    // 再生コンテンツ変更
    NSString *status;
    if (_musicPlayer.playbackState == MPMusicPlaybackStateStopped) {
        status = DConnectMediaPlayerProfileStatusComplete;
    } else {
        status = DConnectMediaPlayerProfileStatusComplete;
        [_musicPlayer stop];

    }
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMusicWithMessage:mediaPlayer];
}

- (void) nowPlayingItemChangedInMoviePlayer:(NSNotification *)notification
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectMediaPlayerProfileName
                                          attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
    
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    
    // 再生コンテンツ変更
    NSString *status;
    NSURL *contentURL = [notification.object contentURL];
    MPMoviePlaybackState playbackState = _viewController.moviePlayer.playbackState;
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
        
        [DConnectMediaPlayerProfile setPos:_musicPlayer.currentPlaybackTime target:mediaPlayer];
    }
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        
        [DConnectMediaPlayerProfile setMediaPlayer:mediaPlayer target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (NSArray *)contextsBySearchingAssetsLibraryWithQuery:(NSString *)query
                                              mimeType:(NSString *)mimeType
{
    NSAssert(![NSThread isMainThread],
             @"%s can not be invoked from the main queue; please invoke it from the other.", __PRETTY_FUNCTION__);
    
    __block BOOL failed = NO;
    __block NSMutableArray *ctxArr = [NSMutableArray new];
    
    @synchronized(_lockAssetsLibraryQuerying) {
        // アセットライブラリへのクエリ処理を排他にする。
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
        
        
        NSUInteger groupTypes = ALAssetsGroupAll;
        NSString *mimeTypeLowercase = mimeType.lowercaseString;
        id mainLoopBlock = ^(ALAssetsGroup *group, BOOL *stop1)
        {
            if (failed) {
                // 失敗状態になっているのなら、処理を切り上げる。
                *stop1 = YES;
                return;
            }
            
            if(group != nil) {
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop2)
                 {
                     if (failed) {
                         // 失敗状態になっているのなら、処理を切り上げる。
                         *stop2 = YES;
                         return;
                     }
                     
                     if (result) {
                         DPHostMediaContext *ctx = [DPHostMediaContext contextWithAsset:result];
                         if (!ctx) {
                             // コンテキスト作成失敗；スキップ
                             return;
                         }
                         
                         // クエリー検索
                         if (query) {
                             // クエリーのマッチングはファイル名に対して行う。
                             NSRange result = [ctx.title rangeOfString:query];
                             if (result.location == NSNotFound && result.length == 0) {
                                 // クエリーにマッチせず；スキップ。
                                 return;
                             }
                         }
                         // MIMEタイプ検索
                         if (mimeType) {
                             NSRange result = [ctx.mimeType rangeOfString:mimeTypeLowercase];
                             if (result.location == NSNotFound && result.length == 0) {
                                 // MIMEタイプにマッチせず；スキップ。
                                 return;
                             }
                         }
                         
                         @synchronized(ctxArr) {
                             [ctxArr addObject:ctx];
                         }
                     }
                 }];
            } else {
                // group == nil ⇒ イテレーション終了
                dispatch_semaphore_signal(semaphore);
            }
        };
        id failBlock = ^(NSError *error)
        {
            failed = YES;
            return;
        };
        
        [_library enumerateGroupsWithTypes:groupTypes
                               usingBlock:mainLoopBlock
                             failureBlock:failBlock];
        
        // ライブラリのクエリー（非同期）が終わる、もしくはタイムアウトするまで待つ
        long result = dispatch_semaphore_wait(semaphore, timeout);
        if (result != 0) {
            // タイムアウト
            failed = YES;
        }
    }
    
    return failed ? nil : ctxArr;
}

- (NSArray *)contextsBySearchingIPodLibraryWithQuery:(NSString *)query
                                            mimeType:(NSString *)mimeType
{
    NSMutableArray *ctxArr = [NSMutableArray new];
    
    @synchronized(_lockIPodLibraryQuerying) {
        // iTunes Media
        MPMediaQuery *mediaQuery = [MPMediaQuery new];
		[mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:@(TargetMPMediaType)
																		forProperty:MPMediaItemPropertyMediaType]];
		[mediaQuery addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:@(NO)
																		forProperty:MPMediaItemPropertyIsCloudItem]];
        NSArray *items = [mediaQuery items];
        
        NSString *mimeTypeLowsercase = mimeType.lowercaseString;
        for (MPMediaItem *mediaItem in items) {
			if (!(mediaItem.mediaType == MPMediaTypeMusic |
				mediaItem.mediaType == MPMediaTypeHomeVideo)) {
				continue;
			}
            DPHostMediaContext *ctx = [DPHostMediaContext contextWithMediaItem:mediaItem];
            if (!ctx) {
                // コンテキスト作成失敗；スキップ
                continue;
            }
            
            // クエリー検索
            if (query) {
                // クエリーのマッチングはファイル名に対して行う。
                BOOL hit = false;
                NSRange result;
                // titleとcreators.creatorでマッチングを行う。
                result = [ctx.title rangeOfString:query];
                hit = hit || result.location != NSNotFound || result.length != 0;
                
                for (int i = 0; i < [ctx.creators count]; ++i) {
                    result = [[[ctx.creators objectAtIndex:i]
                               stringForKey:DConnectMediaPlayerProfileParamCreator]
                                        rangeOfString:query];
                    hit = hit || result.location != NSNotFound || result.length != 0;
                }
                
                if (!hit) {
                    // クエリーにマッチせず；スキップ。
                    continue;
                }
            }
            // MIMEタイプ検索
            if (mimeType) {
                NSRange result = [ctx.mimeType rangeOfString:mimeTypeLowsercase];
                if (result.location == NSNotFound && result.length == 0) {
                    // MIMEタイプにマッチせず；スキップ。
                    continue;
                }
            }
            
            @synchronized(ctxArr) {
                [ctxArr addObject:ctx];
            }
        }
    }
    
    return ctxArr.count == 0 ? nil : ctxArr;
}

- (MPMoviePlayerViewController *)viewControllerWithURL:(NSURL *)url
{
    MPMoviePlayerViewController *viewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    viewController.moviePlayer.shouldAutoplay = NO;
    // 再生完了通知をさせない様にする
    // MPMoviePlayerViewControllerの初期動作だと、再生完了時に閉じる。
    // 再生完了時に閉じる処理を実行させたくないので、再生完了通知を一旦消す。
    [[NSNotificationCenter defaultCenter] removeObserver:_viewController
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_viewController.moviePlayer];
    // 再生完了の通知；独自の再生完了時に処理を行わせる。
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:viewController.moviePlayer];
    // 再生項目変更の通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(nowPlayingItemChangedInMoviePlayer:)
                                                 name:MPMoviePlayerNowPlayingMovieDidChangeNotification
                                               object:viewController.moviePlayer];
  
    return viewController;
}

- (BOOL)moviePlayerViewControllerIsPresented
{
    UIViewController *rootView = [self topViewController];
    [self topViewController:rootView];
    return ([rootView isKindOfClass:[MPMoviePlayerViewController class]]);
}

- (void) videoFinished:(NSNotification*)notification
{

    int value = [[notification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_viewController.moviePlayer stop];
            [_viewController dismissMoviePlayerViewControllerAnimated];
            [self nowPlayingItemChangedInMoviePlayer:notification];
            
            // 一度閉じたら次回動画再生時には
            // 別のMPMoviePlayerViewControllerインスタンスを使うので、
            // オブザーバーを削除しておく。
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        });
    }
    DConnectMessage *mediaPlayer = [DConnectMessage message];
    NSString *status = DConnectMediaPlayerProfileStatusComplete;
    [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
    [self sendEventMovieWithMessage:mediaPlayer];

}

#pragma mark - Private Methods

- (void)checkOrder:(NSString **)sortOrder
      sortTarget:(NSString **)sortTarget
          response:(DConnectResponseMessage *)response
             order:(NSArray *)order
{
    
    
    if (order) {
        if (order.count >= 2) {
            *sortTarget = order[0];
            *sortOrder = order[1];
        }
        if (!(*sortTarget) || !(*sortOrder)) {
            [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
        }
    } else {
        *sortTarget = DConnectMediaPlayerProfileParamTitle;
        *sortOrder = DConnectMediaPlayerProfileOrderASC;
    }
}

- (void)compareOrderWithResponse:(DConnectResponseMessage *)response
                      sortTarget:(NSString *)sortTarget
                       sortOrder:(NSString *)sortOrder
                          comparator:(NSComparator *)comparator
{
    // ソート対象のNSStringもしくはNSNumberを返却するブロックを用意する。
    id (^accessor)(id);
    NSComparisonResult (^innerComp)(id, id);
    if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamMediaId]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj mediaId];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamMIMEType]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj mimeType];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamTitle]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj title];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamType]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj type];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamLanguage]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj language];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamDescription]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj description];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamDuration]) {
        accessor = ^id(id obj) {
            return [(DPHostMediaContext *)obj duration];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamImageURI]) {
        accessor = ^id(id obj) {
            return[(DPHostMediaContext *)obj imageUri].absoluteString;
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else {
        [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
    }
    
    
    if ([sortOrder isEqualToString:DConnectMediaPlayerProfileOrderASC]) {
        *comparator = ^NSComparisonResult(id obj1, id obj2) {
            id obj1Tmp = accessor(obj1);
            id obj2Tmp = accessor(obj2);
            return innerComp(obj1Tmp, obj2Tmp);
        };
    } else if ([sortOrder isEqualToString:DConnectMediaPlayerProfileOrderDESC]) {
        *comparator = ^NSComparisonResult(id obj1, id obj2) {
            id obj1Tmp = accessor(obj1);
            id obj2Tmp = accessor(obj2);
            return innerComp(obj2Tmp, obj1Tmp);
        };
    } else if (![sortOrder isEqualToString:DConnectMediaPlayerProfileOrderASC]
               && ![sortOrder isEqualToString:DConnectMediaPlayerProfileOrderDESC]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
    }
}

- (void)setIpodMusicMediaWithItem:(MPMediaItem *)mediaItem
                    response:(DConnectResponseMessage *)response
{
    __weak typeof(self) _self = self;
    void(^block)(void) = ^{
        [_musicPlayer setQueueWithQuery:_defaultMediaQuery];
        _musicPlayer.nowPlayingItem = mediaItem;

        DConnectMessage *mediaPlayer = [DConnectMessage message];
        NSString *status = DConnectMediaPlayerProfileStatusMedia;
        [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
        [_self sendEventMusicWithMessage:mediaPlayer];
        
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
    
    [response setResult:DConnectMessageResultTypeOk];

    if (_currentMediaPlayer == MediaPlayerTypeMoviePlayer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            DConnectMessage *mediaPlayer = [DConnectMessage message];
            NSString *status = DConnectMediaPlayerProfileStatusMedia;
            [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
            [_self sendEventMusicWithMessage:mediaPlayer];
            
            
            [_viewController.moviePlayer pause];
            [_viewController dismissMoviePlayerViewControllerAnimated];
        });
    }
    
    _currentMediaPlayer = MediaPlayerTypeIPod;
    
}

- (void)setIpodMovieMediaWithResponse:(DConnectResponseMessage *)response
                                  url:(NSURL *)url
                            mediaItem:(MPMediaItem *)mediaItem
                     isIPodMovieMedia:(BOOL)isIPodMovieMedia
{
    NSURL *movieURL = url;
    if (isIPodMovieMedia) {
        NSNumber *isCloudItem = [mediaItem valueForProperty:MPMediaItemPropertyIsCloudItem];
        if ([isCloudItem boolValue]) {
            [response setErrorToUnknownWithMessage:
             @"Media item specified is an iTunes movie item,"
             "and it must be downloaded into the iOS device before playing."];
            return;
        }
        
        // iPodライブラリの動画メディアはMoviePlayerを使う。
        // MoviePlayerではメディアのURLが必要なので、MPMediaItemからAssetURLを取得する。
        movieURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        if (!movieURL) {
            [response setErrorToUnknownWithMessage:
             @"Failed to pass the specified media item to the movie player;"
             "perhaps this media item is a protected media only playable "
             "in the official apps like \"Music\" and \"Videos\"."];
            return;
        }
    }
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    [asset loadValuesAsynchronouslyForKeys:@[@"hasProtectedContent", @"playable"] completionHandler:
     ^{
         NSError *error = nil;
         
         AVKeyValueStatus keyStatus;
         keyStatus = [asset statusOfValueForKey:@"playable" error:&error];
         if (keyStatus == AVKeyValueStatusFailed || error)
         {
             [response setErrorToUnknownWithMessage:
              @"Operation aborted; Failed to determine "
              "whether the specified media item is protected or not."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         if (!asset.playable) {
             // 再生できない
             [response setErrorToUnknownWithMessage:@"Media item is not playable."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         keyStatus = [asset statusOfValueForKey:@"hasProtectedContent" error:&error];
         if (keyStatus == AVKeyValueStatusFailed || error)
         {
             [response setErrorToUnknownWithMessage:
              @"Operation aborted; Failed to determine whether the specified media item is protected or not."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         if (asset.hasProtectedContent) {
             // 保護コンテンツを持っている；再生できない
             [response setErrorToUnknownWithMessage:
              @"Media item specified is an iTunes movie item and is protected;"
              " protected movie media items are playable only "
              "in the official player apps like Music and Videos."];
             [[DConnectManager sharedManager] sendResponse:response];
             return;
         }
         
         if (_currentMediaPlayer == MediaPlayerTypeIPod &&
             _musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
             // iPodミュージックプレイヤーが再生されている場合は、再生を一時停止する。
             dispatch_async(dispatch_get_main_queue(), ^{
                 [_musicPlayer pause];
             });
         }
         __weak typeof(self) _self = self;
         void(^block)(void) = ^{
             _viewController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
             // 再生項目変更は、2度目以降ではprepareToPlayする
             [_viewController.moviePlayer prepareToPlay];
             [response setResult:DConnectMessageResultTypeOk];
             _currentMediaPlayer = MediaPlayerTypeMoviePlayer;
             DConnectMessage *mediaPlayer = [DConnectMessage message];
             NSString *status = DConnectMediaPlayerProfileStatusMedia;
             [DConnectMediaPlayerProfile setStatus:status target:mediaPlayer];
             [_self sendEventMovieWithMessage:mediaPlayer];
             [[DConnectManager sharedManager] sendResponse:response];
         };
         if ([self moviePlayerViewControllerIsPresented]) {
             block();
         } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 _self.viewController = [_self viewControllerWithURL:movieURL];
                 block();
                 [[_self topViewController] presentMoviePlayerViewControllerAnimated:_viewController];
             });
        }
     }];

}

- (BOOL) putMediaRequest:(DConnectRequestMessage *) request
                response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
                 mediaId:(NSString *)mediaId
{
    NSURL *url = [NSURL URLWithString:mediaId];
    DPHostMediaContext *ctx = [DPHostMediaContext contextWithURL:url];
    if (!ctx) {
        [response setErrorToInvalidRequestParameterWithMessage:@"MediaId is Invalid."];
        return YES;
    }
    _nowPlayingMediaId = mediaId;
    NSNumber *persistentId;
    MPMediaItem *mediaItem;
    BOOL isIPodAudioMedia = [url.scheme isEqualToString:MediaContextMediaIdSchemeIPodAudio];
    BOOL isIPodMovieMedia = [url.scheme isEqualToString:MediaContextMediaIdSchemeIPodMovie];
    if (isIPodAudioMedia || isIPodMovieMedia) {
        persistentId = [DPHostMediaContext persistentIdWithMediaIdURL:url];
        
        MPMediaQuery *mediaQuery = [self defaultMediaQuery].copy;
        [mediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:persistentId
                                          forProperty:MPMediaItemPropertyPersistentID]];
        NSArray *items = [mediaQuery items];
        
        if (items.count == 0) {
            [response setErrorToInvalidRequestParameterWithMessage:@"Media specified by mediaId does not found."];
            return YES;
        }
        mediaItem = items[0];
    }
    
    if (isIPodAudioMedia) {
        [self setIpodMusicMediaWithItem:mediaItem response:response];
        return YES;
    }
    [self setIpodMovieMediaWithResponse:response url:url mediaItem:mediaItem isIPodMovieMedia:isIPodMovieMedia];
    return NO;
}



#pragma mark - Get topMost viewController
- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isMemberOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

@end
