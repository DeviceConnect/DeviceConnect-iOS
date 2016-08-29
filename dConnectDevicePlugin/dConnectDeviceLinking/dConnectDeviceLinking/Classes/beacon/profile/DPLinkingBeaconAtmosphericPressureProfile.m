//
//  DPLinkingBeaconAtmosphericPressureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconAtmosphericPressureProfile.h"
#import "DPLinkingBeaconAtmosphericPressureOnce.h"

@implementation DPLinkingBeaconAtmosphericPressureProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        [self addGetPath: @"/"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetAtmosphericPressure:request response:response];
                     }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetAtmosphericPressure:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (beacon.atmosphericPressureData && [[NSDate date] timeIntervalSince1970] - beacon.atmosphericPressureData.timeStamp < 30.0f) {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectAtmosphericPressureProfile setAtmosphericPressure:beacon.atmosphericPressureData.value target:response];
        [DConnectAtmosphericPressureProfile setTimeStamp:beacon.atmosphericPressureData.timeStamp target:response];
        return YES;
    }

    DPLinkingBeaconAtmosphericPressureOnce *ap = [[DPLinkingBeaconAtmosphericPressureOnce alloc] initWithBeacon:beacon];
    ap.request = request;
    ap.response = response;
    
    return NO;
}

@end
