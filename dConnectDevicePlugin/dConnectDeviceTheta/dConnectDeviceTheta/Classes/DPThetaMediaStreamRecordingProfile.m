//
//  DPThetaMediaStreamRecordingProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaMediaStreamRecordingProfile.h"
#import "DPThetaDevicePlugin.h"
#import "DPThetaManager.h"
#import "PtpIpObjectInfo.h"
#import "DPThetaServiceDiscoveryProfile.h"
#import "DPThetaMixedReplaceMediaServer.h"


//Thetaの画像の最大の高さ
static NSUInteger const DPThetaMaxHeight = 1792;

//Thetaの画像の最大の幅
static NSUInteger const DPThetaMaxWidth = 3584;

//Thetaの画像の最小の高さ
static NSUInteger const DPThetaMinHeight = 1024;

//Thetaの画像の最小の幅
static NSUInteger const DPThetaMinWidth = 2048;

//Thetaの画像のMimeType
static NSString *const DPThetaImageMimeType = @"image/jpeg";

//Thetaの動画のMimeType
static NSString *const DPThetaMovieMimeType = @"video/mov";


@interface DPThetaMediaStreamRecordingProfile()
/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;
@property DPThetaMixedReplaceMediaServer *server;

@end
@implementation DPThetaMediaStreamRecordingProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPThetaDevicePlugin class]];
        self.server = [DPThetaMixedReplaceMediaServer new];
    }
    return self;
}

#pragma mark - Get Methods

