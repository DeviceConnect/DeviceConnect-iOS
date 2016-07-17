//
//  DPHitoeBatteryProfile.m
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHitoeBatteryProfile.h"
#import "DPHitoeManager.h"
#import "DPHitoeHeartRateData.h"
@implementation DPHitoeBatteryProfile

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
    return [self getBatteryLevelWithProfile:profile didReceiveGetLevelRequest:request response:response serviceId:serviceId];
}

- (BOOL)          profile:(DConnectBatteryProfile *)profile
didReceiveGetLevelRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                serviceId:(NSString *)serviceId
{
    return [self getBatteryLevelWithProfile:profile didReceiveGetLevelRequest:request response:response serviceId:serviceId];
}

#pragma mark - Private Method

- (BOOL)getBatteryLevelWithProfile:(DConnectBatteryProfile *)profile
         didReceiveGetLevelRequest:(DConnectRequestMessage *)request
                          response:(DConnectResponseMessage *)response
                         serviceId:(NSString *)serviceId {
    
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else {
        DPHitoeManager *mgr = [DPHitoeManager sharedInstance];
        if (!mgr) {
            [response setErrorToNotFoundService];
            return YES;
        }
        DPHitoeHeartRateData *data = [mgr getHeartRateDataForServiceId:serviceId];
        if (!data) {
            [response setErrorToNotFoundService];
            return YES;
        }
        double level = data.target.batteryLevel;
        if (level < 0) {
            [response setErrorToUnknownWithMessage:@"Battery level is unknown."];
        } else {
            [DConnectBatteryProfile setLevel:level target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    }
    return YES;
}

@end
