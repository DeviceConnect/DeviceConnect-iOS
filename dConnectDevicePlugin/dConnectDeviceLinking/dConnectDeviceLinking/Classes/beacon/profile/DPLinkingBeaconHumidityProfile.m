//
//  DPLinkingBeaconHumidityProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconHumidityProfile.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingBeaconHumidityOnce.h"

@implementation DPLinkingBeaconHumidityProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        [self addGetPath: @"/"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetHumidity:request response:response];
                     }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetHumidity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DPLinkingBeaconHumidityOnce *humidity = [[DPLinkingBeaconHumidityOnce alloc] initWithBeacon:beacon];
    humidity.request = request;
    humidity.response = response;
    
    return NO;
}

@end
