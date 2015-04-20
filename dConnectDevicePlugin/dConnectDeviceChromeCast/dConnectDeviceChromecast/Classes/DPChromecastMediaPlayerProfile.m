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


@interface DPChromecastMediaPlayerProfile()
/// アセットライブラリ検索用のロック
@property NSObject *lockAssetsLibraryQuerying;
@property ALAssetsLibrary *library;
@end

@implementation DPChromecastMediaPlayerProfile

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        _library = [ALAssetsLibrary new];
    }
    return self;
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
                         DPChromecastMediaContext *ctx = [DPChromecastMediaContext contextWithAsset:result];
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
//                         if (mimeType) {
//                             NSRange result = [ctx.mimeType rangeOfString:mimeTypeLowercase];
//                             if (result.location == NSNotFound && result.length == 0) {
//                                 // MIMEタイプにマッチせず；スキップ。
//                                 return;
//                             }
//                         }
                         
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



// 共通リクエスト処理
- (BOOL)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             serviceId:(NSString *)serviceId
             callback:(void(^)())callback
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

    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:ctx.media
                                                               presetName:AVAssetExportPresetLowQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:dataPath];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([exportSession status]) {
            case AVAssetExportSessionStatusCompleted:
            {
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
            case AVAssetExportSessionStatusFailed:
            {
                break;
            }
            case AVAssetExportSessionStatusCancelled:
            {
                break;
            }
            default:
            {
                break;
            }
            callback(nil);
        }
        
    }];
    
}


#pragma mark - Get Methods

// 再生状態取得リクエストを受け取った
- (BOOL)               profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetPlayStatusRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // 再生状態取得
                NSString *status = [[DPChromecastManager sharedManager] mediaPlayerStateWithID:serviceId];
                [response setString:status forKey:@"status"];
            }];
}

// コンテンツ情報取得リクエストを受け取った
- (BOOL)          profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetMediaRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
                  mediaId:(NSString *)mediaId
{
    if (!mediaId) {
        [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
        return YES;
    }
    
    if ([mediaId isEqualToString:
         @"https://github.com/DeviceConnect/DeviceConnect-Android/wiki/sphero_demo.MOV"]) {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectMediaPlayerProfile setMIMEType:@"video/quicktime" target:response];
        [DConnectMediaPlayerProfile setTitle:@"Title: Sample" target:response];
        [DConnectMediaPlayerProfile setLanguage:@"ja" target:response];
        [DConnectMediaPlayerProfile setDescription:@"Sample Movie" target:response];
        [DConnectMediaPlayerProfile setDuration:9999 target:response];

    } else {
        NSURL *url = [NSURL URLWithString:mediaId];
        DPChromecastMediaContext *ctx = [DPChromecastMediaContext contextWithURL:url];
        if (ctx.media) {
            [ctx setVariousMetadataToMessage:response omitMediaId:YES];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToUnknownWithMessage:@"Failed to obtain a media context."];
        }
    }
    
    return YES;
}


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


// コンテンツ情報取得リクエストを受け取った
- (BOOL)              profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetMediaListRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                        query:(NSString *)query
                     mimeType:(NSString *)mimeType
                        order:(NSArray *)order
                       offset:(NSNumber *)offset
                        limit:(NSNumber *)limit
{
    NSString *sortTarget;
    NSString *sortOrder;
    [self checkOrder:&sortOrder sortTarget:&sortTarget response:response order:order];
    if ([response integerForKey:DConnectMessageResult] == DConnectMessageResultTypeError) {
        return YES;
    }
    NSComparator comp;
    [self compareOrderWithResponse:response sortTarget:sortTarget sortOrder:sortOrder comparator:&comp];
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
        sampleCtx.mediaId = @"https://github.com/DeviceConnect/DeviceConnect-Android/wiki/sphero_demo.MOV";
        sampleCtx.mimeType = @"video/quicktime";
        sampleCtx.title = @"Title: Sample";
        sampleCtx.duration = @(9999);
        sampleCtx.language = @"ja";
        sampleCtx.desc = @"Sample Movie";
        NSMutableArray *ctxArr = [NSMutableArray array];
        [ctxArr addObject:sampleCtx];
        [ctxArr addObjectsFromArray:[self contextsBySearchingAssetsLibraryWithQuery:query mimeType:mimeType]];
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
    
    return [self handleRequest:request
                      response:response
                     serviceId:serviceId
                      callback:nil];
}

// 再生位置取得リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetSeekRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // 再生位置取得
                NSTimeInterval pos = [[DPChromecastManager sharedManager] streamPositionWithID:serviceId];
                [response setDouble:pos forKey:@"pos"];
            }];
}

