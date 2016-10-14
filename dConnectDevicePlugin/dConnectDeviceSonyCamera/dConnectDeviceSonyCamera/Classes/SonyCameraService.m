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
#import <DConnectSDK/DConnectSettingsProfile.h>
#import "SonyCameraCameraProfile.h"
#import "SonyCameraSettingsProfile.h"

@implementation SonyCameraService

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName plugin: (id) plugin liveViewDelegate: (id<SampleLiveviewDelegate>) liveViewDelegate remoteApiUtilDelegate:(id<SonyCameraRemoteApiUtilDelegate>) remoteApiUtilDelegate {
    
    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        [self addProfile: [DConnectSystemProfile new]];
        [self addProfile: [[SonyCameraMediaStreamRecordingProfile alloc] initWithLiveViewDelegate: liveViewDelegate remoteApiUtilDelegate: remoteApiUtilDelegate]];
        [self addProfile: [SonyCameraSettingsProfile new]];
        [self addProfile: [SonyCameraCameraProfile new]];
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
