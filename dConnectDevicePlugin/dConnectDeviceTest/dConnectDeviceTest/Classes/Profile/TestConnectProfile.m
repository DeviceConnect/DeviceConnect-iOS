//
//  TestConnectProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestConnectProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestConnectProfile

#pragma mark - init

- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _plugin = plugin;
    }
    
    return self;
}

#pragma mark - DConnectConnectProfileDelegate
#pragma mark - Get Methods

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveGetWifiRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectConnectProfile setEnable:YES target:response];
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveGetBluetoothRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectConnectProfile setEnable:YES target:response];
    }
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveGetBLERequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectConnectProfile setEnable:YES target:response];
    }

    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveGetNFCRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [DConnectConnectProfile setEnable:YES target:response];
    }
    return YES;
}

#pragma mark - Put Methods

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutWiFiRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutBluetoothRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutBluetoothDiscoverableRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutBLERequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutNFCRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }

    return YES;
}

#pragma mark Event Registration

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutOnWifiChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectConnectProfileAttrOnWifiChange forKey:DConnectMessageAttribute];
        
        DConnectMessage *connectStatus = [DConnectMessage message];
        [DConnectConnectProfile setEnable:YES target:connectStatus];
        
        [DConnectConnectProfile setConnectStatus:connectStatus target:event];
        [_plugin asyncSendEvent:event];

    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutOnBluetoothChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectConnectProfileAttrOnBluetoothChange forKey:DConnectMessageAttribute];
        
        DConnectMessage *connectStatus = [DConnectMessage message];
        [DConnectConnectProfile setEnable:YES target:connectStatus];
        
        [DConnectConnectProfile setConnectStatus:connectStatus target:event];
        [_plugin asyncSendEvent:event];

    }
    
    return YES;
}


- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutOnBLEChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectConnectProfileAttrOnBLEChange forKey:DConnectMessageAttribute];
        
        DConnectMessage *connectStatus = [DConnectMessage message];
        [DConnectConnectProfile setEnable:YES target:connectStatus];
        
        [DConnectConnectProfile setConnectStatus:connectStatus target:event];
        [_plugin asyncSendEvent:event];
        
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceivePutOnNFCChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectConnectProfileAttrOnNFCChange forKey:DConnectMessageAttribute];
        
        DConnectMessage *connectStatus = [DConnectMessage message];
        [DConnectConnectProfile setEnable:YES target:connectStatus];
        
        [DConnectConnectProfile setConnectStatus:connectStatus target:event];
        [_plugin asyncSendEvent:event];
        
    }
    
    return YES;
}

#pragma mark - Delete Methods

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteWiFiRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}


- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteBluetoothRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}


- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteBluetoothDiscoverableRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteBLERequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteNFCRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

#pragma mark Event Unregistration

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteOnWifiChangeRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}
- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteOnBluetoothChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteOnBLEChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

- (BOOL) profile:(DConnectConnectProfile *)profile didReceiveDeleteOnNFCChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    return YES;
}

@end
