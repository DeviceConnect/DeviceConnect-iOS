//
//  DPLinkingDeviceOrientationProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceOrientationProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingDevicePlugin.h"
#import "DPLinkingDeviceSensorHolder.h"
#import "DPLinkingDeviceSensorOnce.h"

@interface DPLinkingDeviceOrientationProfile () <DConnectDeviceOrientationProfileDelegate, DPLinkingDeviceSensorDelegate>
@end

@implementation DPLinkingDeviceOrientationProfile {
    DPLinkingDeviceSensorHolder *_holder;
}

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
{
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
    
    DPLinkingDeviceSensorOnce *sensor = [[DPLinkingDeviceSensorOnce alloc] initWithDevice:device];
    sensor.request = request;
    sensor.response = response;
    
    [mgr enableListenSensor:device delegate:sensor];

    return NO;
}

- (BOOL)                        profile:(DConnectDeviceOrientationProfile *)profile
didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        if (_holder == nil) {
            _holder = [[DPLinkingDeviceSensorHolder alloc] initWithDevice:device];
        }
        [deviceMgr enableListenSensor:device delegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL)                            profile:(DConnectDeviceOrientationProfile *)profile
didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                   response:(DConnectResponseMessage *)response
                                  serviceId:(NSString *)serviceId
                                 sessionKey:(NSString *)sessionKey
{
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }

    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        if ([self isEmptyEventList:serviceId]) {
            [deviceMgr disableListenSensor:device delegate:self];
        }
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) isEmptyEventList:(NSString *)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events = [mgr eventListForServiceId:serviceId
                                         profile:DConnectDeviceOrientationProfileName
                                       attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
    return events.count == 0;
}

- (void) didReceivedDevice:(DPLinkingDevice *)device sensor:(DPLinkingSensorData *)data
{
    if (!_holder) {
        return;
    }
    
    [DPLinkingDeviceOrientationProfile updateSensorData:data to:_holder.orientation];
    [_holder setSensorData:data];

    if ([_holder isFlag]) {
        [_holder clearFlag];

        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
        NSArray *events  = [mgr eventListForServiceId:device.identifier
                                              profile:DConnectDeviceOrientationProfileName
                                            attribute:DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        if (events == 0) {
            DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
            [deviceMgr disableListenSensor:device delegate:self];
        } else {
            for (DConnectEvent *event in events) {
                DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
                [DConnectDeviceOrientationProfile setOrientation:_holder.orientation target:eventMsg];
                DConnectDevicePlugin *plugin = (DConnectDevicePlugin *)self.provider;
                [plugin sendEvent:eventMsg];
            }
        }
    }
}

+ (void) updateSensorData:(DPLinkingSensorData *)data to:(DConnectMessage *)message
{
    switch (data.type) {
        case DPLinkingSensorTypeGyroscope: {
            DConnectMessage *gyro = [DConnectMessage new];
            [gyro setFloat:data.x forKey:DConnectDeviceOrientationProfileParamX];
            [gyro setFloat:data.y forKey:DConnectDeviceOrientationProfileParamY];
            [gyro setFloat:data.z forKey:DConnectDeviceOrientationProfileParamZ];
            [message setMessage:gyro forKey:DConnectDeviceOrientationProfileParamRotationRate];
        }   break;
        case DPLinkingSensorTypeAccelerometer: {
            DConnectMessage *acceleration = [DConnectMessage new];
            [acceleration setFloat:data.x forKey:DConnectDeviceOrientationProfileParamX];
            [acceleration setFloat:data.y forKey:DConnectDeviceOrientationProfileParamY];
            [acceleration setFloat:data.z forKey:DConnectDeviceOrientationProfileParamZ];
            [message setMessage:acceleration forKey:DConnectDeviceOrientationProfileParamAccelerationIncludingGravity];
        }   break;
        case DPLinkingSensorTypeOrientation: {
            DConnectMessage *compass = [DConnectMessage new];
            [compass setFloat:data.x forKey:@"beta"];
            [compass setFloat:data.y forKey:@"gamma"];
            [compass setFloat:data.z forKey:@"alpha"];
            [message setMessage:compass forKey:@"compass"];
        }   break;
        default:
            return;
    }
}

@end

