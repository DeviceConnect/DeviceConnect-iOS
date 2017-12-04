//
//  DPChromecastMediaPlayerProfile.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastManager.h"
#import "DPChromecastMediaPlayerProfile.h"
#import "DPChromecastDevicePlugin.h"
#import "DPChromecastMediaContext.h"
#import <GoogleCast/GoogleCast.h>
#import <Photos/Photos.h>

static NSString *const DPChromeCastDefaultVideoURL = @"https://github.com/DeviceConnect/DeviceConnect-Android/wiki/sphero_demo.MOV";
@interface DPChromecastMediaPlayerProfile()
/// アセットライブラリ検索用のロック
@property NSObject *lockAssetsLibraryQuerying;
@end

@implementation DPChromecastMediaPlayerProfile

- (id)init
{
    self = [super init];
    if (self) {

        __weak DPChromecastMediaPlayerProfile *weakSelf = self;
        
        // API登録(didReceiveGetPlayStatusRequest相当)
        NSString *getPlayStatusRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaPlayerProfileAttrPlayStatus];
        [self addGetPath: getPlayStatusRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 再生状態取得
                                     NSString *status = [[DPChromecastManager sharedManager] mediaPlayerStateWithID:serviceId];
                                     [response setString:status forKey:@"status"];
                                 }];
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
                         
                         if ([mediaId isEqualToString:DPChromeCastDefaultVideoURL]) {
                             [response setResult:DConnectMessageResultTypeOk];
                             [DConnectMediaPlayerProfile setMIMEType:@"video/quicktime" target:response];
                             [DConnectMediaPlayerProfile setTitle:@"Title: Sample" target:response];
                             [DConnectMediaPlayerProfile setLanguage:@"ja" target:response];
                             [DConnectMediaPlayerProfile setDescription:@"Sample Movie" target:response];
                             [DConnectMediaPlayerProfile setDuration:600 target:response];
                             
                         } else {
                             NSURL *url = [NSURL URLWithString:mediaId];
                             DPChromecastMediaContext *ctx = [DPChromecastMediaContext contextWithURL:url];
                             if (ctx.mediaId) {
                                 [ctx setVariousMetadataToMessage:response omitMediaId:YES];
                                 [response setResult:DConnectMessageResultTypeOk];
                             } else {
                                 [response setErrorToUnknownWithMessage:@"Failed to obtain a media context."];
                             }
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveGetMediaListRequest相当)
        NSString *getMediaListRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectMediaPlayerProfileAttrMediaList];
        [self addGetPath: getMediaListRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
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
                         
                         NSString *offsetString = [request stringForKey:DConnectMediaPlayerProfileParamOffset];
                         NSString *limitString = [request stringForKey:DConnectMediaPlayerProfileParamLimit];
                         if (![[DPChromecastManager sharedManager] existDigitWithString:offsetString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"offset is Invalid."];
                             return YES;
                         }
                         if (![[DPChromecastManager sharedManager] existDigitWithString:limitString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"limit is Invalid."];
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
                         
                         [response setResult:DConnectMessageResultTypeOk];
                         [DConnectMediaPlayerProfile setCount:0 target:response];
                         if (!limit || (limit && limit.integerValue > 0)) {
                             //サンプルムービの追加
                             DPChromecastMediaContext *sampleCtx = [DPChromecastMediaContext new];
                             sampleCtx.mediaId = DPChromeCastDefaultVideoURL;
                             sampleCtx.mimeType = @"video/quicktime";
                             sampleCtx.title = @"Title: Sample";
                             sampleCtx.duration = @(9999);
                             sampleCtx.language = @"ja";
                             sampleCtx.desc = @"Sample Movie";
                             NSMutableArray *ctxArr = [NSMutableArray array];
                             [ctxArr addObject:sampleCtx];
                             [ctxArr addObjectsFromArray:[weakSelf contextsBySearchingPhotoLibraryWithQuery:query mimeType:mimeType]];
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
                             DConnectArray *media = [DConnectArray array];
                             for (DPChromecastMediaContext *ctx in tmpArr) {
                                 DConnectMessage *medium = [DConnectMessage message];
                                 [ctx setVariousMetadataToMessage:medium omitMediaId:NO];
                                 [media addMessage:medium];
                             }
                             [DConnectMediaPlayerProfile setMedia:media target:response];
                             [DConnectMediaPlayerProfile setCount:media.count target:response];
                             
                         }
                         
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:nil];
                     }];
        
        // API登録(didReceiveGetSeekRequest相当)
        NSString *getSeekRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addGetPath: getSeekRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 再生位置取得
                                     NSTimeInterval pos = [[DPChromecastManager sharedManager] streamPositionWithID:serviceId];
                                     [response setDouble:pos forKey:@"pos"];
                                 }];
                     }];
        
        // API登録(didReceiveGetVolumeRequest相当)
        NSString *getVolumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaPlayerProfileAttrVolume];
        [self addGetPath: getVolumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 音量取得
                                     float vol = [[DPChromecastManager sharedManager] volumeWithID:serviceId];
                                     [response setDouble:vol forKey:@"volume"];
                                 }];
                     }];
        
        // API登録(didReceiveGetMuteRequest相当)
        NSString *getMuteRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addGetPath: getMuteRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // ミュート状態取得
                                     BOOL mute = [[DPChromecastManager sharedManager] isMutedWithID:serviceId];
                                     
                                     [response setBool:mute forKey:@"mute"];
                                 }];
                     }];

        // API登録(didReceivePutMediaRequest相当)
        NSString *putMediaRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addPutPath: putMediaRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];

                         if (!mediaId) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
                             return YES;
                         }
                         if ([mediaId isEqualToString:DPChromeCastDefaultVideoURL]) {
                             return [weakSelf handleRequest:request
                                                   response:response
                                                  serviceId:serviceId
                                                   callback:
                                     ^{
                                         // ロード
                                         NSInteger requestId = [[DPChromecastManager sharedManager] loadMediaWithID:serviceId
                                                                                                            mediaID:mediaId];
                                         //リクエストを送信できなかった
                                         if(requestId == kGCKInvalidRequestID){
                                             [response setString:@"mediaId is not exist" forKey:@"value"];
                                         }
                                     }];
                         } else {
                             NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                             NSString *documentsDirectory = [paths objectAtIndex:0];
                             [[DPChromecastManager sharedManager] removeFileForfileNamesAtDirectoryPath:documentsDirectory
                                                                                              extension:@"MOV"];
                             
                             DPChromecastMediaContext *ctx = [DPChromecastMediaContext contextWithURL:
                                                              [NSURL URLWithString:mediaId]];
                             if (!ctx.mediaId) {
                                 [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
                                 return YES;
                             }
                             DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                             [mgr connectToDeviceWithID:serviceId completion:^(BOOL success, NSString *error) {
                                 if (success) {
                                     [weakSelf saveMovie:ctx
                                                callback:
                                      ^(NSString *url) {
                                                if (url) {
                                                    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                                                    NSInteger requestId = [mgr loadMediaWithID:serviceId
                                                                                       mediaID:url];
                                                    if(requestId == kGCKInvalidRequestID){
                                                        [response setErrorToIllegalServerStateWithMessage:
                                                         @"mediaId is not exist"];
                                                    } else {
                                                        [response setResult:DConnectMessageResultTypeOk];
                                                    }
                                                } else {
                                                    [response setErrorToNotFoundService];
                                                }
                                                [[DConnectManager sharedManager] sendResponse:response];
                                            }];
                                 } else {
                                     // エラー
                                     [response setErrorToNotFoundService];
                                     [[DConnectManager sharedManager] sendResponse:response];
                                 }
                             }];
                             return NO;
                         }
                     }];
        
        // API登録(didReceivePutPlayRequest相当)
        NSString *putPlayRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrPlay];
        [self addPutPath: putPlayRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 再生
                                     NSInteger requestId = [[DPChromecastManager sharedManager] playWithID:serviceId];
                                     //リクエストを送信できなかった
                                     if(requestId == kGCKInvalidRequestID){
                                         [response setErrorToInvalidRequestParameterWithMessage:@"Media is not selected"];
                                     }
                                 }];
                     }];
        
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 停止
                                     NSInteger requestId = [[DPChromecastManager sharedManager] stopWithID:serviceId];
                                     // リクエストを送信できなかった
                                     if(requestId == kGCKInvalidRequestID){
                                         [response setErrorToInvalidRequestParameterWithMessage:@"Media is not selected"];
                                     }
                                 }];
                     }];
        
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaPlayerProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 一時停止
                                     NSInteger requestId = [[DPChromecastManager sharedManager] pauseWithID:serviceId];
                                     //リクエストを送信できなかった
                                     if(requestId == kGCKInvalidRequestID){
                                         [response setErrorToInvalidRequestParameterWithMessage:@"Media is not selected"];
                                     }
                                 }];
                     }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaPlayerProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 再生
                                     NSInteger requestId = [[DPChromecastManager sharedManager] playWithID:serviceId];
                                     //リクエストを送信できなかった
                                     if(requestId == kGCKInvalidRequestID){
                                         [response setErrorToInvalidRequestParameterWithMessage:@"Media is not selected"];
                                     }
                                 }];
                     }];
        
        // API登録(didReceivePutSeekRequest相当)
        NSString *putSeekRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addPutPath: putSeekRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSNumber *pos = [DConnectMediaPlayerProfile posFromRequest:request];
                         
                         DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                         NSString *posString = [request stringForKey:DConnectMediaPlayerProfileParamPos];
                         if (![[DPChromecastManager sharedManager] existDigitWithString:posString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"pos is Invalid."];
                             return YES;
                         }
                         if (pos == nil || [pos doubleValue] < 0 || [mgr durationWithID:serviceId] < [pos doubleValue]) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 再生位置変更
                                     [[DPChromecastManager sharedManager] setStreamPositionWithID:serviceId position:[pos doubleValue]];
                                 }];
                     }];
        
        // API登録(didReceivePutVolumeRequest相当)
        NSString *putVolumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaPlayerProfileAttrVolume];
        [self addPutPath: putVolumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         NSNumber *volume = [DConnectMediaPlayerProfile volumeFromRequest:request];
                         
                         // パラメータチェック
                         float vol = [volume floatValue];
                         NSString *volString = [request stringForKey:DConnectMediaPlayerProfileParamVolume];
                         if (![[DPChromecastManager sharedManager] existDecimalWithString:volString]) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"Volume is Invalid."];
                             return YES;
                         }
                         if (!volume || vol < 0 || vol > 1.0) {
                             [response setErrorToInvalidRequestParameter];
                             return YES;
                         }
                         
                         // リクエスト処理
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // 音量変更
                                     [[DPChromecastManager sharedManager] setVolumeWithID:serviceId volume:vol];
                                 }];
                     }];
        
        // API登録(didReceivePutMuteRequest相当)
        NSString *putMuteRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addPutPath: putMuteRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         return [weakSelf handleRequest:request
                                               response:response
                                              serviceId:serviceId
                                               callback:
                                 ^{
                                     // ミュート有効化
                                     [[DPChromecastManager sharedManager] setIsMutedWithID:serviceId muted:YES];
                                 }];
                     }];
        
        // API登録(didReceiveDeleteMuteRequest相当)
        NSString *deleteMuteRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addDeletePath: deleteMuteRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            NSString *serviceId = [request serviceId];
                            // リクエスト処理
                            return [weakSelf handleRequest:request
                                                  response:response
                                                 serviceId:serviceId
                                                  callback:
                                    ^{
                                        // ミュート無効化
                                        [[DPChromecastManager sharedManager] setIsMutedWithID:serviceId muted:NO];
                                    }];
                        }];

        // API登録(didReceivePutOnStatusChangeRequest相当)
        NSString *putOnStatusChangeRequestApiPath = [self apiPath: nil
                                                    attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addPutPath: putOnStatusChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         [weakSelf handleEventRequest:request response:response isRemove:NO callback:^{
                             [weakSelf addMediaEvent:serviceId];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnStatusChangeRequest相当)
        NSString *deleteOnStatusChangeRequestApiPath = [self apiPath: nil
                                                       attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addDeletePath: deleteOnStatusChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         // DConnectイベント削除
                         [weakSelf handleEventRequest:request response:response isRemove:YES callback:^{
                         }];
                         return YES;
                     }];
    }
    return self;
}


