//
//  TestPhoneProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestPhoneProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestPhoneProfile

- (id) init {
    self = [super init];
    
    if (self) {
        
        __weak TestPhoneProfile *weakSelf = self;
        
        // API登録(didReceivePostCallRequest相当)
        NSString *postCallRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectPhoneProfileAttrCall];
        [self addPostPath: postCallRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        
            NSString *serviceId = [request serviceId];
            NSString *phoneNumber = [DConnectPhoneProfile phoneNumberFromRequest:request];
            
            CheckDID(response, serviceId)
            if (phoneNumber == nil || phoneNumber.length == 0) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutSetRequest相当)
        NSString *putSetRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectPhoneProfileAttrSet];
        [self addPutPath: putSetRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSNumber *mode = [DConnectPhoneProfile modeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (mode == nil || [mode intValue] == DConnectPhoneProfilePhoneModeUnknown) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnConnectRequest相当)
        NSString *putOnConnectRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectPhoneProfileAttrOnConnect];
        [self addPutPath: putOnConnectRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:DConnectPhoneProfileAttrOnConnect forKey:DConnectMessageAttribute];
                
                DConnectMessage *phoneStatus = [DConnectMessage message];
                [DConnectPhoneProfile setPhoneNumber:@"090xxxxxxxx" target:phoneStatus];
                [DConnectPhoneProfile setState:DConnectPhoneProfileCallStateFinished target:phoneStatus];
                
                [DConnectPhoneProfile setPhoneStatus:phoneStatus target:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnConnectRequest相当)
        NSString *deleteOnConnectRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectPhoneProfileAttrOnConnect];
        [self addDeletePath: deleteOnConnectRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

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
