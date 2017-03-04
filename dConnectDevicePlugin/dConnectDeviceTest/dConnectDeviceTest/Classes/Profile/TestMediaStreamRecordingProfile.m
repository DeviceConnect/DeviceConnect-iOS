//
//  TestMediaStreamRecordingProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestMediaStreamRecordingProfile.h"
#import "DeviceTestPlugin.h"


NSString *const TestMediaStreamID = @"test_camera_id";
NSString *const TestMediaStreamName = @"test_camera_name";
const int TestMediaStreamImageWidth = 1920;
const int TestMediaStreamImageHeight = 1080;
NSString *const TestMediaStreamMimeType = @"video/mp4";
NSString *const TestMediaStreamConfig = @"test_config";
NSString *const TestMediaStreamUri = @"content://test/test.mp4";
NSString *const TestMediaStreamPhotoPath = @"test.png";
NSString *const TestMediaStreamVideoPath = @"test.mp4";


@implementation TestMediaStreamRecordingProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestMediaStreamRecordingProfile *weakSelf = self;
        
        // API登録(didReceiveGetMediaRecorderRequest相当)
        NSString *getMediaRecorderRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrMediaRecorder];
        [self addGetPath: getMediaRecorderRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                DConnectArray *recorders = [DConnectArray array];
                
                DConnectMessage *recorder = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setRecorderId:TestMediaStreamID target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderName:TestMediaStreamName target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderState:DConnectMediaStreamRecordingProfileRecorderStateInactive
                                                               target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderImageWidth:TestMediaStreamImageWidth target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderImageHeight:TestMediaStreamImageHeight target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderMIMEType:TestMediaStreamMimeType target:recorder];
                [DConnectMediaStreamRecordingProfile setRecorderConfig:TestMediaStreamConfig target:recorder];
                
                [recorders addMessage:recorder];
                [DConnectMediaStreamRecordingProfile setRecorders:recorders target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetOptionsRequest相当)
        NSString *getOptionsRequestRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOptions];
        [self addGetPath: getOptionsRequestRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                DConnectMessage *imageWidth = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setMin:0 target:imageWidth];
                [DConnectMediaStreamRecordingProfile setMax:0 target:imageWidth];
                [DConnectMediaStreamRecordingProfile setImageWidth:imageWidth target:response];
                
                DConnectMessage *imageHeight = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setMin:0 target:imageHeight];
                [DConnectMediaStreamRecordingProfile setMax:0 target:imageHeight];
                [DConnectMediaStreamRecordingProfile setImageHeight:imageHeight target:response];
                
                DConnectArray *mimeTypes = [DConnectArray array];
                [mimeTypes addString:TestMediaStreamMimeType];
                [DConnectMediaStreamRecordingProfile setMIMETypes:mimeTypes target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePostTakePhotoRequest相当)
        NSString *postTakePhotoRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrTakePhoto];
        [self addPostPath: postTakePhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:response];
                [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamPhotoPath target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePostRecordRequest相当)
        NSString *postRecordRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrRecord];
        [self addPostPath: postRecordRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:response];
                [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamVideoPath target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            
            CheckDID(response, serviceId)
            if (target != nil && target.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            
            CheckDID(response, serviceId)
            if (target != nil && target.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrStop];
        [self addPutPath: putStopRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

            CheckDID(response, serviceId)
            if (target != nil && target.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutMuteTrackRequest相当)
        NSString *putMuteTrackRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrMuteTrack];
        [self addPutPath: putMuteTrackRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

            CheckDID(response, serviceId)
            if (target != nil && target.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutUnmuteTrackRequest相当)
        NSString *putUnmuteTrackRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrUnmuteTrack];
        [self addPutPath: putUnmuteTrackRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];

            CheckDID(response, serviceId)
            if (target != nil && target.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOptionsRequest相当)
        NSString *putOptionsRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOptions];
        [self addPutPath: putOptionsRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *target = [DConnectMediaStreamRecordingProfile targetFromRequest:request];
            NSNumber *imageWidth = [DConnectMediaStreamRecordingProfile imageWidthFromRequest:request];
            NSNumber *imageHeight = [DConnectMediaStreamRecordingProfile imageHeightFromRequest:request];
            NSString *mimeType = [DConnectMediaStreamRecordingProfile mimeTypeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (target == nil || target.length == 0
                || imageWidth == nil || imageHeight == nil
                || mimeType == nil || mimeType.length == 0)
            {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnPhotoRequest相当)
        NSString *putOnPhotoRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addPutPath: putOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectMediaStreamRecordingProfileAttrOnPhoto forKey:DConnectMessageAttribute];
                
                DConnectMessage *photo = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamPhotoPath target:photo];
                [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:photo];
                [DConnectMediaStreamRecordingProfile setPhoto:photo target:event];
                [[weakSelf plugin] asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnRecordingChangeRequest相当)
        NSString *putOnRecordingChangeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addPutPath: putOnRecordingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectMediaStreamRecordingProfileAttrOnRecordingChange
                          forKey:DConnectMessageAttribute];
                
                DConnectMessage *media = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setStatus:DConnectMediaStreamRecordingProfileRecordingStateRecording
                                                        target:media];
                [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:media];
                [DConnectMediaStreamRecordingProfile setPath:TestMediaStreamVideoPath target:media];
                [DConnectMediaStreamRecordingProfile setMedia:media target:event];
                [[weakSelf plugin] asyncSendEvent:event];
            }
            
            
            return YES;
        }];
        
        // API登録(didReceivePutOnDataAvailableRequest相当)
        NSString *putOnDataAvailableRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addPutPath: putOnDataAvailableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectMediaStreamRecordingProfileAttrOnDataAvailable
                          forKey:DConnectMessageAttribute];
                
                DConnectMessage *media = [DConnectMessage message];
                [DConnectMediaStreamRecordingProfile setMIMEType:TestMediaStreamMimeType target:media];
                [DConnectMediaStreamRecordingProfile setUri:TestMediaStreamUri target:media];
                [DConnectMediaStreamRecordingProfile setMedia:media target:event];
                [[weakSelf plugin] asyncSendEvent:event];
            }
            
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnPhotoRequest相当)
        NSString *deleteOnPhotoRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnPhoto];
        [self addDeletePath: deleteOnPhotoRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnRecordingChangeRequest相当)
        NSString *deleteOnRecordingChangeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnRecordingChange];
        [self addDeletePath: deleteOnRecordingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnDataAvailableRequest相当)
        NSString *deleteOnDataAvailableRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaStreamRecordingProfileAttrOnDataAvailable];
        [self addDeletePath: deleteOnDataAvailableRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];

            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

@end