- (NSArray *)contextsBySearchingPhotoLibraryWithQuery:(NSString *)query
                                             mimeType:(NSString *)mimeType
{
    __block NSMutableArray *ctxArr = [NSMutableArray new];
    NSString *mimeTypeLowercase = mimeType.lowercaseString;
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[self getAlbum] options:nil];
    if (assets.count == 0) {
        return ctxArr;
    }
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset) {
            DPChromecastMediaContext *ctx = [DPChromecastMediaContext contextWithPHAsset:asset];
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
    
    return ctxArr;
}

- (PHAssetCollection *)getAlbum {
    PHFetchResult *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                               subtype:PHAssetCollectionSubtypeSmartAlbumVideos
                                                                               options:nil];
    if (assetCollections.count == 0) {
        return nil;
    }
    __block PHAssetCollection * myAlbum;
    [assetCollections enumerateObjectsUsingBlock:^(PHAssetCollection *album, NSUInteger idx, BOOL *stop) {
        if ([album.localizedTitle isEqualToString:@"Videos"]) {
            myAlbum = album;
            *stop = YES;
        }
    }];
    
    return myAlbum;
}


// 共通リクエスト処理
- (BOOL)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             serviceId:(NSString *)serviceId
             callback:(void(^)(void))callback
{
    // パラメータチェック
    if (serviceId == nil) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    // 接続＆メッセージクリア
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr connectToDeviceWithID:serviceId completion:^(BOOL success, NSString *error) {
        if (success) {
            if (callback) {
                callback();
            }
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            // エラー
            [response setErrorToNotFoundService];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    return NO;
}



- (void)saveMovie:(DPChromecastMediaContext *)ctx
              callback:(void (^)(NSString* url))callback
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *formattedDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [@"dConnectDeviceChromecastMovie_" stringByAppendingFormat:@"%@.MOV", formattedDateString];
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:fileName];
    __block NSFileManager *fileManager = [NSFileManager defaultManager];
    __block NSString* url = [@"http://" stringByAppendingFormat:@"%@/%@",
                                 [[DPChromecastManager sharedManager] getIPString],
                                 fileName];
    PHFetchResult *fetch = [PHAsset fetchAssetsWithLocalIdentifiers:@[ctx.mediaId] options:nil];
    if (fetch.count == 0) {
        callback(nil);
        return;
    }
    __block NSMutableArray *assets = [NSMutableArray array];
    [fetch enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        [assets addObject:asset];
    }];
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    [[PHImageManager defaultManager] requestExportSessionForVideo:assets.firstObject
                                                          options:options exportPreset:AVAssetExportPresetLowQuality
                                                    resultHandler:^(AVAssetExportSession * exportSession, NSDictionary * info) {
                                                        exportSession.outputURL = [NSURL fileURLWithPath:dataPath];
                                                        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
                                                        [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                                            switch ([exportSession status]) {
                                                                case AVAssetExportSessionStatusCompleted: {
                                                                    NSData *compressedData = [NSData dataWithContentsOfURL:exportSession.outputURL];
                                                                    BOOL success = [fileManager fileExistsAtPath:dataPath];
                                                                    if (success) {
                                                                        compressedData = [NSData dataWithContentsOfFile:dataPath];
                                                                    } else {
                                                                        [compressedData writeToFile:dataPath atomically:YES];
                                                                    }
                                                                    callback(url);
                                                                    return;
                                                                }
                                                                case AVAssetExportSessionStatusFailed: {
                                                                    break;
                                                                }
                                                                case AVAssetExportSessionStatusCancelled: {
                                                                    break;
                                                                }
                                                                default: {
                                                                }
                                                                    callback(nil);
                                                            }
                                                            
                                                        }];
                                                        
    }];
}


