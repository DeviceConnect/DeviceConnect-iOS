//
//  DPHostMediaContext.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <ImageIO/CGImageProperties.h>
#import <MediaPlayer/MediaPlayer.h>

#import "DPHostMediaContext.h"

NSString *MediaContextMediaIdSchemeIPodAudio = @"ipod-audio";
NSString *MediaContextMediaIdSchemeIPodMovie = @"ipod-movie";
NSString *MediaContextMediaIdSchemeIPodLibrary = @"ipod-library";
NSString *MediaContextMediaIdSchemeFile = @"file";

const MPMediaType TargetMPMediaType = MPMediaTypeMusic | MPMediaTypeHomeVideo;

static NSUInteger contextCacheCountMax = 100000;
static NSMutableArray *contextCacheKey;
static NSMutableArray *contextCacheVal;

@interface DPHostMediaContext ()

- (void) cache;

+ (DPHostMediaContext *) findContextWithMediaId:(NSString *)mediaId;

@end

@implementation DPHostMediaContext

+ (void)initialize
{
    if (self == [DPHostMediaContext class]) {
        contextCacheKey = [NSMutableArray array];
        contextCacheVal = [NSMutableArray array];
    }
}

- (void) cache
{
    if (![DPHostMediaContext findContextWithMediaId:_mediaId]) {
        if (contextCacheKey.count == contextCacheCountMax) {
            // 最大キャッシュ数に達していたら先頭の項目を消す。
            [contextCacheKey removeObjectAtIndex:0];
            [contextCacheVal removeObjectAtIndex:0];
        }
        
        // 末尾に追加する。
        [contextCacheKey addObject:_mediaId];
        [contextCacheVal addObject:self];
    }
}

+ (DPHostMediaContext *) findContextWithMediaId:(NSString *)mediaId
{
    NSUInteger index = [contextCacheKey indexOfObject:mediaId];
    if (index != NSNotFound) {
        return contextCacheVal[index];
    }
    return nil;
}

+ (NSNumber *) persistentIdWithMediaIdURL:(NSURL *)mediaIdURL
{
    NSString *persistentIdStr = mediaIdURL.resourceSpecifier;
    unsigned long long persistentIdTmp;
    if (![[NSScanner scannerWithString:persistentIdStr] scanUnsignedLongLong:&persistentIdTmp]) {
        return nil;
    }
    return [NSNumber numberWithUnsignedLongLong:persistentIdTmp];
}

