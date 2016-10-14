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

@implementation DPLinkingDeviceVibrationProfile {
    DPLinkingDeviceRepeatExecutor *_repeatExecutor;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        NSString *vibrateRequestApiPath = [self apiPath:nil
                                          attributeName:DConnectVibrationProfileAttrVibrate];
        [self addPutPath: vibrateRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onPutVibrate:request response:response];
                     }];
        [self addDeletePath: vibrateRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteVibrate:request response:response];
                        }];
    }
    return self;
}

- (BOOL) onPutVibrate:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    NSString *patternStr = [DConnectVibrationProfile patternFromRequest:request];
    NSArray *pattern = patternStr ? [self parsePattern:patternStr] : nil;
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    if (pattern) {
        for (NSNumber *v in pattern) {
            if ([v integerValue] < 0) {
                [response setErrorToInvalidRequestParameter];
                return YES;
            }
        }
        
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

- (BOOL) onDeleteVibrate:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];

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