#pragma mark - Private Methods

- (void)checkOrder:(NSString **)sortOrder
        sortTarget:(NSString **)sortTarget
          response:(DConnectResponseMessage *)response
             order:(NSArray *)order
{
    
    
    if (order) {
        *sortTarget = order[0];
        if (order.count >= 2) {
            *sortOrder = order[1];
            
            if (!(*sortTarget) || !(*sortOrder)) {
                [response setErrorToInvalidRequestParameterWithMessage:@"order is invalid."];
            }
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
            return [(DPChromecastMediaContext *)obj mediaId];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamMIMEType]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj mimeType];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamTitle]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj title];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamType]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj type];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamLanguage]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj language];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamDescription]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj description];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 localizedCaseInsensitiveCompare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamDuration]) {
        accessor = ^id(id obj) {
            return [(DPChromecastMediaContext *)obj duration];
        };
        innerComp = ^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare: obj2];
        };
    } else if ([sortTarget isEqualToString:DConnectMediaPlayerProfileParamImageURI]) {
        accessor = ^id(id obj) {
            return[(DPChromecastMediaContext *)obj imageUri].absoluteString;
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



#pragma mark - Event

// 共通イベントリクエスト処理
- (void)handleEventRequest:(DConnectRequestMessage *)request
				  response:(DConnectResponseMessage *)response
				  isRemove:(BOOL)isRemove
				  callback:(void(^)(void))callback
{
	DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPChromecastDevicePlugin class]];
	DConnectEventError error;
	if (isRemove) {
		error = [mgr removeEventForRequest:request];
	} else {
		error = [mgr addEventForRequest:request];
	}
	switch (error) {
		case DConnectEventErrorNone:
			[response setResult:DConnectMessageResultTypeOk];
			callback();
			break;
		case DConnectEventErrorInvalidParameter:
			[response setErrorToInvalidRequestParameter];
			break;
		case DConnectEventErrorFailed:
		case DConnectEventErrorNotFound:
		default:
			[response setErrorToUnknown];
			break;
	}
}


