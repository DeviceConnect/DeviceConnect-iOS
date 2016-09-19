//
//  DPLinkingDeviceTemperatureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceTemperatureProfile.h"
#import "DPLinkingDeviceTemperatureOnce.h"

@implementation DPLinkingDeviceTemperatureProfile

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
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportTemperature]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceTemperatureOnce *temperature = [[DPLinkingDeviceTemperatureOnce alloc] initWithDevice:device];
    temperature.request = request;
    temperature.response = response;
    return NO;
}

@end
