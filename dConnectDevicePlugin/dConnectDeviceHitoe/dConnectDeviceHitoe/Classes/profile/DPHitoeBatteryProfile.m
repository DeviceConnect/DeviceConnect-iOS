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
        __unsafe_unretained typeof(self) weakSelf = self;
        
        NSString *didReceiveGetAllRequest = [self apiPath: nil
                                            attributeName: nil];
        [self addGetPath:didReceiveGetAllRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf getBatteryLevelWithRequest:request response:response serviceId:[request serviceId]];
        }];
        NSString *didReceiveGetLevelRequest = [self apiPath: nil
                                              attributeName: DConnectBatteryProfileAttrLevel];
        [self addGetPath:didReceiveGetLevelRequest api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf getBatteryLevelWithRequest:request response:response serviceId:[request serviceId]];
        }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL)getBatteryLevelWithRequest:(DConnectRequestMessage *)request
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
        double level = (data.target.batteryLevel + 1) / 4;
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
