//
//  DPLinkingDeviceHumidityProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceHumidityProfile.h"
#import "DPLinkingDeviceHumidityOnce.h"

@implementation DPLinkingDeviceHumidityProfile

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
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportHumidity]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceHumidityOnce *humidity = [[DPLinkingDeviceHumidityOnce alloc] initWithDevice:device];
    humidity.request = request;
    humidity.response = response;
    return NO;
}

@end
