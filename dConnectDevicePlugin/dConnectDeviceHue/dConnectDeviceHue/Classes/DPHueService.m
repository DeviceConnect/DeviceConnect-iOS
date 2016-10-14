//
//  DPHueService.m
//  dConnectDeviceHue
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHueService.h"
#import "DPHueLightProfile.h"

@implementation DPHueService

- (instancetype) initWithBridgeKey: (NSString *) bridgeKey
                       bridgeValue: (NSString *) bridgeValue
                            plugin: (id) plugin {
    // [NSString stringWithFormat:@"%@_%@",[bridgesFound valueForKey:key],key];
    NSString *serviceId = [NSString stringWithFormat:@"%@_%@", bridgeValue, bridgeKey];
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        NSString *name = [NSString stringWithFormat:@"Hue %@", bridgeKey];
        [self setName: name];
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
