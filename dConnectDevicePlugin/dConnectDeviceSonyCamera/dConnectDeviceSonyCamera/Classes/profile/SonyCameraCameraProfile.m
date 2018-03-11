//
//  SonyCameraCameraProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraCameraProfile.h"
#import "SonyCameraManager.h"
#import "RemoteApiList.h"

NSString *const SonyCameraCameraProfileName = @"camera";
NSString *const SonyCameraCameraProfileAttrZoom = @"zoom";
NSString *const SonyCameraCameraProfileParamDirection = @"direction";
NSString *const SonyCameraCameraProfileParamMovement = @"movement";
NSString *const SonyCameraCameraProfileParamZoomdiameter = @"zoomPosition";

@implementation SonyCameraCameraProfile

- (NSString *) profileName {
    return SonyCameraCameraProfileName;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;

        // API登録(didReceiveGetZoomRequest相当)
        NSString *getZoomRequestApiPath = [self apiPath: nil
                                          attributeName: SonyCameraCameraProfileAttrZoom];
        [self addGetPath: getZoomRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceiveGetZoomRequest:request response:response];
        }];
        
        // API登録(didReceivePutZoomRequest相当)
        NSString *putZoomRequestApiPath = [self apiPath: nil
                                          attributeName: SonyCameraCameraProfileAttrZoom];
        [self addPutPath: putZoomRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            return [weakSelf didReceivePutZoomRequest:request response:response];
        }];
    }
    return self;
}

#pragma mark - Private Methods -

-(BOOL) didReceiveGetZoomRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    
    // サポートしていない
    if (![manager isSupportedZoom]) {
        [response setErrorToNotSupportAttribute];
        return YES;
    }
    
    double zoom = [manager getZoom];
    if (zoom < 0) {
        [response setErrorToIllegalDeviceState];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [response setDouble:zoom forKey:SonyCameraCameraProfileParamZoomdiameter];
    }
    return YES;
}

- (BOOL) didReceivePutZoomRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    SonyCameraDevicePlugin *plugin = (SonyCameraDevicePlugin *)self.plugin;
    SonyCameraManager *manager = plugin.sonyCameraManager;
    NSString *serviceId = [request serviceId];
    NSString *direction = [request stringForKey:SonyCameraCameraProfileParamDirection];
    NSString *movement = [request stringForKey:SonyCameraCameraProfileParamMovement];
    
    // サービスIDのチェック
    if (![manager isConnectedService:serviceId]) {
        [response setErrorToIllegalDeviceStateWithMessage:@"Sony's camera is not ready."];
        return YES;
    }
    if (!direction ||!movement) {
        [response setErrorToInvalidRequestParameter];
        return YES;
    }
    if (![direction isEqualToString:@"in"]) {
        if (![direction isEqualToString:@"out"]) {
            [response setErrorToInvalidRequestParameter];
            return YES;
        }
    }
    
    if (![movement isEqualToString:@"in-start"]) {
        if (![movement isEqualToString:@"in-stop"]) {
            if (![movement isEqualToString:@"1shot"]) {
                if (![movement isEqualToString:@"max"]) {
                    [response setErrorToInvalidRequestParameter];
                    return YES;
                }
            }
        }
    }
    // サポートしていない
    if (![manager isSupportedZoom]) {
        [response setErrorToNotSupportAttribute];
        return YES;
    }
    
    [manager setZoomByDirection:direction movement:movement block:^(int errorCode, NSString *errorMessage) {
        if (errorCode == 0) {
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToInvalidRequestParameter];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    
    // レスポンスは非同期で返却するので
    return NO;
}

@end
