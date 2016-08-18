//
//  DPLinkingDeviceTemperatureProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceTemperatureProfile.h"

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
    [response setErrorToNotSupportProfile];
    return YES;
}

@end
