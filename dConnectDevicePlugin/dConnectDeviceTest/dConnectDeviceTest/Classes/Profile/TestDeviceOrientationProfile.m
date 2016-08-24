//
//  TestDeviceOrientationProfile.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestDeviceOrientationProfile.h"
#import "DeviceTestPlugin.h"

@implementation TestDeviceOrientationProfile

- (id) init {
    self = [super init];
    
    if (self) {
        __weak TestDeviceOrientationProfile *weakSelf = self;
        
        // API登録(didReceiveGetOnDeviceOrientationRequest相当)
        NSString *getOnDeviceOrientationRequestApiPath =
        [self apiPath: nil
        attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addGetPath: getOnDeviceOrientationRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            CheckDID(response, serviceId) {
                response.result = DConnectMessageResultTypeOk;
                [weakSelf setOrientation:response];
            }
            return YES;
        }];
        
        // API登録(didReceivePutOnDeviceOrientationRequest相当)
        NSString *putOnDeviceOrientationRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addPutPath: putOnDeviceOrientationRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
                
                DConnectMessage *event = [DConnectMessage message];
                [event setString:sessionKey forKey:DConnectMessageSessionKey];
                [event setString:serviceId forKey:DConnectMessageServiceId];
                [event setString:weakSelf.profileName forKey:DConnectMessageProfile];
                [event setString:DConnectDeviceOrientationProfileName
                          forKey:DConnectMessageAttribute];
                [weakSelf setOrientation:event];
                [weakSelf.plugin asyncSendEvent:event];
            }
            
            return YES;
        }];
        
        // API登録(didReceiveDeleteOnDeviceOrientationRequest相当)
        NSString *deleteOnDeviceOrientationRequestApiPath =
                [self apiPath: nil
                attributeName: DConnectDeviceOrientationProfileAttrOnDeviceOrientation];
        [self addDeletePath: deleteOnDeviceOrientationRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            
            CheckDIDAndSK(response, serviceId, sessionKey) {
                response.result = DConnectMessageResultTypeOk;
            }
            
            return YES;
        }];
    }
    
    return self;
}

- (void) setOrientation:(DConnectMessage *)message
{
    DConnectMessage *orientation = [DConnectMessage message];
    
    DConnectMessage *acceleration = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setX:0 target:acceleration];
    [DConnectDeviceOrientationProfile setY:0 target:acceleration];
    [DConnectDeviceOrientationProfile setZ:0 target:acceleration];
    
    DConnectMessage *accelerationIncludingGravity = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setX:0 target:accelerationIncludingGravity];
    [DConnectDeviceOrientationProfile setY:0 target:accelerationIncludingGravity];
    [DConnectDeviceOrientationProfile setZ:0 target:accelerationIncludingGravity];
    
    DConnectMessage *rotationRate = [DConnectMessage message];
    [DConnectDeviceOrientationProfile setAlpha:0 target:rotationRate];
    [DConnectDeviceOrientationProfile setBeta:0 target:rotationRate];
    [DConnectDeviceOrientationProfile setGamma:0 target:rotationRate];
    
    [DConnectDeviceOrientationProfile setAcceleration:acceleration target:orientation];
    [DConnectDeviceOrientationProfile setAccelerationIncludingGravity:accelerationIncludingGravity
                                                               target:orientation];
    [DConnectDeviceOrientationProfile setRotationRate:rotationRate target:orientation];
    [DConnectDeviceOrientationProfile setInterval:0 target:orientation];
    
    [DConnectDeviceOrientationProfile setOrientation:orientation target:message];
}

#pragma mark - Get Methods
/*
- (BOOL)                            profile:(DConnectDeviceOrientationProfile *)profile didReceiveGetOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                   response:(DConnectResponseMessage *)response
                                  serviceId:(NSString *)serviceId
{
    CheckDID(response, serviceId) {
        response.result = DConnectMessageResultTypeOk;
        [self setOrientation:response];
    }
    return YES;
}
*/

#pragma mark - Put Methods
#pragma mark Event Registration

/*
- (BOOL)                            profile:(DConnectDeviceOrientationProfile *)profile
    didReceivePutOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                   response:(DConnectResponseMessage *)response
                                  serviceId:(NSString *)serviceId
                                 sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
        
        DConnectMessage *event = [DConnectMessage message];
        [event setString:sessionKey forKey:DConnectMessageSessionKey];
        [event setString:serviceId forKey:DConnectMessageServiceId];
        [event setString:self.profileName forKey:DConnectMessageProfile];
        [event setString:DConnectDeviceOrientationProfileName
                  forKey:DConnectMessageAttribute];
        [self setOrientation:event];
        [_plugin asyncSendEvent:event];
    }
    
    return YES;
}
*/

#pragma mark - Delete Methods
#pragma mark Event Unregistration
/*
- (BOOL)                               profile:(DConnectDeviceOrientationProfile *)profile
    didReceiveDeleteOnDeviceOrientationRequest:(DConnectRequestMessage *)request
                                      response:(DConnectResponseMessage *)response
                                     serviceId:(NSString *)serviceId
                                    sessionKey:(NSString *)sessionKey
{
    
    CheckDIDAndSK(response, serviceId, sessionKey) {
        response.result = DConnectMessageResultTypeOk;
    }
    
    return YES;
}
*/

@end
