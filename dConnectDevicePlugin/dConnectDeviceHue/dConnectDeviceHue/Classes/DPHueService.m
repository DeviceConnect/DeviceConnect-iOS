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
#import <DConnectSDK/DConnectServiceInformationProfile.h>

@implementation DPHueService

- (instancetype) initWithBridgeKey: (NSString *) bridgeKey
                       bridgeValue: (NSString *) bridgeValue {
    // [NSString stringWithFormat:@"%@_%@",[bridgesFound valueForKey:key],key];
    NSString *serviceId = [NSString stringWithFormat:@"%@_%@", bridgeValue, bridgeKey];
    self = [super initWithServiceId: serviceId];
    if (self) {
        NSString *name = [NSString stringWithFormat:@"Hue %@", bridgeKey];
        [self setName: name];
        [self setOnline: YES];
        
        // プロファイルを追加
        [self addProfile:[DPHueLightProfile new]];
        [self addProfile:[DConnectServiceInformationProfile new]];
    }
    return self;
}

@end
