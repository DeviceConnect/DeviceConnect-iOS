//
//  TestDriveControllerProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestDriveControllerProfile.h"

static NSString *const DCMDriveControllerProfileName = @"driveController";

static NSString *const DCMDriveControllerProfileAttrMove = @"move";
static NSString *const DCMDriveControllerProfileAttrStop = @"stop";
static NSString *const DCMDriveControllerProfileAttrRotate = @"rotate";
static NSString *const DCMDriveControllerProfileParamAngle = @"angle";
static NSString *const DCMDriveControllerProfileParamSpeed = @"speed";

@implementation TestDriveControllerProfile

- (id) init {
    self = [super init];
    
    if (self) {
        
        // API登録(didReceivePostDriveControllerMoveRequest相当)
        NSString *postDriveControllerMoveRequestApiPath = [self apiPath: nil
                                                          attributeName: DCMDriveControllerProfileAttrMove];
        [self addPostPath: postDriveControllerMoveRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
                          NSString *serviceId = [request serviceId];
                          
                          CheckDID(response, serviceId) {
                              response.result = DConnectMessageResultTypeOk;
                          }
                          
                          return YES;
                      }];
        
        // API登録(didReceivePutDriveControllerRotateRequest相当)
        NSString *putDriveControllerRotateRequestApiPath = [self apiPath: nil
                                                           attributeName: DCMDriveControllerProfileAttrRotate];
        [self addPutPath: putDriveControllerRotateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CheckDID(response, serviceId) {
                             response.result = DConnectMessageResultTypeOk;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteDriveControllerStopRequest相当)
        NSString *deleteDriveControllerStopRequestApiPath = [self apiPath: nil
                                                            attributeName: DCMDriveControllerProfileAttrStop];
        [self addDeletePath: deleteDriveControllerStopRequestApiPath
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
    return DCMDriveControllerProfileName;
}

@end
