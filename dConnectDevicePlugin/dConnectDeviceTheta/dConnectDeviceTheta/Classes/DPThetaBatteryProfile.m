//
//  DPThetaBatteryProfile.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaDevicePlugin.h"
#import "DPThetaBatteryProfile.h"
#import "DPThetaServiceDiscoveryProfile.h"
#import "DPThetaManager.h"

@interface DPThetaBatteryProfile ()

@end

@implementation DPThetaBatteryProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - Get Methods

- (BOOL)        profile:(DConnectBatteryProfile *)profile
didReceiveGetAllRequest:(DConnectRequestMessage *)request
               response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
{
    CONNECT_CHECK();
    float level = [[DPThetaManager sharedManager] getBatteryLevel] / (float) 100.0;
    if (level >= 0 && level <= 1) {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setCharging:NO target:response];
        [DConnectBatteryProfile setLevel:level target:response];
    } else {
        // 未知のステータス；エラーレスポンスを返す。
        [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
    }
    return YES;
}

- (BOOL)          profile:(DConnectBatteryProfile *)profile
didReceiveGetLevelRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
{
    CONNECT_CHECK();
    float level = [[DPThetaManager sharedManager] getBatteryLevel] / (float) 100.0;
    if (level < 0 || level > 1) {
        // 未知のステータス；エラーレスポンスを返す。
        [response setErrorToUnknownWithMessage:@"Battery status is unknown."];
    } else {
        [DConnectBatteryProfile setLevel:level target:response];
        [response setResult:DConnectMessageResultTypeOk];
    }
    return YES;
}


@end
