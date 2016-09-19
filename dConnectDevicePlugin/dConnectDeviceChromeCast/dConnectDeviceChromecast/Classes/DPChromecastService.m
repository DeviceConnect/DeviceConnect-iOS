//
//  DPChromecastService.m
//  dConnectDeviceChromecast
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastService.h"
#import "DPChromecastNotificationProfile.h"
#import "DPChromecastMediaPlayerProfile.h"
#import "DPChromecastCanvasProfile.h"

@implementation DPChromecastService

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName plugin: (id) plugin {
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: [NSString stringWithFormat:@"Chromecast(%@)", deviceName]];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        [self addProfile:[DPChromecastNotificationProfile new]];
        [self addProfile:[DPChromecastMediaPlayerProfile new]];
        [self addProfile:[DPChromecastCanvasProfile new]];
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