// イベント追加
- (void) addMediaEvent:(NSString *)serviceId
{
	__block DConnectDevicePlugin *_self = (DConnectDevicePlugin *)self.plugin;
	
	DConnectEventManager *evtMgr = [DConnectEventManager sharedManagerForClass:[DPChromecastDevicePlugin class]];
	
	[[DPChromecastManager sharedManager] setEventCallbackWithID:serviceId callback:^(NSString *mediaID) {
		DPChromecastManager *mgr = [DPChromecastManager sharedManager];
        DConnectMessage *message = [DConnectMessage message];
		[DConnectMediaPlayerProfile setMediaId:mediaID target:message];
		[DConnectMediaPlayerProfile setMIMEType:@"video/quicktime" target:message];
		[DConnectMediaPlayerProfile setStatus:[mgr mediaPlayerStateWithID:serviceId] target:message];
		[DConnectMediaPlayerProfile setPos:[mgr streamPositionWithID:serviceId] target:message];
		[DConnectMediaPlayerProfile setVolume:[mgr volumeWithID:serviceId] target:message];
		
		NSArray *evts = [evtMgr eventListForServiceId:serviceId
											 profile:DConnectMediaPlayerProfileName
										   attribute:DConnectMediaPlayerProfileAttrOnStatusChange];
		for (DConnectEvent *evt in evts) {
			DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
			[DConnectMediaPlayerProfile setMediaPlayer:message target:eventMsg];
			[_self sendEvent:eventMsg];
		}
	}];
}


@end
