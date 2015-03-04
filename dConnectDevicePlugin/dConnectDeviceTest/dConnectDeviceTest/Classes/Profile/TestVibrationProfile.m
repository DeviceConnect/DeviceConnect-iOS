//
//  TestVibrationProfile.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestVibrationProfile.h"

@implementation TestVibrationProfile

- (id) init {
    self = [super init];
    
    if (self) {
        self.delegate = self;
    }
    
    return self;
}

#pragma mark - Put Methods

- (BOOL) profile:(DConnectVibrationProfile *)profile didReceivePutVibrateRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId pattern:(NSArray *) pattern
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

#pragma mark - Delete Methods

- (BOOL) profile:(DConnectVibrationProfile *)profile didReceiveDeleteVibrateRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response
        serviceId:(NSString *)serviceId
{
    
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}

@end
