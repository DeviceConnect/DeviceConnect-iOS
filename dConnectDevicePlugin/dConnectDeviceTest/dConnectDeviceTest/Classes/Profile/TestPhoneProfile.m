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
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
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
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

#pragma mark - Post Methods

/*
- (BOOL) profile:(DConnectPhoneProfile *)profile didReceivePostCallRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId phoneNumber:(NSString *)phoneNumber
{
    CheckDID(response, serviceId)
    if (phoneNumber == nil || phoneNumber.length == 0) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}
*/

#pragma mark - Put Methods
/*
- (BOOL) profile:(DConnectPhoneProfile *)profile didReceivePutSetRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
            mode:(NSNumber *)mode
{
    CheckDID(response, serviceId)
    if (mode == nil || [mode intValue] == DConnectPhoneProfilePhoneModeUnknown) {
        [response setErrorToInvalidRequestParameter];
    } else {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}
*/

#pragma mark Event Registration

/*
- (BOOL) profile:(DConnectPhoneProfile *)profile didReceivePutOnConnectRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
      sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:DConnectPhoneProfileAttrOnConnect forKey:DConnectMessageAttribute];
        
        DConnectMessage *phoneStatus = [DConnectMessage message];
        [DConnectPhoneProfile setPhoneNumber:@"090xxxxxxxx" target:phoneStatus];
        [DConnectPhoneProfile setState:DConnectPhoneProfileCallStateFinished target:phoneStatus];
        
        [DConnectPhoneProfile setPhoneStatus:phoneStatus target:event];
        [_plugin asyncSendEvent:event];
    }
    
    return YES;
}
*/

#pragma mark - Delete Methods
#pragma mark Event Unregistration

/*
- (BOOL) profile:(DConnectPhoneProfile *)profile didReceiveDeleteOnConnectRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
      sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}
*/

@end
