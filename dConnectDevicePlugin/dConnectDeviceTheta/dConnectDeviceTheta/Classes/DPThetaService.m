//
//  DPThetaService.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaService.h"
#import "DPThetaBatteryProfile.h"
#import "DPThetaFileProfile.h"
#import "DPThetaMediaStreamRecordingProfile.h"
#import "DPThetaOmnidirectionalImageProfile.h"

NSString *const DPThetaDeviceServiceId = @"theta";
NSString *const DPThetaRoiServiceId = @"roi";

@implementation DPThetaService

- (instancetype) initWithServiceId: (NSString *) serviceId plugin: (id) plugin {

    self = [super initWithServiceId: serviceId plugin: plugin];
    if (self) {
        [self addProfile:[DPThetaBatteryProfile new]];
        [self addProfile:[DPThetaFileProfile new]];
        [self addProfile:[DPThetaMediaStreamRecordingProfile new]];
        [self addProfile:[DPThetaOmnidirectionalImageProfile new]];
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
