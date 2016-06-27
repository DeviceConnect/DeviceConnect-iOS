
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

@interface DConnectNotificationProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectNotificationProfile

#pragma mark - DConnectProfile Methods

- (NSString *) profileName {
    return DConnectNotificationProfileName;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrNotify]) {
        
        if ([self hasMethod:@selector(profile:
                                      didReceivePostNotifyRequest:
                                      response:
                                      serviceId:
                                      type:
                                      dir:
                                      lang:
                                      body:
                                      tag:
                                      icon:)
                   response:response])
        {
            NSData *icon = [DConnectNotificationProfile iconFromRequest:request];
            NSNumber *type = [DConnectNotificationProfile typeFromRequest:request];
            NSString *dir = [DConnectNotificationProfile dirFromRequest:request];
            NSString *lang = [DConnectNotificationProfile langFromRequest:request];
            NSString *body = [DConnectNotificationProfile bodyFromRequest:request];
            NSString *tag = [DConnectNotificationProfile tagFromRequest:request];
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceivePostNotifyRequest:request response:response
                             serviceId:serviceId type:type dir:dir
                                 lang:lang body:body tag:tag
                                 icon:icon];

        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnClick]) {
        
        if ([self hasMethod:@selector(profile:didReceivePutOnClickRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnClickRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnClose]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnCloseRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnCloseRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnError]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnErrorRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnErrorRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnShow]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnShowRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutOnShowRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *) request response:(DConnectResponseMessage *) response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    NSString *sessionKey = [request sessionKey];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnClick]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnClickRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnClickRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnClose]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnCloseRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnCloseRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnError]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnErrorRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnErrorRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrOnShow]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnShowRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteOnShowRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectNotificationProfileAttrNotify]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteNotifyRequest:response:serviceId:notificationId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveDeleteNotifyRequest:request response:response
                             serviceId:serviceId
                       notificationId:[DConnectNotificationProfile notificationIdFromRequest:request]];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
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

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
