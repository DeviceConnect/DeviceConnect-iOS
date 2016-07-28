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

@implementation SonyCameraService

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName liveViewDelegate: (id<SampleLiveviewDelegate>) liveViewDelegate remoteApiUtilDelegate:(id<SonyCameraRemoteApiUtilDelegate>) remoteApiUtilDelegate {
    
    self = [super initWithServiceId: serviceId];
    if (self) {
        [self setName: deviceName];
        [self setNetworkType: DConnectServiceDiscoveryProfileNetworkTypeWiFi];
        [self setOnline: YES];
        
        [self addProfile: [DConnectSystemProfile new]];
        [self addProfile: [[SonyCameraMediaStreamRecordingProfile alloc] initWithLiveViewDelegate: liveViewDelegate remoteApiUtilDelegate: remoteApiUtilDelegate]];
        [self addProfile: [DConnectSettingsProfile new]];
        [self addProfile: [SonyCameraCameraProfile new]];
    }
    return self;
}

@end
