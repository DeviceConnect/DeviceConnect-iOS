//
//  DPLinkingDeviceLightProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceLightProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingDeviceRepeatExecutor.h"

@interface DPLinkingDeviceLightProfile () <DConnectLightProfileDelegate>

@end

@implementation DPLinkingDeviceLightProfile {
    DPLinkingDeviceRepeatExecutor *_flashingExecutor;
}

- (BOOL)              profile:(DConnectLightProfile *)profile
    didReceiveGetLightRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    DConnectArray *lights = [DConnectArray array];
    DConnectMessage *led = [DConnectMessage new];

    [DConnectLightProfile setLightId:device.identifier target:led];
    [DConnectLightProfile setLightName:@"Linking LED" target:led];
    [DConnectLightProfile setLightOn:YES target:led];
    [lights addMessage:led];
    
    [DConnectLightProfile setLights:lights target:response];
    [response setResult:DConnectMessageResultTypeOk];

    return YES;
}

- (BOOL)            profile:(DConnectLightProfile *)profile
 didReceivePostLightRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                  serviceId:(NSString *)serviceId
                    lightId:(NSString*)lightId
                 brightness:(NSNumber*)brightness
                      color:(NSString*)color
                   flashing:(NSArray*)flashing
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (flashing) {
        _flashingExecutor = [[DPLinkingDeviceRepeatExecutor alloc] initWithPattern:flashing on:^{
            [deviceMgr sendLEDCommand:device power:YES];
        } off:^{
            [deviceMgr sendLEDCommand:device power:NO];
        }];
    } else {
        [deviceMgr sendLEDCommand:device power:YES];
    }
    
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

- (BOOL)                 profile:(DConnectLightProfile *)profile
    didReceiveDeleteLightRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                       serviceId:(NSString *)serviceId
                         lightId:(NSString*)lightId
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (_flashingExecutor) {
        [_flashingExecutor cancel];
    }
    [deviceMgr sendLEDCommand:device power:NO];

    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

@end
