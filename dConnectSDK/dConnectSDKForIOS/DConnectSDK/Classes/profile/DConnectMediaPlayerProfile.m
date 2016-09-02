//
//  DConnectMediaPlayerProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectMediaPlayerProfile.h"

// 属性
NSString *const DConnectMediaPlayerProfileName               = @"mediaPlayer";
NSString *const DConnectMediaPlayerProfileAttrMedia          = @"media";
NSString *const DConnectMediaPlayerProfileAttrMediaList      = @"mediaList";
NSString *const DConnectMediaPlayerProfileAttrVolume         = @"volume";
NSString *const DConnectMediaPlayerProfileAttrPlayStatus     = @"playStatus";
NSString *const DConnectMediaPlayerProfileAttrPlay           = @"play";
NSString *const DConnectMediaPlayerProfileAttrStop           = @"stop";
NSString *const DConnectMediaPlayerProfileAttrPause          = @"pause";
NSString *const DConnectMediaPlayerProfileAttrResume         = @"resume";
NSString *const DConnectMediaPlayerProfileAttrSeek           = @"seek";
NSString *const DConnectMediaPlayerProfileAttrMute           = @"mute";
NSString *const DConnectMediaPlayerProfileAttrOnStatusChange = @"onstatuschange";

// パラメータ
NSString *const DConnectMediaPlayerProfileParamMediaId     = @"mediaId";
NSString *const DConnectMediaPlayerProfileParamMedia       = @"media";
NSString *const DConnectMediaPlayerProfileParamMediaPlayer = @"mediaPlayer";
NSString *const DConnectMediaPlayerProfileParamMIMEType    = @"mimeType";
NSString *const DConnectMediaPlayerProfileParamTitle       = @"title";
NSString *const DConnectMediaPlayerProfileParamType        = @"type";
NSString *const DConnectMediaPlayerProfileParamLanguage    = @"language";
NSString *const DConnectMediaPlayerProfileParamDescription = @"description";
NSString *const DConnectMediaPlayerProfileParamImageURI    = @"imageUri";
NSString *const DConnectMediaPlayerProfileParamDuration    = @"duration";
NSString *const DConnectMediaPlayerProfileParamCreators    = @"creators";
NSString *const DConnectMediaPlayerProfileParamCreator     = @"creator";
NSString *const DConnectMediaPlayerProfileParamRole        = @"role";
NSString *const DConnectMediaPlayerProfileParamKeywords    = @"keywords";
NSString *const DConnectMediaPlayerProfileParamGenres      = @"genres";
NSString *const DConnectMediaPlayerProfileParamQuery       = @"query";
NSString *const DConnectMediaPlayerProfileParamOrder       = @"order";
NSString *const DConnectMediaPlayerProfileParamOffset      = @"offset";
NSString *const DConnectMediaPlayerProfileParamLimit       = @"limit";
NSString *const DConnectMediaPlayerProfileParamCount       = @"count";
NSString *const DConnectMediaPlayerProfileParamStatus      = @"status";
NSString *const DConnectMediaPlayerProfileParamPos         = @"pos";
NSString *const DConnectMediaPlayerProfileParamVolume      = @"volume";
NSString *const DConnectMediaPlayerProfileParamMute        = @"mute";

// 定数値
// 状態定数
NSString *const DConnectMediaPlayerProfileStatusPlay     = @"play";
NSString *const DConnectMediaPlayerProfileStatusStop     = @"stop";
NSString *const DConnectMediaPlayerProfileStatusPause    = @"pause";
NSString *const DConnectMediaPlayerProfileStatusResume   = @"resume";
NSString *const DConnectMediaPlayerProfileStatusMute     = @"mute";
NSString *const DConnectMediaPlayerProfileStatusUnmute   = @"unmute";
NSString *const DConnectMediaPlayerProfileStatusMedia    = @"media";
NSString *const DConnectMediaPlayerProfileStatusVolume   = @"volume";
NSString *const DConnectMediaPlayerProfileStatusComplete = @"complete";


// 並び順定数
NSString *const DConnectMediaPlayerProfileOrderASC  = @"asc";
NSString *const DConnectMediaPlayerProfileOrderDESC = @"desc";

