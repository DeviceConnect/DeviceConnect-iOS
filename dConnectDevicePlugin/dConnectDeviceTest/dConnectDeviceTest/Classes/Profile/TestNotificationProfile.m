//
//  TestNotificationProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestNotificationProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestNotificationProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestNotificationProfile *weakSelf = self;
        
        // API登録(didReceivePostNotifyRequest相当)
        NSString *postNotifyRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrNotify];
        [self addPostPath: postNotifyRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
            
            CheckDID(response, serviceId)
            if (type == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                NSString *_id = nil;
                switch ([type intValue]) {
                    case DConnectNotificationProfileNotificationTypePhone:
                        _id = @"1";
                        break;
                    case DConnectNotificationProfileNotificationTypeMail:
                        _id = @"2";
                        break;
                    case DConnectNotificationProfileNotificationTypeSMS:
                        _id = @"3";
                        break;
                    case DConnectNotificationProfileNotificationTypeEvent:
                        _id = @"4";
                        break;
                    case DConnectNotificationProfileNotificationTypeUnknown:
                        _id = @"5";
                        break;
                        
                    default:
                        [response setErrorToInvalidRequestParameter];
                        break;
                }
                
                if (_id) {
                    response.result = DConnectMessageResultTypeOk;
                    [DConnectNotificationProfile setNotificationId:_id target:response];
                }
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnClickRequest相当)
        NSString *putOnClickRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnClick];
        [self addPutPath: putOnClickRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectNotificationProfileAttrOnClick forKey:DConnectMessageAttribute];
                [DConnectNotificationProfile setNotificationId:@"1" target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnShowRequest相当)
        NSString *putOnShowRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnShow];
        [self addPutPath: putOnShowRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectNotificationProfileAttrOnShow forKey:DConnectMessageAttribute];
                [DConnectNotificationProfile setNotificationId:@"1" target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnCloseRequest相当)
        NSString *putOnCloseRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnClose];
        [self addPutPath: putOnCloseRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectNotificationProfileAttrOnClose forKey:DConnectMessageAttribute];
                [DConnectNotificationProfile setNotificationId:@"1" target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnErrorRequest相当)
        NSString *putOnErrorRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnError];
        [self addPutPath: putOnErrorRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectNotificationProfileAttrOnError forKey:DConnectMessageAttribute];
                [DConnectNotificationProfile setNotificationId:@"1" target:event];
                [weakSelf.plugin asyncSendEvent:event];
                
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteNotifyRequest相当)
        NSString *deleteNotifyRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrNotify];
        [self addDeletePath: deleteNotifyRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *notificationId = [DConnectNotificationProfile notificationIdFromRequest:request];
            
            CheckDID(response, serviceId)
            if (notificationId == nil) {
                [response setErrorToInvalidRequestParameter];
            } else {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnClickRequest相当)
        NSString *deleteOnClickRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnClick];
        [self addDeletePath: deleteOnClickRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnShowRequest相当)
        NSString *deleteOnShowRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnShow];
        [self addDeletePath: deleteOnShowRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnCloseRequest相当)
        NSString *deleteOnCloseRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnClose];
        [self addDeletePath: deleteOnCloseRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnErrorRequest相当)
        NSString *deleteOnErrorRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectNotificationProfileAttrOnError];
        [self addDeletePath: deleteOnErrorRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
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
