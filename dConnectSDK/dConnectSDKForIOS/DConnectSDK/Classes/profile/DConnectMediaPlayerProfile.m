//
//  DConnectMediaStreamsPlayProfile.m
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

@interface DConnectMediaPlayerProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectMediaPlayerProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectMediaPlayerProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = request.attribute;
    
    if (attribute) {
        
        NSString *serviceId = request.serviceId;
        
        if ([self isEqualToAttribute:DConnectMediaPlayerProfileAttrMedia cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetMediaRequest:response:serviceId:mediaId:)
                       response:response])
            {
                NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
                send = [_delegate profile:self didReceiveGetMediaRequest:request
                                 response:response serviceId:serviceId mediaId:mediaId];
            }
        } else if ([self isEqualToAttribute:DConnectMediaPlayerProfileAttrMediaList cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetMediaListRequest:response:
                                          serviceId:query:mimeType:order:offset:limit:)
                       response:response])
            {
                NSString *query = [DConnectMediaPlayerProfile queryFromRequest:request];
                NSString *mimeType = [DConnectMediaPlayerProfile mimeTypeFromRequest:request];
                NSString *orderStr = [DConnectMediaPlayerProfile orderFromRequest:request];
                NSArray *order = nil;
                if (orderStr) {
                    order = [orderStr componentsSeparatedByString:@","];
                }
                NSNumber *offset = [DConnectMediaPlayerProfile offsetFromRequest:request];
                NSNumber *limit = [DConnectMediaPlayerProfile limitFromRequest:request];
                send = [_delegate profile:self didReceiveGetMediaListRequest:request response:response
                                 serviceId:serviceId query:query mimeType:mimeType order:order
                                   offset:offset limit:limit];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrPlayStatus cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetPlayStatusRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveGetPlayStatusRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrSeek cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetSeekRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveGetSeekRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrVolume cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetVolumeRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveGetVolumeRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrMute cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveGetMuteRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveGetMuteRequest:request
                                 response:response serviceId:serviceId];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = request.attribute;
    
    if (attribute) {
        
        NSString *serviceId = request.serviceId;
        
        if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrMedia cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutMediaRequest:response:serviceId:mediaId:)
                response:response])
            {
                NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
                send = [_delegate profile:self didReceivePutMediaRequest:request response:response
                                 serviceId:serviceId mediaId:mediaId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrPlay cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutPlayRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutPlayRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrStop cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutStopRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutStopRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrPause cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutPauseRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutPauseRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrResume cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutResumeRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutResumeRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrSeek cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutSeekRequest:response:serviceId:pos:)
                       response:response])
            {
                NSNumber *pos = [DConnectMediaPlayerProfile posFromRequest:request];
                send = [_delegate profile:self didReceivePutSeekRequest:request
                                 response:response serviceId:serviceId pos:pos];
                
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrVolume cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutVolumeRequest:response:serviceId:volume:)
                       response:response])
            {
                NSNumber *volume = [DConnectMediaPlayerProfile volumeFromRequest:request];
                send = [_delegate profile:self didReceivePutVolumeRequest:request response:response
                                 serviceId:serviceId volume:volume];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrMute cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutMuteRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutMuteRequest:request
                                 response:response serviceId:serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrOnStatusChange cmp: attribute]) {
            if ([self hasMethod:@selector(profile:didReceivePutOnStatusChangeRequest:response:
                                          serviceId:sessionKey:) response:response])
            {
                send = [_delegate profile:self didReceivePutOnStatusChangeRequest:request
                                 response:response
                                 serviceId:serviceId
                               sessionKey:request.sessionKey];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
        
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = request.attribute;
    
    if (attribute) {
        if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrMute cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveDeleteMuteRequest:response:serviceId:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveDeleteMuteRequest:request response:response
                                 serviceId:request.serviceId];
            }
        } else if ([self isEqualToAttribute: DConnectMediaPlayerProfileAttrOnStatusChange cmp:attribute]) {
            if ([self hasMethod:@selector(profile:didReceiveDeleteOnStatusChangeRequest:
                                          response:serviceId:sessionKey:) response:response])
            {
                send = [_delegate profile:self didReceiveDeleteOnStatusChangeRequest:request response:response
                                 serviceId:request.serviceId sessionKey:request.sessionKey];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
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

#pragma mark - Utility

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
