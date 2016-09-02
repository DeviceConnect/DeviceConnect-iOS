//
//  TestRemoteControllerProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestRemoteControllerProfile.h"

static NSString *const DPIRKitRemoteControllerProfileName = @"remoteController";

@implementation TestRemoteControllerProfile

- (id) init {
    
    self = [super init];
    if (self) {
        
        // API登録(didReceiveGetRequest相当)
        NSString *getRequestApiPath = [self apiPath: nil
                                      attributeName: nil];
        [self addGetPath: getRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];
                         
                         CheckDID(response, serviceId) {
                             response.result = DConnectMessageResultTypeOk;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePostRequest相当)
        NSString *postRequestApiPath = [self apiPath: nil
                                       attributeName: nil];
        [self addPostPath: postRequestApiPath
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
    return DPIRKitRemoteControllerProfileName;
}


@end
