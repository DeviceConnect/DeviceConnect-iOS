//
//  TestOmnidirectionalImageProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestOmnidirectionalImageProfile.h"

static NSString *const DPOmnidirectionalImageProfileName = @"omnidirectionalImage";
static NSString *const DPOmnidirectionalImageProfileInterfaceROI = @"roi";
static NSString *const DPOmnidirectionalImageProfileAttrROI = @"roi";
static NSString *const DPOmnidirectionalImageProfileAttrSettings = @"settings";

@implementation TestOmnidirectionalImageProfile

- (id) init {
    
    self = [super init];
    if (self) {
        
        // API登録(didReceiveGetRoiRequest相当)
        NSString *getRoiRequestApiPath = [self apiPath: nil
                                         attributeName: DPOmnidirectionalImageProfileAttrROI];
        [self addGetPath: getRoiRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CheckDID(response, serviceId) {
                             response.result = DConnectMessageResultTypeOk;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutRoiRequest相当)
        NSString *putRoiRequestApiPath = [self apiPath: nil
                                         attributeName: DPOmnidirectionalImageProfileAttrROI];
        [self addPutPath: putRoiRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CheckDID(response, serviceId) {
                             response.result = DConnectMessageResultTypeOk;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutRoiSettingsRequest相当)
        NSString *putRoiSettingsRequestApiPath = [self apiPath: DPOmnidirectionalImageProfileInterfaceROI
                                                 attributeName: DPOmnidirectionalImageProfileAttrSettings];
        [self addPutPath: putRoiSettingsRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CheckDID(response, serviceId) {
                             response.result = DConnectMessageResultTypeOk;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteRoiRequest相当)
        NSString *deleteRoiRequestApiPath = [self apiPath: nil
                                            attributeName: DPOmnidirectionalImageProfileAttrROI];
        [self addDeletePath: deleteRoiRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            
                            CheckDID(response, serviceId) {
                                response.result = DConnectMessageResultTypeOk;
                            }
                            
                            return YES;
                        }];
    }
    return self;
}

- (NSString *) profileName {
    return DPOmnidirectionalImageProfileName;
}

@end
