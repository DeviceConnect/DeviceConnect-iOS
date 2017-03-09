//
//  TestMediaPlayerProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestMediaPlayerProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestMediaPlayerProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestMediaPlayerProfile *weakSelf = self;
        
        // API登録(didReceiveGetPlayStatusRequest相当)
        NSString *getPlayStatusRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectMediaPlayerProfileAttrPlayStatus];
        [self addGetPath: getPlayStatusRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setStatus:DConnectMediaPlayerProfileStatusPlay target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetMediaRequest相当)
        NSString *getMediaRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addGetPath: getMediaRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
            
            CheckDID(response, serviceId)
            if (mediaId == nil || mediaId.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setMIMEType:@"audio/mp3" target:response];
                [DConnectMediaPlayerProfile setTitle:@"test title" target:response];
                [DConnectMediaPlayerProfile setType:@"test type" target:response];
                [DConnectMediaPlayerProfile setLanguage:@"ja" target:response];
                [DConnectMediaPlayerProfile setDescription:@"test description" target:response];
                [DConnectMediaPlayerProfile setDuration:60000 target:response];
                
                DConnectMessage *creator = [DConnectMessage message];
                [DConnectMediaPlayerProfile setCreator:@"test creator" target:creator];
                [DConnectMediaPlayerProfile setRole:@"test composer" target:creator];
                
                DConnectArray *creators = [DConnectArray array];
                [creators addMessage:creator];
                
                DConnectArray *keywords = [DConnectArray array];
                [keywords addString:@"keyword1"];
                [keywords addString:@"keyword2"];
                
                DConnectArray *genres = [DConnectArray array];
                [genres addString:@"test1"];
                [genres addString:@"test2"];
                
                [DConnectMediaPlayerProfile setCreators:creators target:response];
                [DConnectMediaPlayerProfile setKeywords:keywords target:response];
                [DConnectMediaPlayerProfile setGenres:genres target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetMediaListRequest相当)
        NSString *getMediaListRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrMediaList];
        [self addGetPath: getMediaListRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *orderStr = [DConnectMediaPlayerProfile orderFromRequest:request];
            NSArray *order = nil;
            if (orderStr) {
                order = [orderStr componentsSeparatedByString:@","];
            }

            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setCount:1 target:response];
                
                DConnectMessage *medium = [DConnectMessage message];
                [DConnectMediaPlayerProfile setMediaId:@"media001" target:medium];
                [DConnectMediaPlayerProfile setMIMEType:@"audio/mp3" target:medium];
                [DConnectMediaPlayerProfile setTitle:@"test title" target:medium];
                [DConnectMediaPlayerProfile setType:@"test type" target:medium];
                [DConnectMediaPlayerProfile setLanguage:@"ja" target:medium];
                [DConnectMediaPlayerProfile setDescription:@"test description" target:medium];
                [DConnectMediaPlayerProfile setDuration:60000 target:medium];
                
                DConnectMessage *creator = [DConnectMessage message];
                [DConnectMediaPlayerProfile setCreator:@"test creator" target:creator];
                [DConnectMediaPlayerProfile setRole:@"test composer" target:creator];
                
                DConnectArray *creators = [DConnectArray array];
                [creators addMessage:creator];
                
                DConnectArray *keywords = [DConnectArray array];
                [keywords addString:@"keyword1"];
                [keywords addString:@"keyword2"];
                
                DConnectArray *genres = [DConnectArray array];
                [genres addString:@"test1"];
                [genres addString:@"test2"];
                
                [DConnectMediaPlayerProfile setCreators:creators target:medium];
                [DConnectMediaPlayerProfile setKeywords:keywords target:medium];
                [DConnectMediaPlayerProfile setGenres:genres target:medium];
                
                DConnectArray *media = [DConnectArray array];
                [media addMessage:medium];
                
                [DConnectMediaPlayerProfile setMedia:media target:response];
            }
            
            
            return YES;
        }];
        
        // API登録(didReceiveGetSeekRequest相当)
        NSString *getSeekRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addGetPath: getSeekRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setPos:0 target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetVolumeRequest相当)
        NSString *getVolumeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrVolume];
        [self addGetPath: getVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setVolume:0 target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetMuteRequest相当)
        NSString *getMuteRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addGetPath: getMuteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectMediaPlayerProfile setMute:YES target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutMediaRequest相当)
        NSString *putMediaRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrMedia];
        [self addPutPath: putMediaRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *mediaId = [DConnectMediaPlayerProfile mediaIdFromRequest:request];
            
            CheckDID(response, serviceId)
            if (mediaId == nil || mediaId.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutPlayRequest相当)
        NSString *putPlayRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrPlay];
        [self addPutPath: putPlayRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutStopRequest相当)
        NSString *putStopRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrStop];
        [self addPutPath: putStopRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutPauseRequest相当)
        NSString *putPauseRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrPause];
        [self addPutPath: putPauseRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutResumeRequest相当)
        NSString *putResumeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrResume];
        [self addPutPath: putResumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutSeekRequest相当)
        NSString *putSeekRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrSeek];
        [self addPutPath: putSeekRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *pos = [DConnectMediaPlayerProfile posFromRequest:request];
            
            CheckDID(response, serviceId)
            if (pos == nil || pos < 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnStatusChangeRequest相当)
        NSString *putOnStatusChangeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addPutPath: putOnStatusChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionkey = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, sessionkey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionkey forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:[weakSelf profileName] forKey:DConnectMessageProfile];
                [event setString:DConnectMediaPlayerProfileAttrOnStatusChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *mediaPlayer = [DConnectMessage message];
                [DConnectMediaPlayerProfile setStatus:DConnectMediaPlayerProfileStatusPlay target:mediaPlayer];
                [DConnectMediaPlayerProfile setMediaId:@"test.mp4" target:mediaPlayer];
                [DConnectMediaPlayerProfile setMIMEType:@"video/mp4" target:mediaPlayer];
                [DConnectMediaPlayerProfile setPos:0 target:mediaPlayer];
                [DConnectMediaPlayerProfile setVolume:0.5 target:mediaPlayer];
                
                [DConnectMediaPlayerProfile setMediaPlayer:mediaPlayer target:event];
                [[weakSelf plugin] asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutVolumeRequest相当)
        NSString *putVolumeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrVolume];
        [self addPutPath: putVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *volume = [DConnectMediaPlayerProfile volumeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (volume == nil || [volume doubleValue] < 0.0 || [volume doubleValue] > 1.0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutMuteRequest相当)
        NSString *putMuteRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addPutPath: putMuteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteMuteRequest相当)
        NSString *deleteMuteRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrMute];
        [self addDeletePath: deleteMuteRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnStatusChangeRequest相当)
        NSString *deleteOnStatusChangeRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectMediaPlayerProfileAttrOnStatusChange];
        [self addDeletePath: deleteOnStatusChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionkey = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, sessionkey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

@end
