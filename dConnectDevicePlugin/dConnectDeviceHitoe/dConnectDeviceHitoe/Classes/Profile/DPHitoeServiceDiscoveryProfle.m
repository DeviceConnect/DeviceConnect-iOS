//
//  DPHitoeServiceDiscoveryProfle.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeServiceDiscoveryProfle.h"
#import "DPHitoeManager.h"
#import "DPHitoeDevice.h"

@implementation DPHitoeServiceDiscoveryProfle



- (id)init
{
    self = [super init];
    if (self) {
//        self.delegate = self;
    }
    return self;
    
}


#pragma mark Get Methods

- (BOOL)                 profile:(DConnectServiceDiscoveryProfile *)profile
    didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];
    NSMutableArray *deviceList = [DPHitoeManager sharedInstance].registeredDevices;
    for (DPHitoeDevice *device in deviceList) {
        if (!device.pinCode) {
            continue;
        }
        DConnectMessage *service = [DConnectMessage new];
        
        [DConnectServiceDiscoveryProfile setId:device.serviceId target:service];
        [DConnectServiceDiscoveryProfile setName:device.name
                                          target:service];
        [DConnectServiceDiscoveryProfile setType:DConnectServiceDiscoveryProfileNetworkTypeBLE
                                          target:service];
        [DConnectServiceDiscoveryProfile setOnline:device.isRegisterFlag target:service];
        [services addMessage:service];
    }
    [response setResult:DConnectMessageResultTypeOk];
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    return YES;
}

@end
