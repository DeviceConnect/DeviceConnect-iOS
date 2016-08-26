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
        
        // API登録(didReceiveGetZoomRequest相当)
        NSString *getZoomRequestApiPath = [self apiPath: nil
                                          attributeName: SonyCameraCameraProfileAttrZoom];
        [self addGetPath: getZoomRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_actZoom]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            if (manager.remoteApi.zoomPosition < 0) {
                [response setErrorToIllegalDeviceState];
            } else {
                // ズームのデータ
                [response setResult:DConnectMessageResultTypeOk];
                [response setDouble:manager.remoteApi.zoomPosition
                             forKey:SonyCameraCameraProfileParamZoomdiameter];
            }
            return YES;
        }];
        
        // API登録(didReceivePutZoomRequest相当)
        NSString *putZoomRequestApiPath = [self apiPath: nil
                                          attributeName: SonyCameraCameraProfileAttrZoom];
        [self addPutPath: putZoomRequestApiPath api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
            
            NSString *serviceId = [request serviceId];
            NSString *direction = [request stringForKey:SonyCameraCameraProfileParamDirection];
            NSString *movement = [request stringForKey:SonyCameraCameraProfileParamMovement];
            
            SonyCameraManager *manager = [SonyCameraManager sharedManager];
            
            // サービスIDのチェック
            if (![manager selectServiceId:serviceId response:response]) {
                return YES;
            }
            
            // サポートしていない
            if (![manager.remoteApi isApiAvailable:API_actZoom]) {
                [response setErrorToNotSupportAttribute];
                return YES;
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *dict = [manager.remoteApi actZoom:direction movement:movement];
                if (dict == nil) {
                    [response setErrorToTimeout];
                } else {
                    NSString *errorMessage = @"";
                    NSInteger errorCode = -1;
                    NSArray *resultArray = dict[@"result"];
                    NSArray *errorArray = dict[@"error"];
                    if (errorArray && errorArray.count > 0) {
                        errorCode = (NSInteger) errorArray[0];
                        errorMessage = errorArray[1];
                    }
                    
                    // レスポンス作成
                    if (resultArray.count <= 0 && errorCode >= 0) {
                        [response setErrorToInvalidRequestParameter];
                    } else {
                        [response setResult:DConnectMessageResultTypeOk];
                    }
                }
                
                // レスポンスを返却
                [[DConnectManager sharedManager] sendResponse:response];
            });
            
            // レスポンスは非同期で返却するので
            return NO;
        }];
    }
    return self;
}

@end
