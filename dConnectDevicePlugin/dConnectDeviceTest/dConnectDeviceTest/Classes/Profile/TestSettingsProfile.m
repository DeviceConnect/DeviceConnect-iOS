//
//  TestSettingsProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestSettingsProfile.h"

const double TestSettingsLevel = 0.5;
NSString *const TestSettingsDate = @"2014-01-01T01:01:01+09:00";

@implementation TestSettingsProfile

- (id) init {
    self = [super init];
    
    if (self) {
        
        // API登録(didReceiveGetVolumeRequest相当)
        NSString *getVolumeRequestApiPath =
        [self apiPath: DConnectSettingsProfileInterfaceSound
        attributeName: DConnectSettingsProfileAttrVolume];
        [self addGetPath: getVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            DConnectSettingsProfileVolumeKind kind = [DConnectSettingsProfile volumeKindFromRequest:request];
            
            CheckDID(response, serviceId)
            if (kind == DConnectSettingsProfileVolumeKindUnknown) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingsProfile setVolumeLevel:TestSettingsLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetDateRequest相当)
        NSString *getDateRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectSettingsProfileAttrDate];
        [self addGetPath: getDateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingsProfile setDate:TestSettingsDate target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath =
        [self apiPath: DConnectSettingsProfileInterfaceDisplay
        attributeName: DConnectSettingsProfileAttrLight];
        [self addGetPath: getLightRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingsProfile setLightLevel:TestSettingsLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetSleepRequest相当)
        NSString *getSleepRequestApiPath =
        [self apiPath: DConnectSettingsProfileInterfaceDisplay
        attributeName: DConnectSettingsProfileAttrSleep];
        [self addGetPath: getSleepRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingsProfile setTime:1 target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutVolumeRequest相当)
        NSString *putVolumeRequestApiPath =
        [self apiPath: DConnectSettingsProfileInterfaceSound
        attributeName: DConnectSettingsProfileAttrVolume];
        [self addPutPath: putVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            DConnectSettingsProfileVolumeKind kind = [DConnectSettingsProfile volumeKindFromRequest:request];
            NSNumber *level = [DConnectSettingsProfile levelFromRequest:request];
            
            CheckDID(response, serviceId)
            if (kind == DConnectSettingsProfileVolumeKindUnknown
                || level == nil || [level doubleValue] < DConnectSettingsProfileMinLevel
                || [level doubleValue] > DConnectSettingsProfileMaxLevel)
            {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutDateRequest相当)
        NSString *putDateRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectSettingsProfileAttrDate];
        [self addPutPath: putDateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *date = [DConnectSettingsProfile dateFromRequest:request];
            
            CheckDID(response, serviceId)
            if (date == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutLightRequest相当)
        NSString *putLightRequestApiPath =
        [self apiPath: DConnectSettingsProfileInterfaceDisplay
        attributeName: DConnectSettingsProfileAttrLight];
        [self addPutPath: putLightRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *level = [DConnectSettingsProfile levelFromRequest:request];
            
            CheckDID(response, serviceId)
            if (level == nil || [level doubleValue] < DConnectSettingsProfileMinLevel
                || [level doubleValue] > DConnectSettingsProfileMaxLevel)
            {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutSleepRequest相当)
        NSString *putSleepRequestApiPath =
                [self apiPath: DConnectSettingsProfileInterfaceDisplay
                attributeName: DConnectSettingsProfileAttrSleep];
        [self addPutPath: putSleepRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *time = [DConnectSettingsProfile timeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (time == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

@end
