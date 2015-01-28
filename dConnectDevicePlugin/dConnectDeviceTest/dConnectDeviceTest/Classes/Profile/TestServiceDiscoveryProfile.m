//
//  TestServiceDiscoveryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestServiceDiscoveryProfile.h"
#import "DeviceTestPlugin.h"

NSString *const TestNetworkServiceIdSpecialCharacters = @"!#$'()-~¥@[;+:*],._/=?&%^|`\"{}<>";
NSString *const TestNetworkDeviceName = @"Test Success Device";
NSString *const TestNetworkDeviceNameSpecialCharacters = @"Test Service ID Special Characters";
NSString *const TestNetworkDeviceType = @"TEST";
const BOOL TestNetworkDeviceOnline = YES;
NSString *const TestNetworkDeviceConfig = @"test config";

@implementation TestServiceDiscoveryProfile

- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin {
    self = [super init];
    
    if (self) {
        self.delegate = self;
        _plugin = plugin;
    }
    
    return self;
}

#pragma mark DConnectServiceDiscoveryProfileDelegate

#pragma mark - Get Methods

- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceiveGetGetNetworkServicesRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
{
    
    DConnectArray *services = [DConnectArray array];
    
    // 典型的なサービス
    DConnectMessage *service = [DConnectMessage message];
    [DConnectServiceDiscoveryProfile setId:TDPServiceId target:service];
    [DConnectServiceDiscoveryProfile setName:TestNetworkDeviceName target:service];
    [DConnectServiceDiscoveryProfile setType:TestNetworkDeviceType target:service];
    [DConnectServiceDiscoveryProfile setOnline:TestNetworkDeviceOnline target:service];
    [DConnectServiceDiscoveryProfile setConfig:TestNetworkDeviceConfig target:service];
    [services addMessage:service];
    
    // サービスIDが特殊なサービス
    service = [DConnectMessage message];
    [DConnectServiceDiscoveryProfile setId:TestNetworkServiceIdSpecialCharacters target:service];
    [DConnectServiceDiscoveryProfile setName:TestNetworkDeviceNameSpecialCharacters target:service];
    [DConnectServiceDiscoveryProfile setType:TestNetworkDeviceType target:service];
    [DConnectServiceDiscoveryProfile setOnline:TestNetworkDeviceOnline target:service];
    [DConnectServiceDiscoveryProfile setConfig:TestNetworkDeviceConfig target:service];
    [services addMessage:service];
    
    response.result = DConnectMessageResultTypeOk;
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    return YES;
}

#pragma mark - Put Methods


- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceivePutOnServiceChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectServiceDiscoveryProfileAttrOnServiceChange
                  forKey:DConnectMessageAttribute];
        
        DConnectMessage *service = [DConnectMessage message];
        [DConnectServiceDiscoveryProfile setId:TDPServiceId target:service];
        [DConnectServiceDiscoveryProfile setName:TestNetworkDeviceName target:service];
        [DConnectServiceDiscoveryProfile setType:TestNetworkDeviceType target:service];
        [DConnectServiceDiscoveryProfile setOnline:TestNetworkDeviceOnline target:service];
        [DConnectServiceDiscoveryProfile setConfig:TestNetworkDeviceConfig target:service];

        [DConnectServiceDiscoveryProfile setNetworkService:service target:event];
        [_plugin asyncSendEvent:event];
    }

    response.result = DConnectMessageResultTypeOk;
    return YES;
}

#pragma mark - Delete Methods


- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceiveDeleteOnServiceChangeRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response serviceId:(NSString *)serviceId sessionKey:(NSString *)sessionKey
{
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

@end
