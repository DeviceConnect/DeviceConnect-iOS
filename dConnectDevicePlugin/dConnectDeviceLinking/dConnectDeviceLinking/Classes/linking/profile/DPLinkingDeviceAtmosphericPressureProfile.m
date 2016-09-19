//
//  DPLinkingDeviceAtmosphericPressureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceAtmosphericPressureProfile.h"
#import "DPLinkingDeviceAtmosphericPressureOnce.h"

@implementation DPLinkingDeviceAtmosphericPressureProfile

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
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportAtmosphericPressure]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceAtmosphericPressureOnce *atmosphericPressure = [[DPLinkingDeviceAtmosphericPressureOnce alloc] initWithDevice:device];
    atmosphericPressure.request = request;
    atmosphericPressure.response = response;
    
    return NO;
}
@end
