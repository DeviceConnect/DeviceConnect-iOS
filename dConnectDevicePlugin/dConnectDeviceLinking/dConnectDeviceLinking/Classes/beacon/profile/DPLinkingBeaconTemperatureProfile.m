//
//  DPLinkingBeaconTemperatureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconTemperatureProfile.h"
#import "DPLinkingBeaconTemperatureOnce.h"

@implementation DPLinkingBeaconTemperatureProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        [self addGetPath: @"/"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetTemperature:request response:response];
                     }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetTemperature:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
   if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    float temp = beacon.temperatureData.value;
    int type = [request integerForKey:DCMTemperatureProfileParamType];
    if (type == DCMTemperatureProfileEnumCelsiusFahrenheit) {
        temp = [DCMTemperatureProfile convertFahrenheitToCelsius:temp];
    } else {
        // 1,2以外は摂氏とする。
        type = DCMTemperatureProfileEnumCelsius;
    }
    beacon.temperatureData.temperatureType = type;
    
    if (beacon.temperatureData && [[NSDate date] timeIntervalSince1970] - beacon.temperatureData.timeStamp < 30.0f) {
        [response setResult:DConnectMessageResultTypeOk];
        [DCMTemperatureProfile setTemperature:temp target:response];
        [DCMTemperatureProfile setTimeStamp:beacon.temperatureData.timeStamp target:response];
        [DCMTemperatureProfile setType:type target:response];
        return YES;
    }
    
    DPLinkingBeaconTemperatureOnce *temperature = [[DPLinkingBeaconTemperatureOnce alloc] initWithBeacon:beacon];
    temperature.request = request;
    temperature.response = response;
    
    return NO;
}

@end
