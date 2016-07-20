//
//  DPLinkingDeviceVibrationProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceVibrationProfile.h"
#import "DPLinkingDeviceRepeatExecutor.h"
#import "DPLinkingDeviceManager.h"

@interface DPLinkingDeviceVibrationProfile () <DConnectVibrationProfileDelegate>

@end

@implementation DPLinkingDeviceVibrationProfile {
    DPLinkingDeviceRepeatExecutor *_repeatExecutor;
}

- (BOOL)            profile:(DConnectVibrationProfile *)profile
didReceivePutVibrateRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    pattern:(NSArray *) pattern
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    if (pattern) {
        _repeatExecutor = [[DPLinkingDeviceRepeatExecutor alloc] initWithPattern:pattern on:^{
            [deviceMgr sendVibrationCommand:device power:YES];
        } off:^{
            [deviceMgr sendVibrationCommand:device power:NO];
        }];

    } else {
        [deviceMgr sendVibrationCommand:device power:YES];
    }

    [response setResult:DConnectMessageResultTypeOk];

    return YES;
}

- (BOOL)                profile:(DConnectVibrationProfile *)profile
 didReceiveDeleteVibrateRequest:(DConnectRequestMessage *)request
                       response:(DConnectResponseMessage *)response
                      serviceId:(NSString *)serviceId
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (_repeatExecutor) {
        [_repeatExecutor cancel];
    }
    [deviceMgr sendVibrationCommand:device power:NO];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

@end