+ (instancetype)contextWithURL:(NSURL *)url {
    __block DPHostMediaContext *ctx;
    if (!url) {
        return nil;
    }
    if ((ctx = [DPHostMediaContext findContextWithMediaId:url.absoluteString])) {
        // キャッシュにヒット；キャッシュを返却する。
        return ctx;
    }
    if (!url.scheme) {
        PHFetchResult *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[url.absoluteString] options:nil];
        if (assets.count == 0) {
            return nil;
        }
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        // 30秒経ったらタイムアウト
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
        [assets enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
            ctx = [DPHostMediaContext contextWithPHAsset:asset];
            dispatch_semaphore_signal(semaphore);
        }];
        // ライブラリのクエリー（非同期）が終わる、もしくはタイムアウトするまで待つ
        dispatch_semaphore_wait(semaphore, timeout);
    } else if ([url.scheme isEqualToString:MediaContextMediaIdSchemeFile]) {
        ctx = [self new];
        if (ctx) {
            // iPodプレイヤーで再生させない
            ctx.useIPodPlayer = NO;
            
            // ===== type =====
            NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:url.pathExtension];
            if ([mimeType hasPrefix:@"audio"]) {
                ctx.type = @"Audio";
                ctx.isAudio = YES;
            } else if ([mimeType hasPrefix:@"video"]) {
                ctx.type = @"Movie";
                ctx.isAudio = NO;
            } else {
                // タイプが写真・不明なものは取り扱わない。
                return nil;
            }
            ctx.title = url.lastPathComponent;
            ctx.duration = 0;
            ctx.mediaId = url.absoluteString;
        }
    } else if ([url.scheme isEqualToString:MediaContextMediaIdSchemeIPodAudio]
        || [url.scheme isEqualToString:MediaContextMediaIdSchemeIPodMovie]) {
        NSNumber *persistentId = [DPHostMediaContext persistentIdWithMediaIdURL:url];
        if (persistentId) {
            return nil;
        }
        MPMediaQuery *mediaQuery = [MPMediaQuery new];
        [mediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:TargetMPMediaType]
                                          forProperty:MPMediaItemPropertyMediaType]];
        [mediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:persistentId
                                          forProperty:MPMediaItemPropertyPersistentID]];
        NSArray *items = [mediaQuery items];
        
        MPMediaItem *mediaItem;
        if (items.count != 0) {
            mediaItem = items[0];
        } else {
            return nil;
        }
        
        ctx = [DPHostMediaContext contextWithMediaItem:mediaItem];
    } else if ([url.scheme isEqualToString:MediaContextMediaIdSchemeIPodLibrary]) {
        // ipod-library:スキームのidはPersistentIdなので、それを取得する。
        NSNumber *persistentId = nil;
        for (NSString *keyValStr in [url.query componentsSeparatedByString:@"&"]) {
            NSArray *keyValArr = [keyValStr componentsSeparatedByString:@"="];
            if (keyValArr.count != 2) {
                continue;
            }
            if ([keyValArr[0] isEqualToString:@"id"]) {
                unsigned long long persistentIdTmp;
                if (![[NSScanner scannerWithString:keyValArr[1]] scanUnsignedLongLong:&persistentIdTmp]) {
                    continue;
                }
                persistentId = @(persistentIdTmp);
                break;
            }
        }
        if (!persistentId) {
            return nil;
        }
        
        MPMediaQuery *mediaQuery = [MPMediaQuery new];
        [mediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:TargetMPMediaType]
                                          forProperty:MPMediaItemPropertyMediaType]];
        [mediaQuery addFilterPredicate:
         [MPMediaPropertyPredicate predicateWithValue:persistentId
                                          forProperty:MPMediaItemPropertyPersistentID]];
        NSArray *items = [mediaQuery items];
        
        MPMediaItem *mediaItem;
        if (items.count != 0) {
            mediaItem = items[0];
        } else {
            return nil;
        }
        
        ctx = [DPHostMediaContext contextWithMediaItem:mediaItem];
    }
    
    return ctx;
}



+ (void)checkParameterWithPHAsset:(PHAsset *)asset
                        context:(DPHostMediaContext *)context
{
    
    // ===== title =====
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    __block NSURL *u = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    // 30秒経ったらタイムアウト
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 30);
    [[PHImageManager defaultManager] requestPlayerItemForVideo:asset
                                                       options:options
                                                 resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
                                                     // ===== mediaId =====
                                                     context.mediaId = asset.localIdentifier;
                                                     
                                                     // ===== mimeType =====
                                                     NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:@"mp4"];
                                                     if (!mimeType) {
                                                         mimeType = [DConnectFileManager mimeTypeForArbitraryData];
                                                     }
                                                     context.mimeType = mimeType;
                                                     NSString *token = info[@"PHImageFileSandboxExtensionTokenKey"];
                                                     NSArray *tokenKeys = [token componentsSeparatedByString:@";"];
                                                     NSString * url = [tokenKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF contains[c] '/private/var/mobile/Media'"]].firstObject;
                                                     u = [NSURL URLWithString:url];
                                                     context.title = @"NO Title";
                                                     if (u) {
                                                         context.title = u.lastPathComponent;
                                                     }
                                                     context.duration = @(asset.duration);
                                                     dispatch_semaphore_signal(semaphore);
                                                 }];
    
    // ライブラリのクエリー（非同期）が終わる、もしくはタイムアウトするまで待つ
    dispatch_semaphore_wait(semaphore, timeout);
}