@implementation DConnectMediaPlayerProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectMediaPlayerProfileName;
}

#pragma mark - Setter

+ (void) setCount:(int)count target:(DConnectMessage *)message {
    [message setInteger:count forKey:DConnectMediaPlayerProfileParamCount];
}

+ (void) setMediaId:(NSString *)mediaId target:(DConnectMessage *)message {
    [message setString:mediaId forKey:DConnectMediaPlayerProfileParamMediaId];
}

+ (void) setMedia:(DConnectArray *)media target:(DConnectMessage *)message {
    [message setArray:media forKey:DConnectMediaPlayerProfileParamMedia];
}

+ (void) setMediaPlayer:(DConnectMessage *)mediaPlayer target:(DConnectMessage *)message {
    [message setMessage:mediaPlayer forKey:DConnectMediaPlayerProfileParamMediaPlayer];
}

+ (void) setMute:(BOOL)mute target:(DConnectMessage *)message {
    [message setBool:mute forKey:DConnectMediaPlayerProfileParamMute];
}

+ (void) setStatus:(NSString *)status target:(DConnectMessage *)message {
    [message setString:status forKey:DConnectMediaPlayerProfileParamStatus];
}

+ (void) setPos:(int)pos target:(DConnectMessage *)message {
    [message setInteger:pos forKey:DConnectMediaPlayerProfileParamPos];
}

+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectMediaPlayerProfileParamMIMEType];
}

+ (void) setTitle:(NSString *)title target:(DConnectMessage *)message {
    [message setString:title forKey:DConnectMediaPlayerProfileParamTitle];
}

+ (void) setType:(NSString *)type target:(DConnectMessage *)message {
    [message setString:type forKey:DConnectMediaPlayerProfileParamType];
}

+ (void) setLanguage:(NSString *)language target:(DConnectMessage *)message {
    [message setString:language forKey:DConnectMediaPlayerProfileParamLanguage];
}

+ (void) setImageUri:(NSString *)imageUri target:(DConnectMessage *)message {
    [message setString:imageUri forKey:DConnectMediaPlayerProfileParamImageURI];
}

+ (void) setDescription:(NSString *)description target:(DConnectMessage *)message {
    [message setString:description forKey:DConnectMediaPlayerProfileParamDescription];
}

+ (void) setDuration:(int)duration target:(DConnectMessage *)message {
    [message setInteger:duration forKey:DConnectMediaPlayerProfileParamDuration];
}

+ (void) setCreators:(DConnectArray *)creators target:(DConnectMessage *)message {
    [message setArray:creators forKey:DConnectMediaPlayerProfileParamCreators];
}

+ (void) setCreator:(NSString *)creator target:(DConnectMessage *)message {
    [message setString:creator forKey:DConnectMediaPlayerProfileParamCreator];
}

+ (void) setRole:(NSString *)role target:(DConnectMessage *)message {
    [message setString:role forKey:DConnectMediaPlayerProfileParamRole];
}

+ (void) setKeywords:(DConnectArray *)keywords target:(DConnectMessage *)message {
    [message setArray:keywords forKey:DConnectMediaPlayerProfileParamKeywords];
}

+ (void) setGenres:(DConnectArray *)genres target:(DConnectMessage *)message {
    [message setArray:genres forKey:DConnectMediaPlayerProfileParamGenres];
}

+ (void) setVolume:(double)volume target:(DConnectMessage *)message {
    [message setDouble:volume forKey:DConnectMediaPlayerProfileParamVolume];
}

#pragma mark - Getter

+ (NSString *) mediaIdFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaPlayerProfileParamMediaId];
}

+ (NSNumber *) posFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectMediaPlayerProfileParamPos];
}

+ (NSString *) statusFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaPlayerProfileParamStatus];
}

+ (NSNumber *) volumeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectMediaPlayerProfileParamVolume];
}

+ (NSString *) queryFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaPlayerProfileParamQuery];
}

+ (NSString *) mimeTypeFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaPlayerProfileParamMIMEType];
}

+ (NSString *) orderFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaPlayerProfileParamOrder];
}

+ (NSNumber *) offsetFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectMediaPlayerProfileParamOffset];
}

+ (NSNumber *) limitFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectMediaPlayerProfileParamLimit];
}

@end
