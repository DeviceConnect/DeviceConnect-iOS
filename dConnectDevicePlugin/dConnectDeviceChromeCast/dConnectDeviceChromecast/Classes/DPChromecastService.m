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

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName {
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: [NSString stringWithFormat:@"Chromecast(%@)", deviceName]];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        [self addProfile:[DPChromecastNotificationProfile new]];
        [self addProfile:[DPChromecastMediaPlayerProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
        [self addProfile:[DPChromecastCanvasProfile new]];
    }
    return self;
}


@end
