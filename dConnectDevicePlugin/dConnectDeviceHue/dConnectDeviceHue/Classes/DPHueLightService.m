//
//  DPHueLightService.m
//  dConnectDeviceHue
//
//  Copyright (c) 2018 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueLightService.h"
#import "DPHueLightProfile.h"

@implementation DPHueLightService
- (instancetype) initWithBridgeKey: (NSString *) bridgeKey
                       bridgeValue: (NSString *) bridgeValue
                           lightId: (NSString *) lightId
                         lightName: (NSString *) lightName
                            plugin: (id) plugin {
    NSString *serviceId = [NSString stringWithFormat:@"%@_%@_%@", bridgeValue, bridgeKey, lightId];
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: lightName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        // プロファイルを追加
        [self addProfile:[DPHueLightProfile new]];
    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource Implement.

- (DConnectServiceInformationProfileConnectState)profile:(DConnectServiceInformationProfile *)profile
                                   wifiStateForServiceId:(NSString *)serviceId {
    
    DConnectServiceInformationProfileConnectState wifiState;
    if (self.online) {
        wifiState = DConnectServiceInformationProfileConnectStateOn;
    } else {
        wifiState = DConnectServiceInformationProfileConnectStateOff;
    }
    return wifiState;
}
@end
