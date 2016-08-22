//
//  DPHostNotificationProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostDevicePlugin.h"
#import "DPHostNotificationProfile.h"
#import "DPHostService.h"
#import "DPHostUtils.h"

/*!
 通知情報を保持するNSArrayの各種情報へのインデックス
 */
typedef NS_ENUM(NSUInteger, NotificationIndex) {
    NotificationIndexType,      ///< type: 通知のタイプ
    NotificationIndexDir,       ///< dir: メッセージの文字の向き
    NotificationIndexLang,      ///< lang: メッセージの言語
    NotificationIndexBody,      ///< body: 通知メッセージ
    NotificationIndexTag,       ///< tag: 任意タグ文字列（カンマ区切りで任意個数指定）
    NotificationIndexIcon,      ///< icon: 画像データ
    NotificationIndexNotifiation, ///< Notification
    NotificationIndexServiceId,  ///< serviceId
};

@interface DPHostNotificationProfile ()

@property NSUInteger NotificationIdLength;

/// @brief イベントマネージャ
@property DConnectEventManager *eventMgr;

/// 通知に関する情報を管理するオブジェクト
@property NSMutableDictionary *notificationInfoDict;

/*!
 OnClickイベントメッセージを送信する
 @param notificationId イベントが発生した通知の通知ID
 @param serviceId サービスID
 */
- (void) sendOnClickEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId;
/*!
 OnShowイベントメッセージを送信する
 @param notificationId イベントが発生した通知の通知ID
 @param serviceId サービスID
 */
- (void) sendOnShowEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId;
/*!
 OnCloseイベントメッセージを送信する
 @param notificationId イベントが発生した通知の通知ID
 @param serviceId サービスID
 */
- (void) sendOnCloseEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId;

@end

