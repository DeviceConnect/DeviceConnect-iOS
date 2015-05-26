//
//  DPChromecastServiceDiscoveryProfile.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastServiceDiscoveryProfile.h"
#import "DPChromecastManager.h"

@implementation DPChromecastServiceDiscoveryProfile

- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
    
}


#pragma mark Get Methods

- (BOOL)                 profile:(DConnectServiceDiscoveryProfile *)profile
    didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[DPChromecastManager sharedManager] startScan];
    });
    NSArray *deviceList = [DPChromecastManager sharedManager].deviceList;
    for (NSDictionary *device in deviceList) {
        DConnectMessage *service = [DConnectMessage new];
        
        [DConnectServiceDiscoveryProfile setId:device[@"id"] target:service];
        [DConnectServiceDiscoveryProfile setName:[NSString stringWithFormat:@"Chromecast(%@)", device[@"name"]]
                                          target:service];
        [DConnectServiceDiscoveryProfile setType:DConnectServiceDiscoveryProfileNetworkTypeWiFi
                                                 target:service];
        [DConnectServiceDiscoveryProfile setOnline:YES target:service];
        [DConnectServiceDiscoveryProfile setScopesWithProvider:self.provider
                                                        target:service];
        [services addMessage:service];
    }
    [response setResult:DConnectMessageResultTypeOk];
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    return YES;
}


#pragma mark - Put Methods

- (BOOL)                    profile:(DConnectServiceDiscoveryProfile *)profile
didReceivePutOnServiceChangeRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    [response setErrorToNotSupportProfile];
    return YES;
}


#pragma mark - Delete Methods

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveDeleteOnServiceChangeRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    [response setErrorToNotSupportProfile];
    return YES;
}


@end
