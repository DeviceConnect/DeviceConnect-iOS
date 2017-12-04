//
//  DPHostMediaStreamRecordingProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <DConnectSDK/DConnectFileManager.h>
#import <ImageIO/ImageIO.h>
#import "DPHostDevicePlugin.h"
#import "DPHostService.h"
#import "DPHostUtils.h"
#import "DPHostRecorderManager.h"
#import "DPHostPhotoRecorder.h"

#import "DPHostMediaStreamRecordingProfile.h"

@interface DPHostMediaStreamRecordingProfile ()
@property DPHostRecorderManager *recorderMgr;
@property DConnectEventManager *eventMgr;
@end

@implementation DPHostMediaStreamRecordingProfile



- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recorderMgr = [DPHostRecorderManager new];
        [self.recorderMgr createRecorders];
        [self.recorderMgr initialize];
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        __weak DPHostMediaStreamRecordingProfile *weakSelf = self;
        
        // API登録(didReceiveGetMediaRecorderRequest相当)
        NSString *getPlayStatusRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getPlayStatusRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectArray *recorders = [DConnectArray array];
                         NSArray *recorderArr = [weakSelf.recorderMgr getRecorders];
                         
                         for (DPHostRecorder *recorderItr in recorderArr) {
                             [recorderItr performReading:^{
                                 
                                   DConnectMessage *recorder = [DConnectMessage message];
                                   [DConnectMediaStreamRecordingProfile setRecorderId:recorderItr.recorderId target:recorder];
                                   [DConnectMediaStreamRecordingProfile setRecorderName:recorderItr.name target:recorder];
 
                                   NSString *state;
                                   switch (recorderItr.state) {
                                       case DPHostRecorderStateInactive:
                                           state = DConnectMediaStreamRecordingProfileRecorderStateInactive;
                                           break;
                                       case DPHostRecorderStatePaused:
                                           state = DConnectMediaStreamRecordingProfileRecorderStatePaused;
                                           break;
                                       case DPHostRecorderStateRecording:
                                           state = DConnectMediaStreamRecordingProfileRecorderStateRecording;
                                           break;
                                   }
                                   [DConnectMediaStreamRecordingProfile setRecorderState:state target:recorder];
 
                                   if (recorderItr.pictureSize.width != -1
                                       && recorderItr.pictureSize.height != -1) {
                                       if (recorderItr.pictureSize.width) {
                                           [DConnectMediaStreamRecordingProfile setRecorderImageWidth:
                                            (int) recorderItr.pictureSize.width target:recorder];
                                       }
                                       if (recorderItr.pictureSize.height) {
                                           [DConnectMediaStreamRecordingProfile setRecorderImageHeight:
                                            recorderItr.pictureSize.height target:recorder];
                                       }
                                   }
                                   [DConnectMediaStreamRecordingProfile setRecorderMIMEType:recorderItr.mimeType target:recorder];
                                   [DConnectMediaStreamRecordingProfile setRecorderConfig:@"[]" target:recorder];
 
                                   [recorders addMessage:recorder];
                               }];
                          }
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
                          DPHostPhotoRecorder *recorder = [weakSelf.recorderMgr getCameraRecorderForRecorderId:target];
                          if (!recorder) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                              return YES;
                          }
                          void (^block) (void) = ^(void) {
                              [recorder takePhotoWithSuccessCompletion:^(NSURL *assetURL) {
                                  [DConnectMediaStreamRecordingProfile setUri:assetURL.absoluteString target:response];
                                  [DConnectMediaStreamRecordingProfile setPath:assetURL.path target:response];
                                  NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:@"jpg"];
                                  [DConnectMediaStreamRecordingProfile setMIMEType:mimeType target:response];
                                  [response setResult:DConnectMessageResultTypeOk];
                                  [[DConnectManager sharedManager] sendResponse:response];
                                  [weakSelf sendOnPhotoEventWithPath:assetURL.absoluteString mimeType:mimeType];
                              } failCompletion:^(NSString *errorMessage) {
                                  [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                  [[DConnectManager sharedManager] sendResponse:response];
                              }];
                          };
                          [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                          return NO;
                      }];
        
        // API登録(didReceivePostRecordRequest相当)
        NSString *postRecordRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrRecord];
        [self addPostPath: postRecordRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                          NSNumber *timeslice = [DConnectMediaStreamRecordingProfile timesliceFromRequest:request];

                          NSString *timesliceString = [request stringForKey:DConnectMediaStreamRecordingProfileParamTimeSlice];
                          if (![DPHostUtils existDigitWithString:timesliceString]
                              || (timeslice && timeslice < 0) || (timesliceString && timesliceString.length <= 0)) {
                              [response setErrorToInvalidRequestParameterWithMessage:
                               @"timeslice is not supported; please omit this parameter."];
                              return YES;
                          }
                          DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                          if (!recorder) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                              return YES;
                          }
                          NSString *usedRecorderName = [weakSelf.recorderMgr usedRecorder];
                          if (usedRecorderName) {
                              // レコーダーが既に他のコンテキストで使われている。
                              [response setErrorToInvalidRequestParameterWithMessage:
                                       [NSString stringWithFormat:@"Recorder device is currently used by %@.",
                                        usedRecorderName]];
                              return YES;
                          }
                          void (^block) (void) = ^(void) {
                              [recorder startRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder, NSString *fileName) {
                                  [response setResult:DConnectMessageResultTypeOk];
                                  [weakSelf sendOnRecordingChangeEventWithStatus:DConnectMediaStreamRecordingProfileRecordingStateRecording
                                                                            path:fileName mimeType:recorder.mimeType errorMessage:nil];
                                  [[DConnectManager sharedManager] sendResponse:response];
                              } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                  [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                  [[DConnectManager sharedManager] sendResponse:response];
                              }];
                          };
                          [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                          return NO;

                      }];
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         void (^block) (void) = ^(void) {
                             [recorder stopRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder, NSString *fileName) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [DConnectMediaStreamRecordingProfile setUri:fileName target:response];
                                 [DConnectMediaStreamRecordingProfile setMIMEType:recorder.mimeType target:response];
                                 [weakSelf sendOnRecordingChangeEventWithStatus:DConnectMediaStreamRecordingProfileRecordingStateStop
                                                                           path:fileName mimeType:recorder.mimeType errorMessage:nil];
                                 [[DConnectManager sharedManager] sendResponse:response];
                                 
                             } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                         return NO;
                     }];
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaStreamRecordingProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         void (^block) (void) = ^(void) {
                             [recorder pauseRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                         return NO;
                     }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaStreamRecordingProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         void (^block) (void) = ^(void) {
                             [recorder resumeRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                         return NO;
                     }];
        
        
        
        // API登録(didReceivePutMuteTrackRequest相当)
        NSString *putMuteTrackRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectMediaStreamRecordingProfileAttrMuteTrack];
        [self addPutPath: putMuteTrackRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         void (^block) (void) = ^(void) {
                             [recorder muteRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                         return NO;
                     }];
        
        // API登録(didReceivePutUnmuteTrackRequest相当)
        NSString *putUnmuteTrackRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectMediaStreamRecordingProfileAttrUnmuteTrack];
        [self addPutPath: putUnmuteTrackRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostStreamRecorder *recorder = [weakSelf.recorderMgr getVideoRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         __block void (^block) (void) = ^(void) {
                             [recorder unMuteRecordingWithSuccessCompletion:^(DPHostStreamRecorder *recorder) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             } failCompletion:^(DPHostStreamRecorder *recorder, NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                         return NO;
                     }];
        
        // API登録(didReceivePutOnPhotoRequest相当)
        NSString *putOnPhotoRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakSelf.eventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnRecordingChangeRequest相当)
        NSString *putOnRecordingChangeRequestApiPath = [self apiPath: nil
                                                       attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addPutPath: putOnRecordingChangeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([weakSelf.eventMgr addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutPreviewRequest相当)
        NSString *putPreviewRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrPreview];
        [self addPutPath: putPreviewRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         DPHostPhotoRecorder *recorder = [weakSelf.recorderMgr getCameraRecorderForRecorderId:target];
                         if (!recorder) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                             return YES;
                         }
                         void (^block) (void) = ^(void) {
                             [recorder startWebServerWithSuccessCompletion:^(NSString *uri) {
                                 [response setResult:DConnectMessageResultTypeOk];
                                 [DConnectMediaStreamRecordingProfile setUri:uri target:response];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             } failCompletion:^(NSString *errorMessage) {
                                 [response setErrorToIllegalDeviceStateWithMessage:errorMessage];
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         };
                         [weakSelf requestAuthorizedAfterRunBlock:block response:response];

                         return NO;
                     }];
        
        // API登録(didReceiveDeleteOnPhotoRequest相当)
        NSString *deleteOnPhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakSelf.eventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // エラー無し.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                                case DConnectEventErrorFailed:           // 処理失敗.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnRecordingChangeRequest相当)
        NSString *deleteOnRecordingChangeRequestApiPath = [self apiPath: nil
                                                          attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addDeletePath: deleteOnRecordingChangeRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([weakSelf.eventMgr removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // エラー無し.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                                case DConnectEventErrorFailed:           // 処理失敗.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeletePreviewRequest相当)
        NSString *deletePreviewRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrPreview];
        [self addDeletePath: deletePreviewRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                            DPHostPhotoRecorder *recorder = [weakSelf.recorderMgr getCameraRecorderForRecorderId:target];
                            if (!recorder) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"target is invalid."];
                                return YES;
                            }
                            void (^block) (void) = ^(void) {
                                [recorder stopWebServer];
                                [response setResult:DConnectMessageResultTypeOk];
                            };
                            [weakSelf requestAuthorizedAfterRunBlock:block response:response];
                            return YES;
                        }];
        
    }
    return self;
}

