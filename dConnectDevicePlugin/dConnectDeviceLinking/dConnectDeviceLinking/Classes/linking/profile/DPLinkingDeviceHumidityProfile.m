//
//  DPLinkingDeviceHumidityProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceHumidityProfile.h"

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
    [response setResult:DConnectMessageResultTypeError];
    return YES;
}

@end
