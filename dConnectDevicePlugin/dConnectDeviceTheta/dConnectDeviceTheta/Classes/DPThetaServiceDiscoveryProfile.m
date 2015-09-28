//
//  DPThetaServiceDiscoveryProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectMessage.h>

#import "DPThetaServiceDiscoveryProfile.h"
#import "DPThetaManager.h"

NSString *const DPThetaServiceDiscoveryServiceId = @"theta";

@implementation DPThetaServiceDiscoveryProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - DConnectServiceDiscoveryProfileDelegate
#pragma mark Get Methods

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
{
    CONNECT_CHECK();
    DPThetaManager *mgr = [DPThetaManager sharedManager];
    NSString* serial = [mgr getSerialNo];
    if (serial) {
        NSString *name = [NSString stringWithFormat:@"Theta: %@", serial];

        DConnectArray *services = [DConnectArray array];

        DConnectMessage *service = [DConnectMessage message];
        [DConnectServiceDiscoveryProfile setId:DPThetaServiceDiscoveryServiceId target:service];
        [DConnectServiceDiscoveryProfile setName:name target:service];
        [DConnectServiceDiscoveryProfile setOnline:YES target:service];
        [DConnectServiceDiscoveryProfile setScopesWithProvider:self.provider
                                                        target:service];
        [services addMessage:service];

        [DConnectServiceDiscoveryProfile setServices:services target:response];

        [response setResult:DConnectMessageResultTypeOk];
    }
    return YES;
}


#pragma mark - DConnectEventHandling

- (BOOL) unregisterAllEventsWithSessionkey:(NSString *)sessionKey
{
    return YES;
}

@end