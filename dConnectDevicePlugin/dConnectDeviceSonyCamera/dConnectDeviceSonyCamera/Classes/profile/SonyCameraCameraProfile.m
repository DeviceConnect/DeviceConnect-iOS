//
//  SonyCameraCameraProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraCameraProfile.h"

NSString *const SonyCameraCameraProfileName = @"camera";
NSString *const SonyCameraCameraProfileAttrZoom = @"zoom";
NSString *const SonyCameraCameraProfileParamDirection = @"direction";
NSString *const SonyCameraCameraProfileParamMovement = @"movement";
NSString *const SonyCameraCameraProfileParamZoomdiameter = @"zoomPosition";

@interface SonyCameraCameraProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation SonyCameraCameraProfile

- (NSString *) profileName {
    return SonyCameraCameraProfileName;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    NSString *serviceId = [request serviceId];
    NSString *attribute = [request attribute];
    
    if (attribute) {
        if ([self isEqualToAttribute:attribute cmp:SonyCameraCameraProfileAttrZoom]) {
            NSString *direction = [request stringForKey:SonyCameraCameraProfileParamDirection];
            NSString *movement = [request stringForKey:SonyCameraCameraProfileParamMovement];
            if ([self hasMethod:
                    @selector(profile:
                              didReceivePutZoomRequest:
                              response:
                              serviceId:
                              direction:
                              movement:)
                    response:response]) {
                send = [_delegate        profile:self
                        didReceivePutZoomRequest:request
                                        response:response
                                       serviceId:serviceId
                                       direction:direction
                                        movement:movement];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    NSString *serviceId = [request serviceId];
    NSString *attribute = [request attribute];
    
    if (attribute) {
        if ([self isEqualToAttribute:attribute cmp:SonyCameraCameraProfileAttrZoom]) {
            if ([self hasMethod:@selector(profile:
                                          didReceiveGetZoomRequest:
                                          response:
                                          serviceId:)
                       response:response]) {
                send = [_delegate        profile:self
                        didReceiveGetZoomRequest:request
                                        response:response
                                       serviceId:serviceId];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
