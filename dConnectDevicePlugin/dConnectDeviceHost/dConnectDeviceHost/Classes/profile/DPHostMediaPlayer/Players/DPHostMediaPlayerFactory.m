//
//  DPHostMediaPlayerFactory.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <ImageIO/CGImageProperties.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DPHostMediaPlayerFactory.h"
#import "DPHostIPodAudioPlayer.h"
#import "DPHostMoviePlayer.h"
#import "DPHostUtils.h"
#import <Photos/Photos.h>

@implementation DPHostMediaPlayerFactory
+ (DPHostMediaPlayer*)createPlayerWithMediaId:(NSString *)mediaId plugin:(DPHostDevicePlugin *)plugin error:(NSError **)error
{
    NSURL *url = [NSURL URLWithString:mediaId];
    DPHostMediaPlayer *player = nil;
    DPHostMediaContext *ctx = [DPHostMediaContext contextWithURL:url];
    if (!ctx) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"MediaId is Invalid"];
        return nil;
    }
    BOOL isIPodAudioMedia = [url.scheme isEqualToString:MediaContextMediaIdSchemeIPodAudio];
    if (isIPodAudioMedia) {
        player = [[DPHostIPodAudioPlayer alloc] initWithMediaContext:ctx plugin:plugin error:error];
    } else {
        player = [[DPHostMoviePlayer alloc] initWithMediaContext:ctx plugin:plugin error:error];
    }
    return player;
}

+ (NSArray*)searchMediaWithQuery:(NSString *)query
                        mimeType:(NSString *)mimeType
                           order:(NSString *)order
                          offset:(NSNumber *)offset
                           limit:(NSNumber *)limit
                           error:(NSError**)error
{
    NSString *sortTarget;
    NSString *sortOrder;
    NSArray *orders = nil;

    if (order) {
        orders = [order componentsSeparatedByString:@","];
    }
    [self checkOrder:&sortOrder
          sortTarget:&sortTarget
               order:orders
               error:error];
    if (*error) {
        return nil;
    }
    NSComparator comp;
    [self compareOrderWithSortTarget:sortTarget sortOrder:sortOrder comparator:&comp error:error];
    if (*error) {
        return nil;
    }
    
    if (offset && offset.integerValue < 0) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"offset must be a non-negative value."];
        return nil;
    }
    if (limit && limit.integerValue < 0) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"limit must be a positive value."];
        return nil;
    }
    NSString *limitString = [limit stringValue];
    NSString *offsetString = [offset stringValue];
    if (![DPHostUtils existDigitWithString:limitString]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter
                                            message:@"limit must be a digit number."];
        return nil;
    }
    if (![DPHostUtils existDigitWithString:offsetString]) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter
                                            message:@"offset must be a digit number."];
        return nil;
    }
    NSMutableArray *ctxArr = [NSMutableArray array];
    [ctxArr addObjectsFromArray:[self contextsBySearchingPhotoLibraryWithQuery:query mimeType:mimeType]];
    [ctxArr addObjectsFromArray:[self contextsBySearchingIPodLibraryWithQuery:query mimeType:mimeType]];
    if (offset && offset.integerValue >= ctxArr.count) {
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter
                                            message:@"offset exceeds the size of the media list."];
        return nil;
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
    return tmpArr.mutableCopy;
}

#pragma mark - Private Method

+ (NSArray *)contextsBySearchingPhotoLibraryWithQuery:(NSString *)query
                                              mimeType:(NSString *)mimeType
{
    __block NSMutableArray *ctxArr = [NSMutableArray new];
    NSString *mimeTypeLowercase = mimeType.lowercaseString;

    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:[DPHostMediaPlayerFactory getAlbum] options:nil];
    if (assets.count == 0) {
        return ctxArr;
    }
    [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset) {
            DPHostMediaContext *ctx = [DPHostMediaContext contextWithPHAsset:asset];
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

+ (PHAssetCollection *)getAlbum {
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


+ (NSArray *)contextsBySearchingIPodLibraryWithQuery:(NSString *)query
                                            mimeType:(NSString *)mimeType
{
    NSMutableArray *ctxArr = [NSMutableArray new];
    
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
    
    return ctxArr.count == 0 ? nil : ctxArr;
}



+ (void)checkOrder:(NSString **)sortOrder
        sortTarget:(NSString **)sortTarget
             order:(NSArray *)order
             error:(NSError**)error
{

    if (order) {
        if (order.count >= 2) {
            *sortTarget = order[0];
            *sortOrder = order[1];
        }
        if (!(*sortTarget) || !(*sortOrder)) {
            *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"order is invalid."];
        }
    } else {
        *sortTarget = DConnectMediaPlayerProfileParamTitle;
        *sortOrder = DConnectMediaPlayerProfileOrderASC;
    }
}

+ (void)compareOrderWithSortTarget:(NSString *)sortTarget
                       sortOrder:(NSString *)sortOrder
                      comparator:(NSComparator *)comparator
                           error:(NSError**)error
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
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"order is invalid."];
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
        *error = [DPHostUtils throwsErrorCode:DConnectMessageErrorCodeInvalidRequestParameter message:@"order is invalid."];
    }
}


@end