- (BOOL)                  profile:(DConnectMediaStreamRecordingProfile *)profile
didReceiveGetMediaRecorderRequest:(DConnectRequestMessage *)request
                         response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
{
    CONNECT_CHECK();
    DConnectArray *recorders = [DConnectArray new];
    DConnectMessage *recorder = [DConnectMessage new];
    [DConnectMediaStreamRecordingProfile setRecorderId:@"0" target:recorder];
    [DConnectMediaStreamRecordingProfile setRecorderName:@"Theta" target:recorder];
    [DConnectMediaStreamRecordingProfile
     setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
     target:recorder];
    [DConnectMediaStreamRecordingProfile setRecorderMIMEType:DPThetaImageMimeType
                                                      target:recorder];
    [DConnectMediaStreamRecordingProfile setRecorderImageWidth:DPThetaMaxWidth target:recorder];
    [DConnectMediaStreamRecordingProfile setRecorderImageHeight:DPThetaMaxHeight target:recorder];
    [DConnectMediaStreamRecordingProfile setRecorderConfig:@"[]" target:recorder];
    [recorders addMessage:recorder];
    DConnectMessage *video = [DConnectMessage new];
    [DConnectMediaStreamRecordingProfile setRecorderId:@"1" target:video];
    [DConnectMediaStreamRecordingProfile setRecorderName:@"Theta" target:video];
    if ([[DPThetaManager sharedManager] getCameraStatus] == 1) {
        [DConnectMediaStreamRecordingProfile
         setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateRecording
         target:video];
    } else {
        [DConnectMediaStreamRecordingProfile
         setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
         target:video];
        
    }
    [DConnectMediaStreamRecordingProfile setRecorderMIMEType:DPThetaMovieMimeType
                                                      target:video];
    [DConnectMediaStreamRecordingProfile setRecorderImageWidth:DPThetaMaxWidth target:video];
    [DConnectMediaStreamRecordingProfile setRecorderImageHeight:DPThetaMaxHeight target:video];
    [DConnectMediaStreamRecordingProfile setRecorderConfig:@"[]" target:video];
    [recorders addMessage:video];
    [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}


- (BOOL)            profile:(DConnectMediaStreamRecordingProfile *)profile
didReceiveGetOptionsRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                     target:(NSString *)target
{
    CONNECT_CHECK();
    DConnectMessage *imageWidth = [DConnectMessage new];
    DConnectMessage *imageHeight = [DConnectMessage new];
    DConnectArray *mimeTypes = [DConnectArray initWithArray:@[DPThetaImageMimeType, DPThetaMovieMimeType]];
    
    [DConnectMediaStreamRecordingProfile setMax:DPThetaMaxWidth target:imageWidth];
    [DConnectMediaStreamRecordingProfile setMin:DPThetaMinWidth target:imageWidth];
    [DConnectMediaStreamRecordingProfile setImageWidth:imageWidth target:response];
    [DConnectMediaStreamRecordingProfile setMax:DPThetaMaxHeight target:imageHeight];
    [DConnectMediaStreamRecordingProfile setMin:DPThetaMinHeight target:imageHeight];
    [DConnectMediaStreamRecordingProfile setImageHeight:imageHeight target:response];
    [DConnectMediaStreamRecordingProfile setMIMETypes:mimeTypes target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

#pragma mark - Post Methods


- (BOOL)               profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePostTakePhotoRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
                        target:(NSString *)target
{
    CONNECT_CHECK();
    if (target && ![target isEqualToString:@"0"]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Invalid target"];
        return YES;
    }
    BOOL isSuccess = [[DPThetaManager sharedManager] takePictureWithCompletion:^(NSString *uri, NSString* path) {
        [response setResult:DConnectMessageResultTypeOk];

        [DConnectMediaStreamRecordingProfile setUri:uri
                                             target:response];
        [DConnectMediaStreamRecordingProfile setPath:path
                                              target:response];
        [[DConnectManager sharedManager] sendResponse:response];

    } fileMgr:[SELF_PLUGIN fileMgr]];
    if (!isSuccess) {
        [response setErrorToIllegalServerStateWithMessage:@"Failed to take a picture."];
    }
    return !isSuccess;
}

- (BOOL)            profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePostRecordRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                     target:(NSString *)target
                  timeslice:(NSNumber *)timeslice
{
    CONNECT_CHECK();
    if (target && ![target isEqualToString:@"1"]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"Invalid target"];
        return YES;
    }
    NSString *timesliceString = [request stringForKey:DConnectMediaStreamRecordingProfileParamTimeSlice];
    if (![DPThetaManager existDigitWithString:timesliceString]
        || (timeslice && timeslice < 0) || (timesliceString && timesliceString.length <= 0)) {
        [response setErrorToInvalidRequestParameterWithMessage:
         @"timeslice is not supported; please omit this parameter."];
        return YES;
    }
    BOOL isSuccess = [[DPThetaManager sharedManager] recordingMovie];
    if (isSuccess) {
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToIllegalDeviceStateWithMessage:@"Failed to record movie start"];
    }
    
    return YES;
}


#pragma mark - Put Methods


- (BOOL)         profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePutStopRequest:(DConnectRequestMessage *)request
                response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
                  target:(NSString *)target
{
    CONNECT_CHECK();
    BOOL isSuccess = [[DPThetaManager sharedManager] stopMovie];
    if (isSuccess) {
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToIllegalDeviceStateWithMessage:@"Failed to record movie stop"];
    }
 
    return YES;
}


