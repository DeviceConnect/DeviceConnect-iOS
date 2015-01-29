//
//  DPHueServiceDiscoveryProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueServiceDiscoveryProfile.h"
#import "DPHueManager.h"


@implementation DPHueServiceDiscoveryProfile


- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)                           profile:(DConnectServiceDiscoveryProfile *)profile
    didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                                  response:(DConnectResponseMessage *)response
{
    [response setResult:DConnectMessageResultTypeOk];
    NSDictionary *bridgesFound = [DPHueManager sharedManager].hueBridgeList;
    DConnectArray *services = [DConnectArray array];
    DConnectMessage *service = nil;
    if (bridgesFound.count > 0) {
        NSString * serviceId = @"";
        for (id key in [bridgesFound keyEnumerator]) {
            serviceId = [NSString stringWithFormat:@"%@_%@",[bridgesFound valueForKey:key],key];
            service = [DConnectMessage new];
            [DConnectServiceDiscoveryProfile
             setId:serviceId
             target:service];
            
            [DConnectServiceDiscoveryProfile
             setName:[NSString stringWithFormat:@"Hue %@", key]
             target:service];
            
            [DConnectServiceDiscoveryProfile
             setType:DConnectServiceDiscoveryProfileNetworkTypeWiFi
             
             target:service];
            [DConnectServiceDiscoveryProfile setOnline:YES target:service];
            
            [services addMessage:service];

        }

    }
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    return YES;
}
@end
