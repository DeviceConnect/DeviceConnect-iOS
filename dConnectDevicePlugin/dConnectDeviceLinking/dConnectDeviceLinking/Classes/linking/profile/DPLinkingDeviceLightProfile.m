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

@interface DPLinkingDeviceLightProfile ()
@end

@implementation DPLinkingDeviceLightProfile {
    DPLinkingDeviceRepeatExecutor *_flashingExecutor;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;

        [self addGetPath:[self apiPath:nil attributeName:nil]
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetLight:request response:response];
                     }];
        
        [self addPostPath:[self apiPath:nil attributeName:nil]
                      api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          return [_self onPostLight:request response:response];
                      }];
        
        [self addDeletePath:[self apiPath:nil attributeName:nil]
                        api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteLight:request response:response];
                        }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetLight:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
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

- (BOOL) onPostLight:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    NSString *lightId = [DConnectLightProfile lightIdFromRequest:request];
    NSArray *flashing = [DConnectLightProfile parsePattern:[DConnectLightProfile flashingFromRequest:request] isId:NO];
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (lightId && ![device.identifier isEqualToString:lightId]) {
        [response setErrorToInvalidRequestParameter];
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

- (BOOL) onDeleteLight:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    NSString *lightId = [DConnectLightProfile lightIdFromRequest:request];

    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    if (lightId && ![device.identifier isEqualToString:lightId]) {
        [response setErrorToInvalidRequestParameter];
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
