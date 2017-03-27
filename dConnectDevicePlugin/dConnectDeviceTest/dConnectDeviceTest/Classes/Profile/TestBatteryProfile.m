//
//  TestBatteryProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DeviceTestPlugin.h"
#import "TestBatteryProfile.h"


const double TestBatteryChargingTime = 50000.0;
const double TestBatteryDischargingTime = 10000.0;
const double TestBatteryLevel = 0.5;
const BOOL TestBatteryCharging = NO;
@implementation TestBatteryProfile
- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestBatteryProfile *weakSelf = self;
        
        // API登録(didReceiveGetAllRequest相当)
        NSString *getAllRequestApiPath = [self apiPath: nil
                                         attributeName: nil];
        [self addGetPath: getAllRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectBatteryProfile setCharging:TestBatteryCharging target:response];
                [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:response];
                [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:response];
                [DConnectBatteryProfile setLevel:TestBatteryLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetLevelRequest相当)
        NSString *getLevelRequestApiPath = [self apiPath: nil
                                           attributeName: DConnectBatteryProfileAttrLevel];
        [self addGetPath: getLevelRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectBatteryProfile setLevel:TestBatteryLevel target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetChargingRequest相当)
        NSString *getChargingRequestApiPath = [self apiPath: nil
                                              attributeName: DConnectBatteryProfileAttrCharging];
        [self addGetPath: getChargingRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectBatteryProfile setCharging:TestBatteryCharging target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetChargingTimeRequest相当)
        NSString *getChargingTimeRequestApiPath = [self apiPath: nil
                                              attributeName: DConnectBatteryProfileAttrChargingTime];
        [self addGetPath: getChargingTimeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:response];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveGetDischargingTimeRequest相当)
        NSString *getDishargingTimeRequestApiPath = [self apiPath: nil
                                                  attributeName: DConnectBatteryProfileAttrDischargingTime];
        [self addGetPath: getDishargingTimeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:response];
            }
            
            return YES;
        }];

        // API登録(didReceivePutOnChargingChangeRequest相当)
        NSString *putOnChargingChangeRequestApiPath = [self apiPath: nil
                                                      attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addPutPath: putOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectBatteryProfileAttrOnChargingChange forKey:DConnectMessageAttribute];
                
                DConnectMessage *battery = [DConnectMessage message];
                [DConnectBatteryProfile setCharging:TestBatteryCharging target:battery];
                [DConnectBatteryProfile setBattery:battery target:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
        
            return YES;
        }];
    
        // API登録(didReceivePutOnBatteryChangeRequest相当)
        NSString *putOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                     attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addPutPath: putOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {

            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:accessToken forKey:DConnectMessageAccessToken];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectBatteryProfileAttrOnBatteryChange forKey:DConnectMessageAttribute];
                
                
                DConnectMessage *battery = [DConnectMessage message];
                [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:battery];
                [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:battery];
                [DConnectBatteryProfile setLevel:TestBatteryLevel target:battery];
                
                [DConnectBatteryProfile setBattery:battery target:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            
            return YES;
        }];
        // API登録(didReceiveDeleteOnChargingChangeRequest相当)
        NSString *deleteOnChargingChangeRequestApiPath = [self apiPath: nil
                                                         attributeName: DConnectBatteryProfileAttrOnChargingChange];
        [self addDeletePath: deleteOnChargingChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *accessToken = [request accessToken];
            
            CheckDIDAndSK(response, serviceId, accessToken) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
        // API登録(didReceiveDeleteOnBatteryChangeRequest相当)
        NSString *deleteOnBatteryChangeRequestApiPath = [self apiPath: nil
                                                        attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addDeletePath: deleteOnBatteryChangeRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
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
