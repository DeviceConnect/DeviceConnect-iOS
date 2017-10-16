//
//  DPHostMediaStreamRecordingProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <ImageIO/ImageIO.h>
#import "DPHostDevicePlugin.h"
#import "DPHostService.h"
#import "DPHostMediaStreamRecordingProfile.h"
#import "DPHostRecorderContext.h"
#import "DPHostUtils.h"


#import "DPHostRecorderManager.h"


@interface DPHostMediaStreamRecordingProfile ()
@property DPHostRecorderManager *manager;
@property DConnectEventManager *eventMgr;
@end

@implementation DPHostMediaStreamRecordingProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        __weak DPHostMediaStreamRecordingProfile *weakSelf = self;
        self.manager = [DPHostRecorderManager sharedManager];
        
        // API登録(didReceiveGetMediaRecorderRequest相当)
        NSString *getPlayStatusRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getPlayStatusRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectArray *recorders = [DConnectArray array];
                         NSArray *recorderArr = [weakSelf.manager playStatus];
                         for (size_t i = 0; i < recorderArr.count; ++i) {
                             DPHostRecorderContext *recorderItr = recorderArr[i];
                             [recorderItr performReading:
                              ^{
                                  DConnectMessage *recorder = [DConnectMessage message];
                                  
                                  [DConnectMediaStreamRecordingProfile setRecorderId:[NSString stringWithFormat:@"%lu", i] target:recorder];
                                  [DConnectMediaStreamRecordingProfile setRecorderName:recorderItr.name target:recorder];
                                  
                                  NSString *state;
                                  switch (recorderItr.state) {
                                      case RecorderStateInactive:
                                          state = DConnectMediaStreamRecordingProfileRecorderStateInactive;
                                          break;
                                      case RecorderStatePaused:
                                          state = DConnectMediaStreamRecordingProfileRecorderStatePaused;
                                          break;
                                      case RecorderStateRecording:
                                          state = DConnectMediaStreamRecordingProfileRecorderStateRecording;
                                          break;
                                  }
                                  [DConnectMediaStreamRecordingProfile setRecorderState:state target:recorder];
                                  
                                  if (recorderItr.videoDevice) {
                                      if (recorderItr.videoDevice.imageWidth) {
                                          [DConnectMediaStreamRecordingProfile setRecorderImageWidth:
                                           [recorderItr.videoDevice.imageWidth intValue] target:recorder];
                                      }
                                      if (recorderItr.videoDevice.imageHeight) {
                                          [DConnectMediaStreamRecordingProfile setRecorderImageHeight:
                                           [recorderItr.videoDevice.imageHeight intValue] target:recorder];
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
                         [weakSelf.manager takephotoForTarget:target completionHandler:^(NSURL *assetURL, NSError *error) {
                             if (!error) {
                                 [DConnectMediaStreamRecordingProfile setUri:[assetURL absoluteString] target:response];
                                 [response setResult:DConnectMessageResultTypeOk];
                                 NSString *mimeType = [DConnectFileManager searchMimeTypeForExtension:assetURL.path.pathExtension];
                                 [weakSelf sendOnPhotoEventWithPath:[assetURL absoluteString] mimeType:mimeType];
                             } else {
                                 [response setError:error.code message:error.localizedDescription];
                             }
                             [[DConnectManager sharedManager] sendResponse:response];
                         }];
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
                          [weakSelf.manager recordForTarget:target timeSlice:timeslice response:response completionHandler:^(NSError *error) {
                              if (!error) {
                                  [response setResult:DConnectMessageResultTypeOk];
                                  [weakSelf sendOnRecordingChangeEventWithStatus:DConnectMediaStreamRecordingProfileRecordingStateRecording
                                                                            path:nil mimeType:nil errorMessage:nil];
                              } else {
                                  [response setError:error.code message:error.localizedDescription];
                              }
                              [[DConnectManager sharedManager] sendResponse:response];
                          }];
                          return NO;
                      }];
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         [weakSelf.manager stopForTarget:target completionHandler:^(NSURL *assetURL, NSError *error) {
                             if (!error) {
                                 [DConnectMediaStreamRecordingProfile setUri:[assetURL absoluteString] target:response];
                                 [response setResult:DConnectMessageResultTypeOk];
                                 
                                 [weakSelf sendOnRecordingChangeEventWithStatus:DConnectMediaStreamRecordingProfileRecordingStateStop
                                                                           path:[assetURL absoluteString] mimeType:nil
                                                                   errorMessage:nil];
                             } else {
                                 [response setError:error.code message:error.localizedDescription];
                             }
                             
                             [[DConnectManager sharedManager] sendResponse:response];
                             
                         }];
                         return NO;
                     }];
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectMediaStreamRecordingProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         NSError *error = nil;
                         [weakSelf.manager pauseForTarget:target error:&error];
                         [weakSelf runMediaStreamRecordingWithError:error response:response state:DConnectMediaStreamRecordingProfileRecordingStatePause];
                         return YES;
                     }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectMediaStreamRecordingProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         NSError *error = nil;
                         [weakSelf.manager resumeForTarget:target error:&error];
                         [weakSelf runMediaStreamRecordingWithError:error response:response state:DConnectMediaStreamRecordingProfileRecordingStateResume];
                         return YES;
                     }];
        

        
        // API登録(didReceivePutMuteTrackRequest相当)
        NSString *putMuteTrackRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectMediaStreamRecordingProfileAttrMuteTrack];
        [self addPutPath: putMuteTrackRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         NSError *error = nil;
                         [weakSelf.manager muteTrackForTarget:target error:&error];
                         [weakSelf runMediaStreamRecordingWithError:error response:response state:DConnectMediaStreamRecordingProfileRecordingStateMutetrack];
                         return YES;
                     }];
        
        // API登録(didReceivePutUnmuteTrackRequest相当)
        NSString *putUnmuteTrackRequestApiPath = [self apiPath: nil
                                                 attributeName: DConnectMediaStreamRecordingProfileAttrUnmuteTrack];
        [self addPutPath: putUnmuteTrackRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
                         
                         NSError *error = nil;
                         [weakSelf.manager unmuteTrackForTarget:target error:&error];
                         [weakSelf runMediaStreamRecordingWithError:error
                                                           response:response
                                                              state:DConnectMediaStreamRecordingProfileRecordingStateUnmutetrack];
                         return YES;
                     }];
        
        // API登録(didReceivePutOnPhotoRequest相当)
        NSString *putOnPhotoRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
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
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
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
        
        // API登録(didReceivePutOnDataAvailableRequest相当)
        NSString *putOnDataAvailableRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addPutPath: putOnDataAvailableRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                         NSString *serviceId = [request serviceId];

                         NSArray *evts = [[weakSelf eventMgr] eventListForServiceId:serviceId
                                                                  profile:DConnectMediaStreamRecordingProfileName
                                                                attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
                         if (evts.count == 0) {
                             [weakSelf profile:weakSelf didReceivePostRecordRequest:nil response:[response copy]
                                 serviceId:serviceId target:nil timeslice:nil];
                             
                             // プレビュー画像URIの配送処理が開始されていないのなら、開始する。
//                             _sendPreview = YES;
                         }
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
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
        
        // API登録(didReceiveDeleteOnPhotoRequest相当)
        NSString *deleteOnPhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
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
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
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
        
        // API登録(didReceiveDeleteOnDataAvailableRequest相当)
        NSString *deleteOnDataAvailableRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addDeletePath: deleteOnDataAvailableRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

                            NSString *serviceId = [request serviceId];
                            
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
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
                            
                            NSArray *evts = [[weakSelf eventMgr] eventListForServiceId:serviceId
                                                                     profile:DConnectMediaStreamRecordingProfileName
                                                                   attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
                            if (evts.count == 0) {
                                [weakSelf profile:weakSelf didReceivePutStopRequest:nil response:[response copy]
                                    serviceId:serviceId target:nil];
                                
                                // イベント受領先が存在しないなら、プレビュー画像URIの配送処理を停止する。
//                                _sendPreview = NO;
                                // 次回プレビュー開始時に影響を与えない為に、初期値（無効値）を設定する。
//                                _lastPreviewTimestamp = kCMTimeInvalid;
                            }
                            
                            return YES;
                        }];
        
    }
    return self;
}

