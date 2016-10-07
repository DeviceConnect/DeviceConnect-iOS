//
//  SonyCameraSettingsProfile.m
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "SonyCameraSettingsProfile.h"
#import "SonyCameraManager.h"
#import "RemoteApiList.h"

@implementation SonyCameraSettingsProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *putDateApiPath = [self apiPath: nil
                                   attributeName: DConnectSettingsProfileAttrDate];
        [self addPutPath: putDateApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         NSString *serviceId = [request serviceId];
                         NSString *date = [DConnectSettingsProfile dateFromRequest:request];
                         
                         SonyCameraManager *manager = [SonyCameraManager sharedManager];
                         
                         // サービスIDのチェック
                         if (![manager selectServiceId:serviceId response:response]) {
                             return YES;
                         }
                         
                         // サポートしていない
                         if (![manager.remoteApi isApiAvailable:API_setCurrentTime]) {
                             [response setErrorToNotSupportAttribute];
                             return YES;
                         }
                         
                         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             BOOL result = [manager.remoteApi setDate:date];
                             if (result) {
                                 [response setResult:DConnectMessageResultTypeOk];
                             } else {
                                 [response setErrorToUnknown];
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