- (BOOL)            profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePutOptionsRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                     target:(NSString *)target
                 imageWidth:(NSNumber *)imageWidth
                imageHeight:(NSNumber *)imageHeight
                   mimeType:(NSString *)mimeType
{
    CONNECT_CHECK();
    if ((([imageWidth floatValue] == DPThetaMaxWidth) && ([imageHeight floatValue] == DPThetaMaxHeight))
        || (([imageWidth floatValue] == DPThetaMinWidth) && ([imageHeight floatValue] == DPThetaMinHeight))) {
        [[DPThetaManager sharedManager] setImageSize:CGSizeMake([imageWidth floatValue],
                                                                [imageHeight floatValue])];
    }
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

#pragma mark Event Registration


- (BOOL)            profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePutOnPhotoRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                 sessionKey:(NSString *)sessionKey
{
    CONNECT_CHECK();
    [self handleEventRequest:request response:response isRemove:NO callback:^{
        [[DPThetaManager sharedManager] addOnPhotoEventCallbackWithID:serviceId
                                                              fileMgr:[SELF_PLUGIN fileMgr]
                                                             callback:^(NSString *path) {
            [self sendOnPhotoEventWithPath:path mimeType:DPThetaImageMimeType];
        }];
    }];
    return YES;
}


- (BOOL)                      profile:(DConnectMediaStreamRecordingProfile *)profile
didReceivePutOnRecordingChangeRequest:(DConnectRequestMessage *)request
                             response:(DConnectResponseMessage *)response
                            serviceId:(NSString *)serviceId
                           sessionKey:(NSString *)sessionKey
{
    CONNECT_CHECK();
    [self handleEventRequest:request response:response isRemove:NO callback:^{
        [[DPThetaManager sharedManager] addOnStatusEventCallbackWithID:serviceId
                                                              callback:^(PtpIpObjectInfo *object,
                                                                         NSString *status,
                                                                         NSString *message) {
            NSString *path = nil;
            if (object) {
                path = object.filename;
            }
            [self sendOnRecordingChangeEventWithStatus:status
                                                  path:path
                                              mimeType:DPThetaMovieMimeType
                                          errorMessage:message];
        }];
    }];
    return YES;
}

#pragma mark - Delete Methods
#pragma mark Event Unregstration

- (BOOL) profile:(DConnectMediaStreamRecordingProfile *)profile
    didReceiveDeleteOnPhotoRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
       serviceId:(NSString *)serviceId
      sessionKey:(NSString *)sessionKey
{
    CONNECT_CHECK();
    [self handleEventRequest:request response:response isRemove:YES callback:^{
        [[DPThetaManager sharedManager] removeOnPhotoEventCallbackWithID:serviceId];
    }];
    return YES;
}


- (BOOL)                         profile:(DConnectMediaStreamRecordingProfile *)profile
didReceiveDeleteOnRecordingChangeRequest:(DConnectRequestMessage *)request
                                response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                              sessionKey:(NSString *)sessionKey
{
    CONNECT_CHECK();
    [self handleEventRequest:request response:response isRemove:YES callback:^{
        [[DPThetaManager sharedManager] removeOnStatusEventCallbackWithID:serviceId];
    }];
    return YES;
}


#pragma mark - Event Method

- (void)handleEventRequest:(DConnectRequestMessage *)request
                  response:(DConnectResponseMessage *)response
                  isRemove:(BOOL)isRemove
                  callback:(void(^)())callback
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPThetaDevicePlugin class]];
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


// OnPhotoのイベントを送信する
- (void)sendOnPhotoEventWithPath:(NSString *)path mimeType:(NSString*)mimeType
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ;
    });
    
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPThetaServiceDiscoveryServiceId
                                             profile:DConnectMediaStreamRecordingProfileName
                                           attribute:DConnectMediaStreamRecordingProfileAttrOnPhoto];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *photo = [DConnectMessage message];
        
        [DConnectMediaStreamRecordingProfile setPath:path target:photo];
        
        [DConnectMediaStreamRecordingProfile setMIMEType:mimeType target:photo];
        [DConnectMediaStreamRecordingProfile setPhoto:photo target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (void) sendOnRecordingChangeEventWithStatus:(NSString *)status
                                         path:(NSString *)path
                                     mimeType:(NSString *)mimeType
                                 errorMessage:(NSString *)errorMsg
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPThetaServiceDiscoveryServiceId
                                             profile:DConnectMediaStreamRecordingProfileName
                                           attribute:DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setStatus:status target:media];
        if (path) {
            [DConnectMediaStreamRecordingProfile setPath:path target:media];
        }
        if (mimeType) {
            [DConnectMediaStreamRecordingProfile setMIMEType:mimeType target:media];
        }
        if (errorMsg) {
            [DConnectMediaStreamRecordingProfile setErrorMessage:errorMsg target:media];
        }
        [DConnectMediaStreamRecordingProfile setMedia:media target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

@end
