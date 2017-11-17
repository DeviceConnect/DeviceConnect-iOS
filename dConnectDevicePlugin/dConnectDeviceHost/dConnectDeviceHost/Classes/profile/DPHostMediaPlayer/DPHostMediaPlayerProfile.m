//
//  DPHostMediaPlayerProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <DConnectSDK/DConnectSDK.h>

#import "DPHostDevicePlugin.h"
#import "DPHostMediaPlayerProfile.h"
#import "DPHostMediaContext.h"
#import "DPHostUtils.h"

#import "DPHostMediaPlayer.h"
#import "DPHostMoviePlayer.h"
#import "DPHostMediaPlayerFactory.h"

@interface DPHostMediaPlayerProfile()

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

@property DPHostMediaPlayer *mediaPlayer;

@end

@implementation DPHostMediaPlayerProfile


- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak DPHostMediaPlayerProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        
       
        // API登録(didReceiveGetPlayStatusRequest相当)
        NSString *getPlayStatusRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaPlayerProfileAttrPlayStatus];
        [self addGetPath: getPlayStatusRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         if ([weakSelf mediaPlayer]) {
                             NSString *status = [[weakSelf mediaPlayer] playStatus];
                             [DConnectMediaPlayerProfile setStatus:status target:response];
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToUnknownWithMessage:@"Status is unknown"];
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
                         if (![mediaId hasPrefix:MediaContextMediaIdSchemeIPodAudio]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeFile]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeIPodLibrary]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeIPodMovie]
                             && [mediaId hasPrefix:@"/"]) {
                             mediaId = [NSString stringWithFormat:@"file://%@", mediaId];
                         }
                         NSURL *url = [NSURL URLWithString:[mediaId stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];
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
                         NSNumber *offset = [DConnectMediaPlayerProfile offsetFromRequest:request];
                         NSNumber *limit = [DConnectMediaPlayerProfile limitFromRequest:request];
                         NSError *error = nil;
                         NSArray *tmpArr = [DPHostMediaPlayerFactory searchMediaWithQuery:query
                                                                                 mimeType:mimeType
                                                                                    order:orderStr
                                                                                   offset:offset
                                                                                    limit:limit
                                                                                    error:&error];
                         if (!error) {
                             [DConnectMediaPlayerProfile setCount:(int)tmpArr.count target:response];
                             DConnectArray *media = [DConnectArray array];
                             for (DPHostMediaContext *ctx in tmpArr) {
                                 DConnectMessage *medium = [DConnectMessage message];
                                 [ctx setVariousMetadataToMessage:medium omitMediaId:NO];
                                 [media addMessage:medium];
                             }
                             [DConnectMediaPlayerProfile setMedia:media target:response];
                             
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setError:error.code message:error.localizedDescription];
                         }
                         return YES;
                     }];
        


        // API登録(didReceivePutMediaRequest相当)
        NSString *putMediaRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addPutPath: putMediaRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
                         if (!mediaId) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
                             return YES;
                         }
                         NSError *error = nil;
                         if (weakSelf.mediaPlayer) {
                             // MoviePlayerViewControllerがすでに起動している場合は一度閉じる
                             if ([weakSelf.mediaPlayer isKindOfClass:[DPHostMoviePlayer class]]) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [((DPHostMoviePlayer*)weakSelf.mediaPlayer) closeMoviePlayerViewController];
                                 });
                                 //ViewControllerが閉じるのを待つ
                                 sleep(1.0);
                             }
                         }
                         if (![mediaId hasPrefix:MediaContextMediaIdSchemeIPodAudio]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeFile]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeIPodLibrary]
                             && ![mediaId hasPrefix:MediaContextMediaIdSchemeIPodMovie]
                             && [mediaId hasPrefix:@"/"]) {
                             mediaId = [NSString stringWithFormat:@"file://%@", mediaId];
                         }
                         weakSelf.mediaPlayer = [DPHostMediaPlayerFactory createPlayerWithMediaId:[mediaId stringByReplacingOccurrencesOfString:@" " withString:@"%20"]
                                                                                           plugin:weakSelf.plugin
                                                                                            error:&error];
                         if (weakSelf.mediaPlayer || !error) {
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setError:error.code message:error.localizedDescription];
                         }
                         return YES;
                     }];
        
        // API登録(didReceivePutPlayRequest相当)
        NSString *putPlayRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrPlay];
        [self addPutPath: putPlayRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if (weakSelf.mediaPlayer) {
                             block = [weakSelf.mediaPlayer playWithError:&error];
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Please call PUT Media API first"];
                             return YES;
                         }
                         [weakSelf runMediaPlayerForBlock:block error:error response:response];
                         return YES;
                     }];

        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if (weakSelf.mediaPlayer) {
                             block = [weakSelf.mediaPlayer stopWithError:&error];
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Player status is illegal."];
                             return YES;
                         }
                         [weakSelf runMediaPlayerForBlock:block error:error response:response];
                         return YES;
                     }];
        
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if (weakSelf.mediaPlayer) {
                             block = [weakSelf.mediaPlayer pauseWithError:&error];
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Player status is illegal."];
                             return YES;
                         }
                         [weakSelf runMediaPlayerForBlock:block error:error response:response];
                         return YES;
                     }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaPlayerProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if (weakSelf.mediaPlayer) {
                             block = [weakSelf.mediaPlayer resumeWithError:&error];
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Player status is illegal."];
                             return YES;
                         }
                         [weakSelf runMediaPlayerForBlock:block error:error response:response];
                         return YES;
                     }];
        // API登録(didReceiveGetSeekRequest相当)
        NSString *getSeekRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addGetPath: getSeekRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         __block NSTimeInterval pos = 0.0f;
                         __block NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if ([weakSelf mediaPlayer]) {
                             block = ^{
                                 pos = [[weakSelf mediaPlayer] seekStatusWithError:&error];
                             };
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Player status is illegal."];
                             return YES;
                         }
                         if (!error) {
                             if ([NSThread isMainThread]) {
                                 block();
                             } else {
                                 dispatch_sync(dispatch_get_main_queue(), block);
                             }
                             [DConnectMediaPlayerProfile setPos:pos target:response];
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setError:error.code message:error.localizedDescription];
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
                         
                         NSError *error = nil;
                         DPHostPlayerBlock block = nil;
                         if (weakSelf.mediaPlayer) {
                             block = [weakSelf.mediaPlayer seekPosition:pos error:&error];
                         } else {
                             [response setErrorToIllegalServerStateWithMessage:@"Player status is illegal."];
                             return YES;
                         }
                         [weakSelf runMediaPlayerForBlock:block error:error response:response];
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


#pragma mark - Private Methods

- (void)runMediaPlayerForBlock:(DPHostPlayerBlock)block
                         error:(NSError *)error
                      response:(DConnectResponseMessage *)response {
    if (!error) {
        if ([NSThread isMainThread]) {
            block();
        } else {
            dispatch_sync(dispatch_get_main_queue(), block);
        }
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setError:error.code message:error.localizedDescription];
    }
}


@end
