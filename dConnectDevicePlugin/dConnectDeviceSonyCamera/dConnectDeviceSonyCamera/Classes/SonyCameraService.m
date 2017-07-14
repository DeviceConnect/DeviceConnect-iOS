//
//  SonyCameraService.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraService.h"
#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectProfile.h>
#import <DConnectSDK/DConnectSystemProfile.h>
#import "SonyCameraMediaStreamRecordingProfile.h"
#import <DConnectSDK/DConnectSettingProfile.h>
#import "SonyCameraCameraProfile.h"

@implementation SonyCameraService

- (instancetype) initWithServiceId:(NSString *) serviceId
                        deviceName:(NSString *) deviceName
                            plugin:(id) plugin {
    self = [super initWithServiceId:serviceId plugin:plugin];
    if (self) {
        [self setName:deviceName];
        [self setNetworkType:DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline:NO];
        [self addProfile:[SonyCameraMediaStreamRecordingProfile new]];
        [self addProfile:[SonyCameraCameraProfile new]];
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
