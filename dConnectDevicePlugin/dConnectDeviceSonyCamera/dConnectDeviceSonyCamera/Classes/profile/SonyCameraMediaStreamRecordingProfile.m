//
//  SonyCameraMediaStreamRecordingProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraMediaStreamRecordingProfile.h"
#import "SonyCameraManager.h"
#import "RemoteApiList.h"

@interface SonyCameraMediaStreamRecordingProfile()

@property(nonatomic, weak) id<SampleLiveviewDelegate> mLiveViewDelegate;
@property(nonatomic, weak) id<SonyCameraRemoteApiUtilDelegate> mRemoteApiUtilDelegate;

@end

@implementation SonyCameraMediaStreamRecordingProfile

- (instancetype) initWithLiveViewDelegate: (id<SampleLiveviewDelegate>) liveViewDelegate remoteApiUtilDelegate:(id<SonyCameraRemoteApiUtilDelegate>) remoteApiUtilDelegate {
    
    self = [super init];
    if (self) {
        _mLiveViewDelegate = liveViewDelegate;
        _mRemoteApiUtilDelegate = remoteApiUtilDelegate;
        
        __weak SonyCameraMediaStreamRecordingProfile *weakSelf = self;
        
        // API登録(didReceiveGetMediaRecorderRequest相当)
        NSString *getMediaRecorderRequestApiPath = [self apiPath: nil
                                                   attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getMediaRecorderRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_getStillSize]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            // MEMO: getStillSizeは、QX10は最新のファームウェアでないとサポートしていない
            NSDictionary *dic = [manager.remoteApi getStillSize];
            if (dic) {
                NSString *aspect = dic[@"aspect"];
                NSString *size = dic[@"size"];
                
                NSArray *sizes = [aspect componentsSeparatedByString:@":"];
                NSString *widthString = sizes[0];
                NSString *heightString = sizes[1];
                int stillSize = 0;
                int width = [widthString intValue];
                int height = [heightString intValue];
                
                if ([aspect isEqualToString:@"1:1"]) {
                    if ([size isEqualToString:@"3.7M"]) {
                        stillSize = (1920 * 1920) / (width * height);
                    } else if ([size isEqualToString:@"13M"]) {
                        stillSize = (3648 * 3648) / (width * height);
                    }
                } else if ([aspect isEqualToString:@"3:2"]) {
                    if ([size isEqualToString:@"20M"]) {
                        stillSize = (5472 * 3648) / (width * height);
                    } else if ([size isEqualToString:@"5M"]) {
                        stillSize = (2736 * 1824) / (width * height);
                    }
                } else if ([aspect isEqualToString:@"4:3"]) {
                    if ([size isEqualToString:@"18M"]) {
                        stillSize = (4864 * 3648) / (width * height);
                    } else if ([size isEqualToString:@"5M"]) {
                        stillSize = (2592 * 1944) / (width * height);
                    }
                } else if ([aspect isEqualToString:@"16:9"]) {
                    if ([size isEqualToString:@"17M"]) {
                        stillSize = (5472 * 3080) / (width * height);
                    } else if ([size isEqualToString:@"4.2M"]) {
                        stillSize = (2720 * 1528) / (width * height);
                    }
                }
                
                if (stillSize == 0) {
                    [response setErrorToNotSupportAttribute];
                } else {
                    NSString *cameraStatus = manager.remoteApi.cameraStatus;
                    NSString *status = nil;
                    if ([cameraStatus isEqualToString:@"Error"] ||
                        [cameraStatus isEqualToString:@"NotReady"] ||
                        [cameraStatus isEqualToString:@"MovieSaving"] ||
                        [cameraStatus isEqualToString:@"AudioSaving"] ||
                        [cameraStatus isEqualToString:@"StillSaving"]) {
                        status = DConnectMediaStreamRecordingProfileRecorderStateInactive;
                    } else if ([cameraStatus isEqualToString:@"StillCapturing"] ||
                               [cameraStatus isEqualToString:@"MediaRecording"] ||
                               [cameraStatus isEqualToString:@"AudioRecording"] ||
                               [cameraStatus isEqualToString:@"IntervalRecording"]) {
                        status = DConnectMediaStreamRecordingProfileRecorderStateRecording;
                    } else if ([cameraStatus isEqualToString:@"MovieWaitRecStart"] ||
                               [cameraStatus isEqualToString:@"MoviewWaitRecStop"] ||
                               [cameraStatus isEqualToString:@"AudioWaitRecStart"] ||
                               [cameraStatus isEqualToString:@"AudioRecWaitRecStop"] ||
                               [cameraStatus isEqualToString:@"IntervalWaitRecStart"] ||
                               [cameraStatus isEqualToString:@"IntervalWaitRecStop"]) {
                        status = DConnectMediaStreamRecordingProfileRecorderStatePaused;
                    }
                    
                    width = width * stillSize;
                    height = height * stillSize;
                    
                    DConnectMessage *recorder = [DConnectMessage message];
                    [DConnectMediaStreamRecordingProfile setRecorderId:SERVICE_ID target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderId:@"SonyCamera" target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderName:@"SonyCamera" target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderState:status target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderMIMEType:@"image/png" target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderImageWidth:width target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderImageHeight:height target:recorder];
                    [DConnectMediaStreamRecordingProfile setRecorderConfig:@"" target:recorder];
                    
                    DConnectArray *recorders = [DConnectArray array];
                    [recorders addMessage:recorder];
                    
                    [response setResult:DConnectMessageResultTypeOk];
                    [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
                }
            } else {
                [response setErrorToNotSupportAttribute];
            }
            return YES;
        }];
        
        // API登録(didReceivePostTakePhotoRequest相当)
        NSString *postTakePhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrTakePhoto];
        [self addPostPath: postTakePhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_actTakePicture]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            // 既に撮影中はエラー
            if ([SonyCameraStatusMovieRecording isEqualToString:manager.remoteApi.cameraStatus]) {
                [response setErrorToIllegalDeviceState];
                return YES;
            }
            
            // 動画撮影モード切り替え
            if (![SonyCameraShootModePicture isEqualToString:manager.remoteApi.shootMode]
                && ![manager.remoteApi actSetShootMode:SonyCameraShootModePicture]) {
                [response setErrorToIllegalDeviceState];
                return YES;
            }
            
            if (target && ![target isEqualToString:@"SonyCamera"]) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
            
            // 写真撮影をバックグランドでAPIなどを実行
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *dict = [manager.remoteApi actTakePicture];
                if (dict == nil) {
                    [response setErrorToTimeout];
                } else {
                    NSString *errorMessage = @"";
                    NSInteger errorCode = -1;
                    NSArray *resultArray = dict[@"result"];
                    NSArray *errorArray = dict[@"error"];
                    if (errorArray && errorArray.count > 0) {
                        errorCode = (NSInteger) errorArray[0];
                        errorMessage = errorArray[1];
                    }
                    
                    // レスポンス作成
                    if (resultArray.count <= 0 && errorCode >= 0) {
                        [response setErrorToUnknown];
                    } else {
                        NSArray *arr = resultArray[0];
                        NSData *data = [manager download:arr[0]];
                        if (data) {
                            // ファイルを保存
                            NSString *uri = [manager saveFile:data];
                            [[weakSelf mRemoteApiUtilDelegate] didReceivedImage:uri];
                            if (!uri) {
                                // ファイル保存に失敗
                                [response setErrorToUnknown];
                            } else {
                                [response setResult:DConnectMessageResultTypeOk];
                                [DConnectMediaStreamRecordingProfile setPath:[uri lastPathComponent] target:response];
                                [DConnectMediaStreamRecordingProfile setUri:uri target:response];
                            }
                        } else {
                            [response setErrorToUnknown];
                        }
                    }
                }
                
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            });
            
            return NO;
        }];
        
        // API登録(didReceivePostRecordRequest相当)
        NSString *postRecordRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrRecord];
        [self addPostPath: postRecordRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_startRecMode]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            // 撮影中は、さらに撮影できないのでエラーを返す
            if ([SonyCameraStatusMovieRecording isEqualToString:manager.remoteApi.cameraStatus]) {
                [response setErrorToIllegalDeviceState];
                return YES;
            }
            
            // 動画撮影モード切り替え
            if (![SonyCameraShootModeMovie isEqualToString:manager.remoteApi.shootMode]
                && ![manager.remoteApi actSetShootMode:SonyCameraShootModeMovie]) {
                [response setErrorToIllegalDeviceState];
                return YES;
            }
            
            // 撮影開始
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *dict = [manager.remoteApi startMovieRec];
                if (dict) {
                    [response setResult:DConnectMessageResultTypeOk];
                } else {
                    [response setErrorToUnknown];
                }
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            });
            
            return NO;
        }];
        
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath = [self apiPath: nil
                                          attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // 撮影が開始されていないので、エラーを返す。
            if ([SonyCameraStatusIdle isEqualToString:manager.remoteApi.cameraStatus]) {
                [response setErrorToIllegalDeviceState];
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_stopRecMode]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            // 撮影停止
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *dict = [manager.remoteApi stopMovieRec];
                if (dict) {
                    [response setResult:DConnectMessageResultTypeOk];
                } else {
                    [response setErrorToUnknown];
                }
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            });
            
            return NO;
        }];
        
        // API登録(didReceivePutOnPhotoRequest相当)
        NSString *putOnPhotoRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *origin = [request origin];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // オリジン確認
            if (!origin) {
                [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil."];
                return YES;
            }
            
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[weakSelf.plugin class]];
            DConnectEventError error = [mgr addEventForRequest:request];
            if (error == DConnectEventErrorNone) {
                [response setResult:DConnectMessageResultTypeOk];
            } else if (error == DConnectEventErrorInvalidParameter) {
                [response setErrorToInvalidRequestParameter];
            } else {
                [response setErrorToUnknown];
            }
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnPhotoRequest相当)
        NSString *deleteOnPhotoRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *origin = [request origin];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // オリジン確認
            if (!origin) {
                [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil."];
                return YES;
            }
            
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[weakSelf.plugin class]];
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
        }];
        
        // API登録(didReceivePutOnDataAvailableRequest相当)
        NSString *putOnDataAvailableRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addPutPath: putOnDataAvailableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *origin = [request origin];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // オリジン確認
            if (!origin) {
                [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil."];
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_startLiveview]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[weakSelf.plugin class]];
            DConnectEventError error = [mgr addEventForRequest:request];
            if (error == DConnectEventErrorNone) {
                [response setResult:DConnectMessageResultTypeOk];
                // プレビュー開始
                if (![manager.remoteApi isStartedLiveView]) {
                    [manager.remoteApi actStartLiveView:[weakSelf mLiveViewDelegate]];
                }
            } else if (error == DConnectEventErrorInvalidParameter) {
                [response setErrorToInvalidRequestParameter];
            } else {
                [response setErrorToUnknown];
            }
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnDataAvailableRequest相当)
        NSString *deleteOnDataAvailableRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addDeletePath: deleteOnDataAvailableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *origin = [request origin];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // オリジン確認
            if (!origin) {
                [response setErrorToInvalidRequestParameterWithMessage:@"origin is nil."];
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_startLiveview]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[weakSelf.plugin class]];
            DConnectEventError error = [mgr removeEventForRequest:request];
            if (error == DConnectEventErrorNone) {
                [response setResult:DConnectMessageResultTypeOk];
                
                // プレビュー停止
                if ([manager.remoteApi isStartedLiveView] && ![manager hasDataAvaiableEvent]) {
                    [manager.remoteApi actStopLiveView];
                }
            } else if (error == DConnectEventErrorInvalidParameter
                       && error == DConnectEventErrorNotFound) {
                [response setErrorToInvalidRequestParameter];
            } else {
                [response setErrorToUnknown];
            }
            return YES;
        }];
        
    }
    return self;
}

@end
