//
//  DPSpheroServiceDiscoveryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPSpheroServiceDiscoveryProfile.h"
#import "DPSpheroDevicePlugin.h"
#import "DPSpheroManager.h"

@implementation DPSpheroServiceDiscoveryProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
    
}

//  dConnect Managerに接続されている、デバイスプラグイン対応デバイス一覧を取得する。
- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceiveGetGetNetworkServicesRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];
    
    NSArray *deviceList = [DPSpheroManager sharedManager].deviceList;
    for (NSDictionary *device in deviceList) {
        DConnectMessage *service = [DConnectMessage new];
        
        [DConnectServiceDiscoveryProfile setId:device[@"id"] target:service];
        [DConnectServiceDiscoveryProfile setName:device[@"name"] target:service];
        [DConnectServiceDiscoveryProfile setType:DConnectServiceDiscoveryProfileNetworkTypeBluetooth
                                                 target:service];
        [DConnectServiceDiscoveryProfile setOnline:YES target:service];
        [services addMessage:service];
    }
    [response setResult:DConnectMessageResultTypeOk];
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    return YES;
}

@end
