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
NSString *const DConnectMediaStreamRecordingProfileAttrMediaRecorder = @"mediaRecorder";
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

@implementation DConnectMediaStreamRecordingProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectMediaStreamRecordingProfileName;
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

@end
