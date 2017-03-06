//
//  TestSettingProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestSettingProfile.h"

const double TestSettingLevel = 0.5;
NSString *const TestSettingDate = @"2014-01-01T01:01:01+09:00";

@implementation TestSettingProfile

- (id) init {
    self = [super init];
    
    if (self) {
        
        // API登録(didReceiveGetVolumeRequest相当)
        NSString *getVolumeRequestApiPath =
        [self apiPath: DConnectSettingProfileInterfaceSound
        attributeName: DConnectSettingProfileAttrVolume];
        [self addGetPath: getVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            DConnectSettingProfileVolumeKind kind = [DConnectSettingProfile volumeKindFromRequest:request];
            
            CheckDID(response, serviceId)
            if (kind == DConnectSettingProfileVolumeKindUnknown) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingProfile setVolumeLevel:TestSettingLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetDateRequest相当)
        NSString *getDateRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectSettingProfileAttrDate];
        [self addGetPath: getDateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingProfile setDate:TestSettingDate target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetLightRequest相当)
        NSString *getLightRequestApiPath =
        [self apiPath: DConnectSettingProfileInterfaceDisplay
        attributeName: DConnectSettingProfileAttrBrightness];
        [self addGetPath: getLightRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingProfile setLightLevel:TestSettingLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetSleepRequest相当)
        NSString *getSleepRequestApiPath =
        [self apiPath: DConnectSettingProfileInterfaceDisplay
        attributeName: DConnectSettingProfileAttrSleep];
        [self addGetPath: getSleepRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectSettingProfile setTime:1 target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutVolumeRequest相当)
        NSString *putVolumeRequestApiPath =
        [self apiPath: DConnectSettingProfileInterfaceSound
        attributeName: DConnectSettingProfileAttrVolume];
        [self addPutPath: putVolumeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            DConnectSettingProfileVolumeKind kind = [DConnectSettingProfile volumeKindFromRequest:request];
            NSNumber *level = [DConnectSettingProfile levelFromRequest:request];
            
            CheckDID(response, serviceId)
            if (kind == DConnectSettingProfileVolumeKindUnknown
                || level == nil || [level doubleValue] < DConnectSettingProfileMinLevel
                || [level doubleValue] > DConnectSettingProfileMaxLevel)
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
        attributeName: DConnectSettingProfileAttrDate];
        [self addPutPath: putDateRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *date = [DConnectSettingProfile dateFromRequest:request];
            
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
        [self apiPath: DConnectSettingProfileInterfaceDisplay
        attributeName: DConnectSettingProfileAttrBrightness];
        [self addPutPath: putLightRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *level = [DConnectSettingProfile levelFromRequest:request];
            
            CheckDID(response, serviceId)
            if (level == nil || [level doubleValue] < DConnectSettingProfileMinLevel
                || [level doubleValue] > DConnectSettingProfileMaxLevel)
            {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutSleepRequest相当)
        NSString *putSleepRequestApiPath =
                [self apiPath: DConnectSettingProfileInterfaceDisplay
                attributeName: DConnectSettingProfileAttrSleep];
        [self addPutPath: putSleepRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *time = [DConnectSettingProfile timeFromRequest:request];
            
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
