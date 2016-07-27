//
//  DPPebbleNotificationProfile.m
//  dConnectDevicePebble
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPPebbleNotificationProfile.h"
#import "DPPebbleManager.h"

@interface DPPebbleNotificationProfile ()
@end

@implementation DPPebbleNotificationProfile

// 初期化
- (id)init
{
	self = [super init];
	if (self) {
		self.delegate = self;
//        __weak DPPebbleNotificationProfile *weakSelf = self;
        
		// 通知許可を得る
		UIApplication *application = [UIApplication sharedApplication];
		if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
			UIUserNotificationSettings *settings
                            = [UIUserNotificationSettings
                                settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound
                                      categories:nil];
			[application registerUserNotificationSettings:settings];
		}
        
        // API登録(didReceivePostNotifyRequest相当)
        NSString *postNotifyRequestApiPath = [self apiPathWithProfile: self.profileName
                                                        interfaceName: nil
                                                        attributeName: DConnectNotificationProfileAttrNotify];
        [self addPostPath: postNotifyRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                          
//                          NSData *icon = [DConnectNotificationProfile iconFromRequest:request];
                          NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
//                          NSString *dir = [DConnectNotificationProfile dirFromRequest:request];
//                          NSString *lang = [DConnectNotificationProfile langFromRequest:request];
                          NSString *body = [DConnectNotificationProfile bodyFromRequest:request];
//                          NSString *tag = [DConnectNotificationProfile tagFromRequest:request];
//                          NSString *serviceId = [request serviceId];
                          
                          // パラメータチェック
                          NSString *typeString = [request stringForKey:DConnectNotificationProfileParamType];
                          
                          if (!type || type.intValue < 0 || 3 < type.intValue
                              || (type && ![[DPPebbleManager sharedManager] existDigitWithString:typeString])) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"type is null or invalid"];
                              return YES;
                          }
                          if (!body) {
                              [response setErrorToInvalidRequestParameterWithMessage:@"body is null"];
                              return YES;
                          }
                          // LocalNotificationを発動させるとPebbleのNotificationに通知が行く
                          // FIXME:この方式だとServiceID無視で全デバイスに通知が行ってしまう。
                          UILocalNotification *notify = [[UILocalNotification alloc] init];
                          notify.fireDate = [NSDate new];
                          notify.alertBody = body.length>0 ? body : @" ";
                          [[UIApplication sharedApplication] scheduleLocalNotification:notify];
                          
                          //IDは取得できないので、処理のしようがない
                          [DConnectNotificationProfile setNotificationId:@"0" target:response];
                          [response setResult:DConnectMessageResultTypeOk];
                          
                          return YES;
                      }];
	}
	return self;
}

@end