+ (instancetype)contextWithPHAsset:(PHAsset *)asset
{
    if (!asset) {
        return nil;
    }
    DPHostMediaContext *instance = [self new];
    if (instance) {
        // iPodプレイヤーで再生させない
        instance.useIPodPlayer = NO;
        
        // ===== type =====
        PHAssetMediaType type = asset.mediaType;
        if (type == PHAssetMediaTypeImage || type == PHAssetMediaTypeUnknown) {
            // タイプが写真・不明なものは取り扱わない。
            return nil;
        } else if (type == PHAssetMediaTypeAudio) {
            instance.type = @"Audio";
            instance.isAudio = YES;
        } else if (type == PHAssetMediaTypeVideo) {
            instance.type = @"Movie";
            instance.isAudio = NO;
        }
        
        NSString *localIdentifier = asset.localIdentifier;
        if (!localIdentifier) {
            return nil;
        }
        
        [self checkParameterWithPHAsset:asset context:instance];
    }
    
    // キャッシュする。
    [instance cache];
    return instance;
}
+ (instancetype)contextWithMediaItem:(MPMediaItem *)mediaItem
{
    if (!mediaItem) {
        return nil;
    }
    
    DPHostMediaContext *instance = [self new];
    
    if (instance) {
        // iPodプレイヤーで再生させる
        instance.useIPodPlayer = YES;
        
        NSNumber *persistentId = [mediaItem valueForProperty:MPMediaItemPropertyPersistentID];
        if (!persistentId) {
            return nil;
        }
        
        NSInteger type = [[mediaItem valueForProperty:MPMediaItemPropertyMediaType] integerValue];
        if ((type & MPMediaTypeAnyVideo) != 0) {
            instance.isAudio = NO;
            instance.type = @"Movie";
            instance.mediaId =
            [NSString stringWithFormat:@"%@:%llu",
             MediaContextMediaIdSchemeIPodMovie, persistentId.unsignedLongLongValue];
        } else if ((type & MPMediaTypeAnyAudio) != 0) {
            instance.isAudio = YES;
            instance.type = @"Audio";
            instance.mediaId =
            [NSString stringWithFormat:@"%@:%llu",
             MediaContextMediaIdSchemeIPodAudio, persistentId.unsignedLongLongValue];
        } else {
            // ????
            return nil;
        }
        
        NSURL *url = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
        NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:url.path.pathExtension];
        if (!mimeType) {
            mimeType = [DConnectFileManager mimeTypeForArbitraryData];
        }
        instance.mimeType = mimeType;
        
        instance.title = [mediaItem valueForProperty:MPMediaItemPropertyTitle];

        instance.duration = [mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
        
        instance.desc = [mediaItem valueForProperty:MPMediaItemPropertyComments];
        
        NSString *creator = [mediaItem valueForProperty:MPMediaItemPropertyArtist];
        if (creator) {
            DConnectArray *creators = [DConnectArray array];
            DConnectMessage *message = [DConnectMessage message];
            [DConnectMediaPlayerProfile setCreator:creator target:message];
            [DConnectMediaPlayerProfile setRole:@"Artist" target:message];
            [creators addMessage:message];
            instance.creators = creators;
        }
    }
    
    // キャッシュする。
    [instance cache];
    
    return instance;
}

- (void) setVariousMetadataToMessage:(DConnectMessage *)message omitMediaId:(BOOL)omitMediaId
{
    if (_mediaId && !omitMediaId) {
        [DConnectMediaPlayerProfile setMediaId:_mediaId target:message];
    }
    if (_mimeType) {
        [DConnectMediaPlayerProfile setMIMEType:_mimeType target:message];
    }
    if (_title) {
        [DConnectMediaPlayerProfile setTitle:_title target:message];
    }
    if (_type) {
        [DConnectMediaPlayerProfile setType:_type target:message];
    }
    if (_language) {
        [DConnectMediaPlayerProfile setLanguage:_language target:message];
    }
    if (_desc) {
        [DConnectMediaPlayerProfile setDescription:_desc target:message];
    }
    if (_imageUri) {
        [DConnectMediaPlayerProfile setImageUri:_imageUri.absoluteString target:message];
    }
    if (_duration) {
        [DConnectMediaPlayerProfile setDuration:_duration.intValue target:message];
    }
    if (_creators) {
        [DConnectMediaPlayerProfile setCreators:_creators target:message];
    }
    if (_keywords) {
        [DConnectMediaPlayerProfile setKeywords:_keywords target:message];
    }
    if (_genres) {
        [DConnectMediaPlayerProfile setGenres:_genres target:message];
    }
}

@end
