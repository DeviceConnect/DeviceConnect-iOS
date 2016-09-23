//
//  DPLinkingDeviceBatteryProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceBatteryProfile.h"
#import "DPLinkingDeviceBatteryOnce.h"

@implementation DPLinkingDeviceBatteryProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        [self addGetPath: @"/"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetBattery:request response:response];
                     }];

        [self addGetPath: @"/level"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetBattery:request response:response];
                     }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetBattery:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportSensor]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceBatteryOnce *battery = [[DPLinkingDeviceBatteryOnce alloc] initWithDevice:device];
    battery.request = request;
    battery.response = response;
    
    return NO;
}

@end