// メディアプレーヤーの音量取得リクエストを受け取った
- (BOOL)           profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetVolumeRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // 音量取得
                float vol = [[DPChromecastManager sharedManager] volumeWithID:serviceId];
                [response setDouble:vol forKey:@"volume"];
            }];
}

// メディアプレーヤーミュート状態取得リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceiveGetMuteRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // ミュート状態取得
                BOOL mute = [[DPChromecastManager sharedManager] isMutedWithID:serviceId];

                [response setBool:mute forKey:@"mute"];
            }];
}


#pragma mark - Put Methods

// 再生コンテンツ変更リクエストを受け取った
- (BOOL)            profile:(DConnectMediaPlayerProfile *)profile
  didReceivePutMediaRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                    mediaId:(NSString *)mediaId
{
    if (!mediaId) {
        [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
        return YES;
    }
    if ([mediaId isEqualToString:
         @"https://github.com/DeviceConnect/DeviceConnect-Android/wiki/sphero_demo.MOV"]) {
        return [self handleRequest:request
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
        if (!ctx.media) {
            [response setErrorToInvalidRequestParameterWithMessage:@"mediaId must be specified."];
            return YES;
        }
        DPChromecastManager *mgr = [DPChromecastManager sharedManager];
        [mgr connectToDeviceWithID:serviceId completion:^(BOOL success, NSString *error) {
            if (success) {
                [self saveMovie:ctx
                       callback:^(NSString *url) {
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
}

// 再生開始リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceivePutPlayRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
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
}

// 再生停止リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceivePutStopRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{

    
    // リクエスト処理
    return [self handleRequest:request
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
}

// 再生一時停止リクエストを受け取った
- (BOOL)          profile:(DConnectMediaPlayerProfile *)profile
didReceivePutPauseRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
{
    
    // リクエスト処理
    return [self handleRequest:request
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
}

// 再生再開リクエストを受け取った
- (BOOL)           profile:(DConnectMediaPlayerProfile *)profile
didReceivePutResumeRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
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
}

// 再生位置変更リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceivePutSeekRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
                     pos:(NSNumber *)pos
{
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
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // 再生位置変更
                [[DPChromecastManager sharedManager] setStreamPositionWithID:serviceId position:[pos doubleValue]];
            }];
}

// メディアプレーヤーの音量変更リクエストを受け取った
- (BOOL)           profile:(DConnectMediaPlayerProfile *)profile
didReceivePutVolumeRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    volume:(NSNumber *)volume
{
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
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // 音量変更
                [[DPChromecastManager sharedManager] setVolumeWithID:serviceId volume:vol];
            }];
}

// メディアプレーヤーミュート有効化リクエストを受け取った
- (BOOL)         profile:(DConnectMediaPlayerProfile *)profile
didReceivePutMuteRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // ミュート有効化
                [[DPChromecastManager sharedManager] setIsMutedWithID:serviceId muted:YES];
            }];
}


#pragma mark - Delete Methods

// メディアプレーヤーミュート無効化リクエストを受け取った
- (BOOL)            profile:(DConnectMediaPlayerProfile *)profile
didReceiveDeleteMuteRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // ミュート無効化
				[[DPChromecastManager sharedManager] setIsMutedWithID:serviceId muted:NO];
            }];
}


#pragma mark - Event

// 共通イベントリクエスト処理
- (void)handleEventRequest:(DConnectRequestMessage *)request
				  response:(DConnectResponseMessage *)response
				  isRemove:(BOOL)isRemove
				  callback:(void(^)())callback
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

// onstatuschangeイベント登録リクエストを受け取った
- (BOOL)                   profile:(DConnectMediaPlayerProfile *)profile
didReceivePutOnStatusChangeRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
                        sessionKey:(NSString *)sessionkey
{
	[self handleEventRequest:request response:response isRemove:NO callback:^{
		[self addMediaEvent:serviceId];
	}];
    return YES;
}

// イベント追加
- (void) addMediaEvent:(NSString *)serviceId
{
	__block DConnectDevicePlugin *_self = (DConnectDevicePlugin *)self.provider;
	
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

// onstatuschangeイベント解除リクエストを受け取った
- (BOOL)                      profile:(DConnectMediaPlayerProfile *)profile
didReceiveDeleteOnStatusChangeRequest:(DConnectRequestMessage *)request
                             response:(DConnectResponseMessage *)response
                             serviceId:(NSString *)serviceId
                           sessionKey:(NSString *)sessionkey
{
	// DConnectイベント削除
	[self handleEventRequest:request response:response isRemove:YES callback:^{
	}];
    return YES;
}
 

@end
