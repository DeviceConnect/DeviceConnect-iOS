//
//  DPIRKitServiceInformationProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitServiceInformationProfile.h"
#import "DPIRKitDBManager.h"
#import "DPIRKitVirtualDevice.h"


static NSString *const DPIRKitLightSupportProfile[] = {
                                                    @"system",
                                                    @"servicediscovery",
                                                    @"serviceinformation",
                                                    @"authorization",
                                                    @"light"};
static NSString *const DPIRKitTVSupportProfile[] = {
                                                    @"system",
                                                    @"servicediscovery",
                                                    @"serviceinformation",
                                                    @"authorization",
                                                    @"tv"};
static NSString *const DPIRKitRemoteControllerSupportProfile[] = {
                                                    @"system",
                                                    @"servicediscovery",
                                                    @"serviceinformation",
                                                    @"authorization",
                                                    @"remote_controller"};

static NSUInteger const DPIRKitSupportCount = 5;

@implementation DPIRKitServiceInformationProfile

// 初期化
- (id)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
    
}


- (BOOL)                    profile:(DConnectServiceInformationProfile *)profile
    didReceiveGetInformationRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                          serviceId:(NSString *)serviceId
{
    BOOL send = YES;
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSArray *virtuals = [[DPIRKitDBManager sharedInstance] queryVirtualDevice:serviceId];
    if (!interface && !attribute) {
        DConnectMessage *connect = [DConnectMessage message];
        [DConnectServiceInformationProfile setWiFiState:DConnectServiceInformationProfileConnectStateOn
                                                 target:connect];
        [DConnectServiceInformationProfile setConnect:connect target:response];
        if (virtuals.count == 1) {
            DPIRKitVirtualDevice *device = virtuals[0];
            if ([device.categoryName isEqualToString:@"ライト"]) {
                DConnectArray *supports = [DConnectArray array];
                for (int i = 0; i < DPIRKitSupportCount; i++) {
                    [supports addString:DPIRKitLightSupportProfile[i]];
                }
                [DConnectServiceInformationProfile setSupports:supports target:response];
            } else {
                DConnectArray *supports = [DConnectArray array];
                for (int i = 0; i < DPIRKitSupportCount; i++) {
                    [supports addString:DPIRKitTVSupportProfile[i]];
                }
                [DConnectServiceInformationProfile setSupports:supports target:response];
            }
        } else {
            DConnectArray *supports = [DConnectArray array];
            for (int i = 0; i < DPIRKitSupportCount; i++) {
                [supports addString:DPIRKitRemoteControllerSupportProfile[i]];
            }
            [DConnectServiceInformationProfile setSupports:supports target:response];
        }
        [response setResult:DConnectMessageResultTypeOk];
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

@end
