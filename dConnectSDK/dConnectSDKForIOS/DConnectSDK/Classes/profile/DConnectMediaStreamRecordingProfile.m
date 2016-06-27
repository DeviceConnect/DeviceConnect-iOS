//
//  DConnectMediaStreamRecordingProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectMediaStreamRecordingProfile.h"

NSString *const DConnectMediaStreamRecordingProfileName = @"mediastreamRecording";
NSString *const DConnectMediaStreamRecordingProfileAttrMediaRecorder = @"mediarecorder";
NSString *const DConnectMediaStreamRecordingProfileAttrTakePhoto = @"takephoto";
NSString *const DConnectMediaStreamRecordingProfileAttrRecord = @"record";
NSString *const DConnectMediaStreamRecordingProfileAttrPause = @"pause";
NSString *const DConnectMediaStreamRecordingProfileAttrResume = @"resume";
NSString *const DConnectMediaStreamRecordingProfileAttrStop = @"stop";
NSString *const DConnectMediaStreamRecordingProfileAttrMuteTrack = @"mutetrack";
NSString *const DConnectMediaStreamRecordingProfileAttrUnmuteTrack = @"unmutetrack";
NSString *const DConnectMediaStreamRecordingProfileAttrOptions = @"options";
NSString *const DConnectMediaStreamRecordingProfileAttrOnPhoto = @"onphoto";
NSString *const DConnectMediaStreamRecordingProfileAttrOnRecordingChange = @"onrecordingchange";
NSString *const DConnectMediaStreamRecordingProfileAttrOnDataAvailable = @"ondataavailable";
NSString *const DConnectMediaStreamRecordingProfileAttrPreview = @"preview";
NSString *const DConnectMediaStreamRecordingProfileParamRecorders = @"recorders";
NSString *const DConnectMediaStreamRecordingProfileParamId = @"id";
NSString *const DConnectMediaStreamRecordingProfileParamName = @"name";
NSString *const DConnectMediaStreamRecordingProfileParamState = @"state";
NSString *const DConnectMediaStreamRecordingProfileParamImageWidth = @"imageWidth";
NSString *const DConnectMediaStreamRecordingProfileParamImageHeight = @"imageHeight";
NSString *const DConnectMediaStreamRecordingProfileParamMin = @"min";
NSString *const DConnectMediaStreamRecordingProfileParamMax = @"max";
NSString *const DConnectMediaStreamRecordingProfileParamMIMEType = @"mimeType";
NSString *const DConnectMediaStreamRecordingProfileParamConfig = @"config";
NSString *const DConnectMediaStreamRecordingProfileParamTarget = @"target";
NSString *const DConnectMediaStreamRecordingProfileParamMediaId = @"mediaId";
NSString *const DConnectMediaStreamRecordingProfileParamTimeSlice = @"timeslice";
NSString *const DConnectMediaStreamRecordingProfileParamSettings = @"settings";
NSString *const DConnectMediaStreamRecordingProfileParamPhoto = @"photo";
NSString *const DConnectMediaStreamRecordingProfileParamMedia = @"media";
NSString *const DConnectMediaStreamRecordingProfileParamUri = @"uri";
NSString *const DConnectMediaStreamRecordingProfileParamStatus = @"status";
NSString *const DConnectMediaStreamRecordingProfileParamErrorMessage = @"errorMessage";
NSString *const DConnectMediaStreamRecordingProfileParamPath = @"path";

NSString *const DConnectMediaStreamRecordingProfileRecorderStateUnknown = @"Unknown";
NSString *const DConnectMediaStreamRecordingProfileRecorderStateInactive = @"inactive";
NSString *const DConnectMediaStreamRecordingProfileRecorderStateRecording = @"recording";
NSString *const DConnectMediaStreamRecordingProfileRecorderStatePaused = @"paused";

NSString *const DConnectMediaStreamRecordingProfileRecordingStateUnknown = @"Unknown";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateRecording = @"recording";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateStop = @"stop";
NSString *const DConnectMediaStreamRecordingProfileRecordingStatePause = @"pause";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateResume = @"resume";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateMutetrack = @"mutetrack";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateUnmutetrack = @"unmutetrack";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateError = @"error";
NSString *const DConnectMediaStreamRecordingProfileRecordingStateWarning = @"warning";

@interface DConnectMediaStreamRecordingProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectMediaStreamRecordingProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectMediaStreamRecordingProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrMediaRecorder]) {
        if ([self hasMethod:@selector(profile:didReceiveGetMediaRecorderRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveGetMediaRecorderRequest:request
                             response:response serviceId:serviceId];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOptions]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOptionsRequest:response:serviceId:target:)
                   response:response])
        {
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            send = [_delegate profile:self didReceiveGetOptionsRequest:request response:response
                             serviceId:serviceId target:target];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrTakePhoto]) {
        if ([self hasMethod:@selector(profile:didReceivePostTakePhotoRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePostTakePhotoRequest:request
                             response:response serviceId:serviceId target:target];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrRecord]) {
        if ([self hasMethod:@selector(profile:didReceivePostRecordRequest:response:serviceId:target:timeslice:)
                   response:response])
        {
            NSNumber *timeslice = [DConnectMediaStreamRecordingProfile timesliceFromRequest:request];
            send = [_delegate profile:self didReceivePostRecordRequest:request response:response serviceId:serviceId
                               target:target timeslice:timeslice];
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
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrPause]) {
        if ([self hasMethod:@selector(profile:didReceivePutPauseRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutPauseRequest:request
                             response:response serviceId:serviceId target:target];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrResume]) {
        if ([self hasMethod:@selector(profile:didReceivePutResumeRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutResumeRequest:request
                             response:response serviceId:serviceId target:target];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrStop]) {
        if ([self hasMethod:@selector(profile:didReceivePutStopRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutStopRequest:request
                             response:response serviceId:serviceId target:target];
        }
        
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrMuteTrack]) {
        if ([self hasMethod:@selector(profile:didReceivePutMuteTrackRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutMuteTrackRequest:request
                             response:response serviceId:serviceId target:target];
        }
    } else if ([self isEqualToAttribute:attribute cmp:DConnectMediaStreamRecordingProfileAttrUnmuteTrack]) {
        if ([self hasMethod:@selector(profile:didReceivePutUnmuteTrackRequest:response:serviceId:target:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutUnmuteTrackRequest:request
                             response:response serviceId:serviceId target:target];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOptions]) {
        if ([self hasMethod:
             @selector(profile:didReceivePutOptionsRequest:response:serviceId:target:imageWidth:imageHeight:mimeType:)
                   response:response])
        {
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            NSNumber *imageWidth = [DConnectMediaStreamRecordingProfile imageWidthFromRequest:request];
            NSNumber *imageHeight = [DConnectMediaStreamRecordingProfile imageHeightFromRequest:request];
            NSString *mimeType = [DConnectMediaStreamRecordingProfile mimeTypeFromRequest:request];
            send = [_delegate profile:self didReceivePutOptionsRequest:request response:response
                             serviceId:serviceId target:target
                           imageWidth:imageWidth imageHeight:imageHeight
                             mimeType:mimeType];
            
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnPhoto]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnPhotoRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnPhotoRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnRecordingChange]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnRecordingChangeRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnRecordingChangeRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnDataAvailable]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnDataAvailableRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnDataAvailableRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrPreview]) {
        if ([self hasMethod:@selector(profile:didReceivePutPreviewRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutPreviewRequest:request response:response
                            serviceId:serviceId];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnPhoto]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnPhotoRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnPhotoRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }

    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnRecordingChange]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnRecordingChangeRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnRecordingChangeRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrOnDataAvailable]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnDataAvailableRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnDataAvailableRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectMediaStreamRecordingProfileAttrPreview]) {
        if ([self hasMethod:@selector(profile:didReceiveDeletePreviewRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeletePreviewRequest:request response:response
                            serviceId:serviceId];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setRecorderId:(NSString *)cameraId target:(DConnectMessage *)message {
    [message setString:cameraId forKey:DConnectMediaStreamRecordingProfileParamId];
}

+ (void) setRecorderName:(NSString *)name target:(DConnectMessage *)message {
    [message setString:name forKey:DConnectMediaStreamRecordingProfileParamName];
}

+ (void) setRecorderState:(NSString *)state target:(DConnectMessage *)message {
    [message setString:state forKey:DConnectMediaStreamRecordingProfileParamState];
}

+ (void) setRecorderImageWidth:(int)imageWidth target:(DConnectMessage *)message {
    [message setInteger:imageWidth forKey:DConnectMediaStreamRecordingProfileParamImageWidth];
}

+ (void) setRecorderImageHeight:(int)imageHeight target:(DConnectMessage *)message {
    [message setInteger:imageHeight forKey:DConnectMediaStreamRecordingProfileParamImageHeight];
}

+ (void) setRecorderMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectMediaStreamRecordingProfileParamMIMEType];
}

+ (void) setRecorderConfig:(NSString *)config target:(DConnectMessage *)message {
    [message setString:config forKey:DConnectMediaStreamRecordingProfileParamConfig];
}

+ (void) setImageHeight:(DConnectMessage *)imageHeight target:(DConnectMessage *)message {
    [message setMessage:imageHeight forKey:DConnectMediaStreamRecordingProfileParamImageHeight];
}

+ (void) setImageWidth:(DConnectMessage *)imageWidth target:(DConnectMessage *)message {
    [message setMessage:imageWidth forKey:DConnectMediaStreamRecordingProfileParamImageWidth];
}

+ (void) setMin:(int)min target:(DConnectMessage *)message {
    [message setInteger:min forKey:DConnectMediaStreamRecordingProfileParamMin];
}

+ (void) setMax:(int)max target:(DConnectMessage *)message {
    [message setInteger:max forKey:DConnectMediaStreamRecordingProfileParamMax];
}

+ (void) setPath:(NSString *)path target:(DConnectMessage *)message {
    [message setString:path forKey:DConnectMediaStreamRecordingProfileParamPath];
}

+ (void) setPhoto:(DConnectMessage *)photo target:(DConnectMessage *)message {
    [message setMessage:photo forKey:DConnectMediaStreamRecordingProfileParamPhoto];
}

+ (void) setMedia:(DConnectMessage *)media target:(DConnectMessage *)message {
    [message setMessage:media forKey:DConnectMediaStreamRecordingProfileParamMedia];
}

+ (void) setUri:(NSString *)uri target:(DConnectMessage *)message {
    [message setString:uri forKey:DConnectMediaStreamRecordingProfileParamUri];
}

+ (void) setErrorMessage:(NSString *)errorMessage target:(DConnectMessage *)message {
    [message setString:errorMessage forKey:DConnectMediaStreamRecordingProfileParamErrorMessage];
}

+ (void) setStatus:(NSString *)status target:(DConnectMessage *)message {
    [message setString:status forKey:DConnectMediaStreamRecordingProfileParamStatus];
}

+ (void) setMIMEType:(NSString *)mimeType target:(DConnectMessage *)message {
    [message setString:mimeType forKey:DConnectMediaStreamRecordingProfileParamMIMEType];
}

+ (void) setMIMETypes:(DConnectArray *)mimeTypes target:(DConnectMessage *)message {
    [message setArray:mimeTypes forKey:DConnectMediaStreamRecordingProfileParamMIMEType];
}

+ (void) setRecorders:(DConnectArray *)recorders target:(DConnectMessage *)message {
    [message setArray:recorders forKey:DConnectMediaStreamRecordingProfileParamRecorders];
}

#pragma mark - Getter

+ (NSString *) targetFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaStreamRecordingProfileParamTarget];
}

+ (NSNumber *) timesliceFromRequest:(DConnectMessage *)request {
	return [request numberForKey:DConnectMediaStreamRecordingProfileParamTimeSlice];
}

+ (NSNumber *) imageWidthFromRequest:(DConnectMessage *)request {
	return [request numberForKey:DConnectMediaStreamRecordingProfileParamImageWidth];
}

+ (NSNumber *) imageHeightFromRequest:(DConnectMessage *)request {
	return [request numberForKey:DConnectMediaStreamRecordingProfileParamImageHeight];
}

+ (NSString *) mimeTypeFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectMediaStreamRecordingProfileParamMIMEType];
}

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
