//
//  TestProximityProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestProximityProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestProximityProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestProximityProfile *weakSelf = self;

        // API登録(didReceiveGetOnDeviceProximityRequest相当)
        NSString *getOnDeviceProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnDeviceProximity];
        [self addGetPath: getOnDeviceProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
        
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                
                [weakSelf setDeviceProximity:response];
            }
            return YES;
        }];
        
        // API登録(didReceiveGetOnUserProximityRequest相当)
        NSString *getOnUserProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addGetPath: getOnUserProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                
                [weakSelf setUserProximity:response];
            }
            return YES;
        }];
        
        // API登録(didReceivePutOnDeviceProximityRequest相当)
        NSString *putOnDeviceProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnDeviceProximity];
        [self addPutPath: putOnDeviceProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectProximityProfileAttrOnDeviceProximity forKey:DConnectMessageAttribute];
                [weakSelf setDeviceProximity:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceivePutOnUserProximityRequest相当)
        NSString *putOnUserProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addPutPath: putOnUserProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectProximityProfileAttrOnUserProximity forKey:DConnectMessageAttribute];
                [weakSelf setUserProximity:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnDeviceProximityRequest相当)
        NSString *deleteOnDeviceProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnDeviceProximity];
        [self addDeletePath: deleteOnDeviceProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnUserProximityRequest相当)
        NSString *deleteOnUserProximityRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectProximityProfileAttrOnUserProximity];
        [self addDeletePath: deleteOnUserProximityRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
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

- (void) setDeviceProximity:(DConnectMessage *)message
{
    DConnectMessage *proximity = [DConnectMessage message];
    [DConnectProximityProfile setValue:0 target:proximity];
    [DConnectProximityProfile setMax:0 target:proximity];
    [DConnectProximityProfile setMin:0 target:proximity];
    [DConnectProximityProfile setThreshold:0 target:proximity];
    [DConnectProximityProfile setProximity:proximity target:message];
}

- (void) setUserProximity:(DConnectMessage *)message
{
    DConnectMessage *proximity = [DConnectMessage message];
    [DConnectProximityProfile setNear:true target:proximity];
    [DConnectProximityProfile setProximity:proximity target:message];
}

@end