#pragma mark - Private Method
- (void)requestAuthorizedAfterRunBlock:(void (^)(void))block response:(DConnectResponseMessage *)response {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusAuthorized:
        default:
            break;
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusNotDetermined:
            // 初回起動時に許可設定を促すダイアログが表示される
            NSLog(@"aaaaa");
            dispatch_async(dispatch_get_main_queue(), ^{
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    if (granted) {
                        block();
                    } else {
                        [response setErrorToUnknownWithMessage:@"Not Authorized to take photo."];
                        [[DConnectManager sharedManager] sendResponse:response];
                    }
                }];

            });
            return;
    }
    
    block();
}


#pragma mark - Send Event

- (void) sendOnPhotoEventWithPath:(NSString *)path mimeType:(NSString*)mimeType
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ;
    });
    
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaStreamRecordingProfileName
                                           attribute:DConnectMediaStreamRecordingProfileAttrOnPhoto];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *photo = [DConnectMessage message];
        
        [DConnectMediaStreamRecordingProfile setUri:path target:photo];
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
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                             profile:DConnectMediaStreamRecordingProfileName
                                           attribute:DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
    
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *media = [DConnectMessage message];
        [DConnectMediaStreamRecordingProfile setStatus:status target:media];
        if (path) {
            [DConnectMediaStreamRecordingProfile setUri:path target:media];
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
