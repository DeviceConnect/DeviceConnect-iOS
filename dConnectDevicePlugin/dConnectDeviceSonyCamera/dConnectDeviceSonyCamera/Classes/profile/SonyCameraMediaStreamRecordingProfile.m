//
//  SonyCameraMediaStreamRecordingProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraMediaStreamRecordingProfile.h"
#import "SonyCameraDevicePlugin.h"
#import "SonyCameraManager.h"
#import "RemoteApiList.h"

/*!
 @brief ターゲットIDを定義.
 */
#define SONY_TARGET_ID @"sonycamera"

/*!
 @brief ターゲット名を定義.
 */
#define SONY_TARGET_NAME @"Sony Camera"

@implementation SonyCameraMediaStreamRecordingProfile

- (instancetype) init {
    
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        // GET /mediaStreamRecording/mediaRecorder
        NSString *getMediaRecorderRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getMediaRecorderRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivedGetMediaRecorderRequest:request response:response];
        }];
        
        // POST /mediaStreamRecording/takePhoto
        NSString *postTakePhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrTakePhoto];
        [self addPostPath: postTakePhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePostTakePhotoRequest:request response:response];
        }];
        
        // POST /mediaStreamRecording/record
        NSString *postRecordRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrRecord];
        [self addPostPath: postRecordRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePostRecordRequest:request response:response];
        }];
        
        // PUT /mediaStreamRecording/stop
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutStopRequest:request response:response];
        }];
        
        // PUT /mediaStreamRecording/onPhoto
        NSString *putOnPhotoRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutOnPhotoRequest:request response:response];
        }];
        
        // DELETE /mediaStreamRecording/onPhoto
        NSString *deleteOnPhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeleteOnPhotoRequest:request response:response];
        }];
        
        // PUT /mediaStreamRecording/preview
        NSString *putPreviewRequestApiPath = [self apiPath: nil
                                             attributeName: @"preview"];
        [self addPutPath: putPreviewRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutPreviewRequest:request response:response];
        }];
        
        // DELETE /mediaStreamRecording/preview
        NSString *deletePreviewRequestApiPath = [self apiPath: nil
                                                attributeName: @"preview"];
        [self addDeletePath: deletePreviewRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveDeletePreviewRequest:request response:response];
        }];
    }
    return self;
}

#pragma mark - Private Methods

- (BOOL) didReceivedGetMediaRecorderRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    [manager getCameraState:^(NSString *state, int width, int height) {
        if (state) {
            DConnectMessage *recorder = [DConnectMessage message];
            [DConnectMediaStreamRecordingProfile setRecorderId:SONY_TARGET_ID target:recorder];
            [DConnectMediaStreamRecordingProfile setRecorderName:SONY_TARGET_NAME target:recorder];
            [DConnectMediaStreamRecordingProfile setRecorderState:state target:recorder];
            [DConnectMediaStreamRecordingProfile setRecorderMIMEType:@"image/jpg" target:recorder];
            if (width > 0 && height > 0) {
                [DConnectMediaStreamRecordingProfile setRecorderImageWidth:width target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderImageHeight:height target:recorder];
            }
            
            DConnectArray *recorders = [DConnectArray array];
            [recorders addMessage:recorder];
            
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    return NO;
}


- (BOOL) didReceivePostTakePhotoRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }

    // サポートしていない
    if (![manager isSupportedPicture]) {
        [response setErrorToNotSupportAttribute];
        return YES;
    }
    
    // 既に撮影中はエラー
    if ([manager isRecording]) {
        [response setErrorToIllegalDeviceState];
        return YES;
    }
    
    [manager takePicture:^(NSString *uri) {
        if (uri) {
            [response setResult:DConnectMessageResultTypeOk];
            [DConnectMediaStreamRecordingProfile setUri:uri target:response];
        } else {
            [response setErrorToUnknown];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
    return NO;
}


- (BOOL) didReceivePostRecordRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }
    
    // サポートしていない
    if (![manager isSupportedRecording]) {
        [response setErrorToNotSupportAttribute];
        return YES;
    }
    
    // 撮影中は、さらに撮影できないのでエラーを返す
    if ([manager isRecording]) {
        [response setErrorToIllegalDeviceState];
        return YES;
    }
    
    [manager startMovieRec:^(int errorCode, NSString *errorMessage) {
        if (errorCode == 0) {
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setError:errorCode message:errorMessage];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
    return NO;
}


- (BOOL) didReceivePutStopRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }
    
    // サポートしていない
    if (![manager isSupportedRecording]) {
        [response setErrorToNotSupportAttribute];
        return YES;
    }
    
    // 撮影が開始されていないので、エラーを返す。
    if (![manager isRecording]) {
        [response setErrorToIllegalDeviceState];
        return YES;
    }
    
    [manager stopMovieRec:^(int errorCode, NSString *errorMessage) {
        if (errorCode == 0) {
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setError:errorCode message:errorMessage];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
    return NO;
}

- (BOOL) didReceivePutOnPhotoRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }

    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }

    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self.plugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameter];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) didReceiveDeleteOnPhotoRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }

    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }

    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[self.plugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
    } else if (error == DConnectEventErrorInvalidParameter
               || error == DConnectEventErrorNotFound) {
        [response setErrorToInvalidRequestParameter];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) didReceivePutPreviewRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSNumber *timeSlice = [request numberForKey:@"timeSlice"];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }

    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }

    [manager startPreviewWithTimeSlice:timeSlice block:^(NSString *uri) {
        if (uri) {
            [response setResult:DConnectMessageResultTypeOk];
            [response setString:uri forKey:@"uri"];
        } else {
            [response setErrorToUnknown];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
    return NO;
}

- (BOOL) didReceiveDeletePreviewRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    // ターゲットチェック
    if (target && ![target isEqualToString:SONY_TARGET_ID]) {
        [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
        return YES;
    }
    
    // プレビューチェック
    if (![manager isPreview]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not running a preview."];
        return YES;
    }

    [manager stopPreview];

    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}


@end