@implementation DPHostNotificationProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak DPHostNotificationProfile *weakSelf = self;
        
        // イベントマネージャを取得
        self.eventMgr = [DConnectEventManager sharedManagerForClass:[DPHostDevicePlugin class]];
        
        _notificationInfoDict = @{}.mutableCopy;
        
        [self setNotificationIdLength: 3];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf
                                                     selector:@selector(didReceiveLocalNotification:)
                                                         name:@"UIApplicationDidReceiveLocalNotification"
                                                       object:nil];
        });

        // API登録(didReceivePostNotifyRequest相当)
        NSString *postNotifyRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectNotificationProfileAttrNotify];
        [self addPostPath: postNotifyRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSData *icon = [DConnectNotificationProfile iconFromRequest:request];
                         NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
                         NSString *dir = [DConnectNotificationProfile dirFromRequest:request];
                         NSString *lang = [DConnectNotificationProfile langFromRequest:request];
                         NSString *body = [DConnectNotificationProfile bodyFromRequest:request];
                         NSString *tag = [DConnectNotificationProfile tagFromRequest:request];
                         NSString *serviceId = [request serviceId];
                         
                         if (!body) {
                             [response setError:100 message:@"body is nill"];
                             return YES;
                         }
                         if (!type || type.intValue < 0 || 3 < type.intValue) {
                             [response setErrorToInvalidRequestParameterWithMessage:@"type is null or invalid"];
                             return YES;
                         }
                         NSString *notificationId = [DPHostUtils randomStringWithLength:[weakSelf NotificationIdLength]];
                         do {
                             notificationId = [DPHostUtils randomStringWithLength:[weakSelf NotificationIdLength]];
                         } while ([weakSelf notificationInfoDict][notificationId]);
                         UILocalNotification *notification;
                         NSString *status = @"EVENT \n";
                         switch ([type intValue]) {
                             case DConnectNotificationProfileNotificationTypePhone:
                                 status = @"PHONE \n";
                                 break;
                             case DConnectNotificationProfileNotificationTypeMail:
                                 status = @"MAIL \n";
                                 break;
                             case DConnectNotificationProfileNotificationTypeSMS:
                                 status = @"SMS \n";
                                 break;
                             case DConnectNotificationProfileNotificationTypeEvent:
                                 status = @"EVENT \n";
                                 break;
                             default:
                                 [response setErrorToInvalidRequestParameterWithMessage:@"Not support type"];
                                 return YES;
                         }
                         notification = [self scheduleWithAlertBody:[status stringByAppendingString:body]
                                                           userInfo:@{@"id":notificationId,@"serviceId":serviceId}];
                         
                         // 通知情報を生成し、notificationInfoDictにて管理
                         NSMutableArray *notificationInfo =
                         @[type,
                           dir  ? dir  : [NSNull null],
                           lang ? lang : [NSNull null],
                           body ? body : [NSNull null],
                           tag  ? tag  : [NSNull null],
                           icon ? icon : [NSNull null],
                           notification,
                           serviceId].mutableCopy;
                         [weakSelf notificationInfoDict][notificationId] = notificationInfo;
                         [weakSelf sendOnShowEventWithNotificaitonId:notificationId
                                                           serviceId:[weakSelf notificationInfoDict][notificationId][NotificationIndexServiceId]];
                         [response setString:notificationId forKey:DConnectNotificationProfileParamNotificationId];
                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnClickRequest相当)
        NSString *putOnClickRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectNotificationProfileAttrOnClick];
        [self addPutPath: putOnClickRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnShowRequest相当)
        NSString *putOnShowRequestApiPath = [self apiPath: nil
                                            attributeName: DConnectNotificationProfileAttrOnShow];
        [self addPutPath: putOnShowRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceivePutOnCloseRequest相当)
        NSString *putOnCloseRequestApiPath = [self apiPath: nil
                                             attributeName: DConnectNotificationProfileAttrOnClose];
        [self addPutPath: putOnCloseRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         switch ([[weakSelf eventMgr] addEventForRequest:request]) {
                             case DConnectEventErrorNone:             // エラー無し.
                                 [response setResult:DConnectMessageResultTypeOk];
                                 break;
                             case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                 [response setErrorToInvalidRequestParameter];
                                 break;
                             case DConnectEventErrorNotFound:         // マッチするイベント無し.
                             case DConnectEventErrorFailed:           // 処理失敗.
                                 [response setErrorToUnknown];
                                 break;
                         }
                         
                         return YES;
                     }];
        
        // API登録(didReceiveDeleteNotifyRequest相当)
        NSString *deleteNotifyRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectNotificationProfileAttrNotify];
        [self addDeletePath: deleteNotifyRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                            NSString *serviceId = [request serviceId];
                            NSString *notificationId = [DConnectNotificationProfile notificationIdFromRequest:request];
                            
                            if (!notificationId) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"notificationId must be specified."];
                                return YES;
                            }
                            if (![weakSelf notificationInfoDict][notificationId]) {
                                [response setErrorToInvalidRequestParameterWithMessage:@"Specified notificationId does not exist."];
                                return YES;
                            }
                            
                            
                            UILocalNotification *notification =  [weakSelf notificationInfoDict][notificationId][NotificationIndexNotifiation];
                            [[UIApplication sharedApplication] cancelLocalNotification:notification];
                            [weakSelf sendOnCloseEventWithNotificaitonId:notificationId serviceId:serviceId];
                            [[weakSelf notificationInfoDict] removeObjectForKey:notificationId];
                            [response setResult:DConnectMessageResultTypeOk];
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnClickRequest相当)
        NSString *deleteOnClickRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectNotificationProfileAttrOnClick];
        [self addDeletePath: deleteOnClickRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // エラー無し.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                                case DConnectEventErrorFailed:           // 処理失敗.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnShowRequest相当)
        NSString *deleteOnShowRequestApiPath = [self apiPath: nil
                                               attributeName: DConnectNotificationProfileAttrOnShow];
        [self addDeletePath: deleteOnShowRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // エラー無し.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                                case DConnectEventErrorFailed:           // 処理失敗.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
        
        // API登録(didReceiveDeleteOnCloseRequest相当)
        NSString *deleteOnCloseRequestApiPath = [self apiPath: nil
                                                attributeName: DConnectNotificationProfileAttrOnClose];
        [self addDeletePath: deleteOnCloseRequestApiPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            
                            switch ([[weakSelf eventMgr] removeEventForRequest:request]) {
                                case DConnectEventErrorNone:             // エラー無し.
                                    [response setResult:DConnectMessageResultTypeOk];
                                    break;
                                case DConnectEventErrorInvalidParameter: // 不正なパラメータ.
                                    [response setErrorToInvalidRequestParameter];
                                    break;
                                case DConnectEventErrorNotFound:         // マッチするイベント無し.
                                case DConnectEventErrorFailed:           // 処理失敗.
                                    [response setErrorToUnknown];
                                    break;
                            }
                            
                            return YES;
                        }];
    }
    return self;
}


-(void)didReceiveLocalNotification:(NSNotification*)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo) {
        [self sendOnClickEventWithNotificaitonId:userInfo[@"id"] serviceId:userInfo[@"serviceId"]];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIApplicationDidReceiveLocalNotification"
                                                  object:nil];
}



- (void) sendOnClickEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectNotificationProfileName
                                          attribute:DConnectNotificationProfileAttrOnClick];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectNotificationProfile setNotificationId:notificationId target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (void) sendOnShowEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectNotificationProfileName
                                          attribute:DConnectNotificationProfileAttrOnShow];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectNotificationProfile setNotificationId:notificationId target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

- (void) sendOnCloseEventWithNotificaitonId:(NSString *)notificationId serviceId:(NSString *)serviceId
{
    // イベントの取得
    NSArray *evts = [_eventMgr eventListForServiceId:DPHostDevicePluginServiceId
                                            profile:DConnectNotificationProfileName
                                          attribute:DConnectNotificationProfileAttrOnClose];
    // イベント送信
    for (DConnectEvent *evt in evts) {
        DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:evt];
        [DConnectNotificationProfile setNotificationId:notificationId target:eventMsg];
        
        [SELF_PLUGIN sendEvent:eventMsg];
    }
}

#pragma mark - private method


// ローカル通知を作成する
- (UILocalNotification *)scheduleWithAlertBody:(NSString *)alertBody userInfo:(NSDictionary *) userInfo {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    [notification setUserInfo:userInfo];
    [notification setTimeZone:[NSTimeZone systemTimeZone]];
    [notification setAlertBody:alertBody];
    [notification setUserInfo:userInfo];
    [notification setAlertAction:@"Open"];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    return notification;
}

@end