- (void)dealloc
{
    // iOSデバイスの向き変更の監視をやめる
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
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
        
        DConnectManager *mgr = [DConnectManager sharedManager];
        NSString *uri = [NSString stringWithFormat:@"http://%@:%d/files?uri=%@",
                         mgr.settings.host, mgr.settings.port,
                         [DPHostUtils percentEncodeString:path withEncoding:NSUTF8StringEncoding]];
        [DConnectMediaStreamRecordingProfile setPath:uri target:photo];
        
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


- (void) sendOnDataAvailableEventWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    NSURL *fileURL;
    NSArray *evts;
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (!imageBuffer) {
            return;
        }
        CIImage *ciImage = [CIImage imageWithCVPixelBuffer:imageBuffer];
        if (!ciImage) {
            return;
        }
        
        // イベントの取得
        evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                       profile:DConnectMediaStreamRecordingProfileName
                                     attribute:DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        
        // プレビュー画像の書き出し。
        if (evts.count > 0) {
            UIImage *image = [UIImage imageWithCIImage:ciImage];
            CGSize size = image.size;
            double scale = 160000.0 / (size.width * size.height);
            size = CGSizeMake((int)(size.width * scale), (int)(size.height * scale));
            UIGraphicsBeginImageContext(size);
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
            
//            NSString *fileName = [NSString stringWithFormat:@"preview_%02d", _curPreviewImageEnumerator];
//            fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
//            if (!fileURL || ![jpegData writeToURL:fileURL atomically:NO]) {
//                return;
//            }
        } else {
            return;
        }
    }
//    _curPreviewImageEnumerator = (_curPreviewImageEnumerator + 1) % 100;
    
    DConnectURIBuilder *builder = [DConnectURIBuilder new];
    builder.profile = @"files";
    [builder addParameter:[NSString stringWithFormat:@"%@",
                           [DPHostUtils percentEncodeString:[fileURL path]
                                               withEncoding:NSUTF8StringEncoding]]
                  forName:@"uri"];
    NSString *uri = builder.build.absoluteString;
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        DConnectMessage *media = [DConnectMessage message];
        
        [DConnectMediaStreamRecordingProfile setUri:uri target:media];
        [DConnectMediaStreamRecordingProfile setMIMEType:@"image/jpeg" target:media];
        [DConnectMediaStreamRecordingProfile setMedia:media target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

#pragma mark - Private Methods

- (void)runMediaStreamRecordingWithError:(NSError *)error
                               response:(DConnectResponseMessage *)response
                                   state:(NSString *)state
{
    if (!error) {
        [response setResult:DConnectMessageResultTypeOk];
        [self sendOnRecordingChangeEventWithStatus:state
                                              path:nil
                                          mimeType:nil
                                      errorMessage:nil];
        

    } else {
        [response setError:error.code message:error.localizedDescription];
    }
}
@end
