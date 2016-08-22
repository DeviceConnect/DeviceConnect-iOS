
//
//  NotificationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectNotificationProfile.h"

NSString *const DConnectNotificationProfileName = @"notification";
NSString *const DConnectNotificationProfileAttrNotify = @"notify";
NSString *const DConnectNotificationProfileAttrOnClick = @"onclick";
NSString *const DConnectNotificationProfileAttrOnShow = @"onshow";
NSString *const DConnectNotificationProfileAttrOnClose = @"onclose";
NSString *const DConnectNotificationProfileAttrOnError = @"onerror";
NSString *const DConnectNotificationProfileParamBody = @"body";
NSString *const DConnectNotificationProfileParamType = @"type";
NSString *const DConnectNotificationProfileParamDir = @"dir";
NSString *const DConnectNotificationProfileParamLang = @"lang";
NSString *const DConnectNotificationProfileParamTag = @"tag";
NSString *const DConnectNotificationProfileParamIcon = @"icon";
NSString *const DConnectNotificationProfileParamNotificationId = @"notificationId";
NSString *const DConnectNotificationProfileParamUri = @"uri";

@implementation DConnectNotificationProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectNotificationProfileName;
}

#pragma mark - Setter

+ (void) setNotificationId:(NSString *)notificationId target:(DConnectMessage *)message {
    [message setString:notificationId forKey:DConnectNotificationProfileParamNotificationId];
}

#pragma mark - Getter

+ (NSNumber *) typeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectNotificationProfileParamType];
}

+ (NSString *) dirFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectNotificationProfileParamDir];
}

+ (NSString *) langFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectNotificationProfileParamLang];
}

+ (NSString *) bodyFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectNotificationProfileParamBody];
}

+ (NSString *) tagFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectNotificationProfileParamTag];
}

+ (NSString *) notificationIdFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectNotificationProfileParamNotificationId];
}

+ (NSData *) iconFromRequest:(DConnectMessage *)request {
    return [request dataForKey:DConnectNotificationProfileParamIcon];
}

@end
