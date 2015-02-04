//
//  TestBatteryProfile.m
//  DConnectSDK
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

- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _plugin = plugin;
    }
    
    return self;
}

#pragma mark - DConnectBatteryProfileDelegate

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveGetAllRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectBatteryProfile setCharging:TestBatteryCharging target:response];
        [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:response];
        [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:response];
        [DConnectBatteryProfile setLevel:TestBatteryLevel target:response];
    }
    
    return YES;
}

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveGetLevelRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectBatteryProfile setLevel:TestBatteryLevel target:response];
    }
    
    return YES;
}

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveGetChargingRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectBatteryProfile setCharging:TestBatteryCharging target:response];
    }
    
    return YES;
}

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveGetChargingTimeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:response];
    }
    
    return YES;
}

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveGetDischargingTimeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:response];
    }
    
    return YES;
}

#pragma mark - Put Methods
#pragma mark Event Registration

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceivePutOnChargingChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
      sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectBatteryProfileAttrOnChargingChange forKey:DConnectMessageAttribute];
        
        DConnectMessage *battery = [DConnectMessage message];
        [DConnectBatteryProfile setCharging:TestBatteryCharging target:battery];
        
        [DConnectBatteryProfile setBattery:battery target:event];
        [_plugin asyncSendEvent:event];
    }
        
    return YES;
}

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceivePutOnBatteryChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectBatteryProfileAttrOnBatteryChange forKey:DConnectMessageAttribute];
        
        
        DConnectMessage *battery = [DConnectMessage message];
        [DConnectBatteryProfile setChargingTime:TestBatteryChargingTime target:battery];
        [DConnectBatteryProfile setDischargingTime:TestBatteryDischargingTime target:battery];
        [DConnectBatteryProfile setLevel:TestBatteryLevel target:battery];
        
        [DConnectBatteryProfile setBattery:battery target:event];
        [_plugin asyncSendEvent:event];
    }

    
    return YES;
}

#pragma mark - Delete Methods

- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveDeleteOnChargingChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}
- (BOOL) profile:(DConnectBatteryProfile *)profile didReceiveDeleteOnBatteryChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}


@end
