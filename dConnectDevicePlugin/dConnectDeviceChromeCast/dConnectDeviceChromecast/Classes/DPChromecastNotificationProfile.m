//
//  DPChromecastNotificationProfile.m
//  dConnectDeviceChromeCast
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPChromecastDevicePlugin.h"
#import "DPChromecastNotificationProfile.h"
#import "DPChromecastManager.h"


@interface DPChromecastNotificationProfile ()
@end

@implementation DPChromecastNotificationProfile

- (id)init
{
    self = [super init];
    if (self) {
        __weak DPChromecastNotificationProfile *weakSelf = self;
        
        // API登録(didReceivePostNotifyRequest相当)
        NSString *postNotifyRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectNotificationProfileAttrNotify];
        [self addPostPath: postNotifyRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
//                          NSData *icon = [DConnectNotificationProfile iconFromRequest:request];
                          NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
//                          NSString *dir = [DConnectNotificationProfile dirFromRequest:request];
//                          NSString *lang = [DConnectNotificationProfile langFromRequest:request];
                          NSString *body = [DConnectNotificationProfile bodyFromRequest:request];
//                          NSString *tag = [DConnectNotificationProfile tagFromRequest:request];
                          NSString *serviceId = [request serviceId];
                          
                          // パラメータチェック
                          NSString *typeString = [request stringForKey:DConnectNotificationProfileParamType];
                          
                          if (!type || type.intValue < 0 || 3 < type.intValue
                              || (type && ![[DPChromecastManager sharedManager] existDigitWithString:typeString])) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"type is null or invalid"];
                              return YES;
                          }
                          if (!body) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"body is null"];
                              return YES;
                          }
                          
                          [DConnectNotificationProfile setNotificationId:@"dConnectDeviceChromeCast"
                                                                  target:response];
                          // リクエスト処理
                          return [weakSelf handleRequest:request
                                                response:response
                                               serviceId:serviceId
                                                callback:
                                  ^{
                                      // メッセージ送信
                                      DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                                      [mgr sendMessageWithID:serviceId message:body type:[type intValue]];
                                  }];
                          
                          return YES;
                      }];

        // API登録(didReceiveDeleteNotifyRequest相当)
        NSString *deleteNotifyRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectNotificationProfileAttrNotify];
        [self addDeletePath: deleteNotifyRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            NSString *serviceId = [request serviceId];
                            NSString *notificationId = [DConnectNotificationProfile notificationIdFromRequest:request];
                            
                            if (!notificationId
                                || (notificationId &&
                                    ![notificationId isEqualToString:@"dConnectDeviceChromeCast"])) {
                                    [response setErrorToInvalidRequestParameterWithMessage:@"NotificationId is invalid"];
                                    return YES;
                                } else if (notificationId &&
                                           [notificationId isEqualToString:@"dConnectDeviceChromeCast"]) {
                                    // リクエスト処理
                                    return [weakSelf handleRequest:request
                                                          response:response
                                                         serviceId:serviceId
                                                          callback:
                                            ^{
                                                // メッセージクリア
                                                DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                                                [mgr clearMessageWithID:serviceId];
                                            }];
                                } else {
                                    [response setErrorToUnknown];
                                    return YES;
                                }
                        }];
        
    }
    return self;
}

// 共通リクエスト処理
- (BOOL)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             serviceId:(NSString *)serviceId
             callback:(void(^)(void))callback
{
    // パラメータチェック
    if (serviceId == nil) {
        [response setErrorToEmptyServiceId];
        return YES;
    }
    
    // 接続＆メッセージクリア
    DPChromecastManager *mgr = [DPChromecastManager sharedManager];
    [mgr connectToDeviceWithID:serviceId completion:^(BOOL success, NSString *error) {
        if (success) {
            callback();
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            // エラー
            [response setErrorToNotFoundService];
        }
        [[DConnectManager sharedManager] sendResponse:response];
    }];
    return NO;
}

@end

