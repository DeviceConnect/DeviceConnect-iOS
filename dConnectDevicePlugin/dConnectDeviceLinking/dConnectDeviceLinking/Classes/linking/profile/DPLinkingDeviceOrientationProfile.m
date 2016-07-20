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
#import "DPLinkingUtil.h"
#import "DPLinkingDevicePlugin.h"

#pragma mark - DPLinkingDeviceSensor

@interface DPLinkingDeviceSensor : NSObject <DPLinkingDeviceSensorDelegate>
@property (nonatomic) DPLinkingDevice *device;
@property (nonatomic) DConnectRequestMessage *request;
@property (nonatomic) DConnectResponseMessage *response;
@end

@implementation DPLinkingDeviceSensor {
    DPLinkingDeviceManager *_deviceManager;
    DConnectMessage *_orientation;
    BOOL _supportGyro;
    BOOL _supportAcceleration;
    BOOL _supportCompass;
    BOOL _cleanupFlag;
    DPLinkingUtilTimerCancelBlock _cancelBlock;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _cleanupFlag = NO;
        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _orientation = [DConnectMessage new];
        [self setTimeout:30.0f];
    }
    return self;
}

- (void) didReceivedDevice:(DPLinkingDevice *)device sensor:(DPLinkingSensorData *)data
{
    if (_cleanupFlag) {
        return;
    }
    
    switch (data.type) {
        case DPLinkingSensorTypeGyroscope: {
            DConnectMessage *gyro = [DConnectMessage new];
            [gyro setFloat:data.x forKey:DConnectDeviceOrientationProfileParamX];
            [gyro setFloat:data.y forKey:DConnectDeviceOrientationProfileParamY];
            [gyro setFloat:data.z forKey:DConnectDeviceOrientationProfileParamZ];
            [_orientation setMessage:gyro forKey:DConnectDeviceOrientationProfileParamRotationRate];
            _supportGyro = YES;
        }   break;
        case DPLinkingSensorTypeAccelerometer: {
            DConnectMessage *acceleration = [DConnectMessage new];
            [acceleration setFloat:data.x forKey:DConnectDeviceOrientationProfileParamX];
            [acceleration setFloat:data.y forKey:DConnectDeviceOrientationProfileParamY];
            [acceleration setFloat:data.z forKey:DConnectDeviceOrientationProfileParamZ];
            [_orientation setMessage:acceleration forKey:DConnectDeviceOrientationProfileParamAccelerationIncludingGravity];
            _supportAcceleration = YES;
        }   break;
        case DPLinkingSensorTypeOrientation: {
            DConnectMessage *compass = [DConnectMessage new];
            [compass setFloat:data.x forKey:@"beta"];
            [compass setFloat:data.y forKey:@"gamma"];
            [compass setFloat:data.z forKey:@"alpha"];
            [_orientation setMessage:compass forKey:@"compass"];
            _supportCompass = YES;
        }   break;
        default:
            return;
    }
    
    if ([self isFlag]) {
        [self.response setResult:DConnectMessageResultTypeOk];
        [self.response setMessage:_orientation forKey:DConnectDeviceOrientationProfileParamOrientation];
        [[DConnectManager sharedManager] sendResponse:self.response];
        [self cleanup];
    }
}

- (void) timeout
{
    if (_cleanupFlag) {
        return;
    }
    
    [self.response setErrorToTimeout];
    [[DConnectManager sharedManager] sendResponse:self.response];
    
    [self cleanup];
}

- (void) cleanup
{
    if (_cleanupFlag) {
        return;
    }
    _cleanupFlag = YES;

    _cancelBlock();
    
    [_deviceManager disableListenSensor:self.device delegate:self];
}

- (void) setTimeout:(float)time
{
    __block DPLinkingDeviceSensor *_self = self;
    
    _cancelBlock = [DPLinkingUtil asyncAfterDelay:time block:^{
        [_self timeout];
    }];
}

- (BOOL) isFlag
{
    return [self.device isSupportGryo] == _supportGyro &&
            [self.device isSupportAcceleration] == _supportAcceleration &&
            [self.device isSupportCompass] == _supportCompass;
}

@end



#pragma mark - DPLinkingDeviceOrientationProfile

@interface DPLinkingDeviceOrientationProfile() <DConnectDeviceOrientationProfileDelegate, DPLinkingDeviceSensorDelegate>

@end

@implementation DPLinkingDeviceOrientationProfile

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
    
    DPLinkingDeviceSensor *sensor = [DPLinkingDeviceSensor new];
    sensor.device = device;
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
        }
    }
}

@end
