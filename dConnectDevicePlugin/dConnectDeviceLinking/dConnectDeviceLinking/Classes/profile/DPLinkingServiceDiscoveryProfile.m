//
//  DPLinkingServiceDiscoveryProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingServiceDiscoveryProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingBeaconManager.h"

@implementation DPLinkingServiceDiscoveryProfile {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingBeaconManager *_beaconManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
    }
    return self;
}

#pragma mark - DConnectServiceDiscoveryProfileDelegate

- (BOOL)             profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                    response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];
    
    
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

@end
