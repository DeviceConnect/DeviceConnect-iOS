//
//  DPChromecastNotificationProfile.m
//  DConnectSDK
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
        self.delegate = self;
    }
    return self;
}

// 共通リクエスト処理
- (BOOL)handleRequest:(DConnectRequestMessage *)request
             response:(DConnectResponseMessage *)response
             serviceId:(NSString *)serviceId
             callback:(void(^)())callback
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



#pragma mark - Post Methods

// ノーティフィケーションの表示リクエストを受け取った
- (BOOL)            profile:(DConnectNotificationProfile *)profile
didReceivePostNotifyRequest:(DConnectRequestMessage *)request
                   response:(DConnectResponseMessage *)response
                   serviceId:(NSString *)serviceId
                       type:(NSNumber *)type
                        dir:(NSString *)dir
                       lang:(NSString *)lang
                       body:(NSString *)body
                        tag:(NSString *)tag
                       icon:(NSData *)icon
{
    // パラメータチェック
    if (!type || type.intValue<0 || 2<type.intValue) {
        [response setErrorToInvalidRequestParameterWithMessage:@"type is null or invalid"];
        return YES;
    }
    if (!body) {
        [response setErrorToInvalidRequestParameterWithMessage:@"body is null"];
        return YES;
    }
    
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // メッセージ送信
                DPChromecastManager *mgr = [DPChromecastManager sharedManager];
                [mgr sendMessageWithID:serviceId message:body type:[type intValue]];
            }];
}


#pragma mark - Delete Methods

// ノーティフィケーションの削除リクエストを受け取った
- (BOOL)              profile:(DConnectNotificationProfile *)profile
didReceiveDeleteNotifyRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response
                     serviceId:(NSString *)serviceId
               notificationId:(NSString *)notificationId
{
    // リクエスト処理
    return [self handleRequest:request
                      response:response
                      serviceId:serviceId
                      callback:
            ^{
                // メッセージクリア
                DPChromecastManager *mgr = [DPChromecastManager sharedManager];
				[mgr clearMessageWithID:serviceId];
            }];
}

@end

