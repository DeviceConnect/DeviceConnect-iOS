//
//  DPHitoeService.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeService.h"
#import "DPHitoeHealthProfile.h"
#import "DPHitoeECGProfile.h"
#import "DPHitoeBatteryProfile.h"
#import "DPHitoePoseEstimationProfile.h"
#import "DPHitoeStressEstimationProfile.h"
#import "DPHitoeDeviceOrientationProfile.h"
#import "DPHitoeWalkStateProfile.h"


@implementation DPHitoeService
- (instancetype) initWithServiceId: (NSString *) serviceId plugin: (id) plugin {

    self = [super initWithServiceId: serviceId plugin: plugin dataSource: self];
    if (self) {
        //ServiceDiscoveryの定義
        [self setNetworkType:DConnectServiceDiscoveryProfileNetworkTypeBLE];
        
        // サポートするProfileの定義
        [self addProfile:[DPHitoeBatteryProfile new]];
        [self addProfile:[DPHitoeHealthProfile new]];
        [self addProfile:[DPHitoeECGProfile new]];
        [self addProfile:[DPHitoePoseEstimationProfile new]];
        [self addProfile:[DPHitoeStressEstimationProfile new]];
        [self addProfile:[DPHitoeWalkStateProfile new]];
        [self addProfile:[DPHitoeDeviceOrientationProfile new]];

    }
    return self;
}

#pragma mark - DConnectServiceInformationProfileDataSource Implement.

- (DConnectServiceInformationProfileConnectState)profile:(DConnectServiceInformationProfile *)profile
                                   wifiStateForServiceId:(NSString *)serviceId {
    
    DConnectServiceInformationProfileConnectState bleState;
    if (self.online) {
        bleState = DConnectServiceInformationProfileConnectStateOn;
    } else {
        bleState = DConnectServiceInformationProfileConnectStateOff;
    }
    return bleState;
}


@end
