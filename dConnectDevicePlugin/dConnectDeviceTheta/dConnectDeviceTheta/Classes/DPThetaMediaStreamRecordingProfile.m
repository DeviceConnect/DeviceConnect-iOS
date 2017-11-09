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
#import "DPThetaMixedReplaceMediaServer.h"
#import "DPThetaService.h"
 
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
        __weak DPThetaMediaStreamRecordingProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPThetaDevicePlugin class]];
        self.server = [DPThetaMixedReplaceMediaServer new];
        
        // API登録(didReceiveGetMediaRecorderRequest相当)
        NSString *getMediaRecorderRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getMediaRecorderRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         CONNECT_CHECK();
                         DConnectArray *recorders = [DConnectArray new];
                         DConnectMessage *recorder = [DConnectMessage new];
                         [DConnectMediaStreamRecordingProfile
                          setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
                          target:recorder];
                         [DConnectMediaStreamRecordingProfile
                          setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
                          target:recorder];
                         [DConnectMediaStreamRecordingProfile setRecorderImageWidth:DPThetaMinWidth target:recorder];
                         [DConnectMediaStreamRecordingProfile setRecorderImageHeight:DPThetaMinHeight target:recorder];
                         [DConnectMediaStreamRecordingProfile setRecorderConfig:@"[]" target:recorder];
                         if ([[DPThetaManager sharedManager] getCameraStatus] == 0) {
                             [DConnectMediaStreamRecordingProfile setRecorderId:@"1" target:recorder];
                             [DConnectMediaStreamRecordingProfile setRecorderMIMEType:DPThetaMovieMimeType
                                                                               target:recorder];
                             [DConnectMediaStreamRecordingProfile setRecorderName:@"THETA - movie" target:recorder];
                             
                         } else {
                             [DConnectMediaStreamRecordingProfile setRecorderId:@"0" target:recorder];
                             [DConnectMediaStreamRecordingProfile
                              setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateRecording
                              target:recorder];
                             [DConnectMediaStreamRecordingProfile setRecorderMIMEType:DPThetaImageMimeType
                                                                               target:recorder];
                             [DConnectMediaStreamRecordingProfile setRecorderName:@"THETA - photo" target:recorder];
                             
                         }
                         [recorders addMessage:recorder];
                         [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        // API登録(didReceivePostTakePhotoRequest相当)
        NSString *postTakePhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrTakePhoto];
        [self addPostPath: postTakePhotoRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                          NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         
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
                              
                          } fileMgr:[WEAKSELF_PLUGIN fileMgr]];
                          if (!isSuccess) {
                              [response setErrorToIllegalServerStateWithMessage:@"Failed to take a picture."];
                          }
                          return !isSuccess;
                      }];
        
        // API登録(didReceivePostRecordRequest相当)
        NSString *postRecordRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrRecord];
        [self addPostPath: postRecordRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                          NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                          NSNumber *timeslice = [DConnectMediaStreamRecordingProfile timesliceFromRequest:request];

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
                      }];
        
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                         CONNECT_CHECK();
                         BOOL isSuccess = [[DPThetaManager sharedManager] stopMovie];
                         if (isSuccess) {
                             [response setResult:DConnectMessageResultTypeOk];
                         } else {
                             [response setErrorToIllegalDeviceStateWithMessage:@"Failed to record movie stop"];
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnPhotoRequest相当)
        NSString *putOnPhotoRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CONNECT_CHECK();
                         [weakSelf handleEventRequest:request response:response isRemove:NO callback:^{
                             [[DPThetaManager sharedManager] addOnPhotoEventCallbackWithID:serviceId
                                                                                   fileMgr:[WEAKSELF_PLUGIN fileMgr]
                                                                                  callback:^(NSString *path) {
                                                                                      [weakSelf sendOnPhotoEventWithPath:path mimeType:DPThetaImageMimeType];
                                                                                  }];
                         }];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnRecordingChangeRequest相当)
        NSString *putOnRecordingChangeRequestApiPath = [self apiPath: nil
                                                       attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addPutPath: putOnRecordingChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         CONNECT_CHECK();
                         [weakSelf handleEventRequest:request response:response isRemove:NO callback:^{
                             [[DPThetaManager sharedManager] addOnStatusEventCallbackWithID:serviceId
                                                                                   callback:^(NSString *status,
                                                                                              NSString *message) {
                                                                                       [weakSelf sendOnRecordingChangeEventWithServiceId:serviceId
                                                                                                                                  status:status
                                                                                                                                mimeType:DPThetaMovieMimeType
                                                                                                                     errorMessage:message];
                                                                                   }];
                             
                         }];
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteOnPhotoRequest相当)
        NSString *deleteOnPhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                            NSString *serviceId = [request serviceId];
                            
                            CONNECT_CHECK();
                            [weakSelf handleEventRequest:request response:response isRemove:YES callback:^{
                                [[DPThetaManager sharedManager] removeOnPhotoEventCallbackWithID:serviceId];
                            }];
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnRecordingChangeRequest相当)
        NSString *deleteOnRecordingChangeRequestApiPath = [self apiPath: nil
                                                          attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addDeletePath: deleteOnRecordingChangeRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            
                            CONNECT_CHECK();
                            [weakSelf handleEventRequest:request response:response isRemove:YES callback:^{
                                [[DPThetaManager sharedManager] removeOnStatusEventCallbackWithID:serviceId];
                            }];
                            return YES;
                        }];
    }
    return self;
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
    NSArray *evts = [_eventMgr eventListForServiceId:DPThetaDeviceServiceId
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

- (void) sendOnRecordingChangeEventWithServiceId:(NSString*)serviceId
                                          status:(NSString *)status
                                     mimeType:(NSString *)mimeType
                                 errorMessage:(NSString *)errorMsg
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPThetaDeviceServiceId
                                             profile:DConnectMediaStreamRecordingProfileName
                                           attribute:DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setStatus:status target:media];
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
