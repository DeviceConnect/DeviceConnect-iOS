//
//  DConnectKeyEventProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectKeyEventProfile.h"

NSString *const DConnectKeyEventProfileName = @"keyEvent";
NSString *const DConnectKeyEventProfileAttrKeyEvent = @"keyevent";
NSString *const DConnectKeyEventProfileAttrOnDown = @"ondown";
NSString *const DConnectKeyEventProfileAttrOnUp = @"onup";
NSString *const DConnectKeyEventProfileParamKeyEvent = @"keyevent";
NSString *const DConnectKeyEventProfileParamId = @"id";
NSString *const DConnectKeyEventProfileParamConfig = @"config";
int const DConnectKeyEventProfileKeyTypeStdKey = 0x00000000;
int const DConnectKeyEventProfileKeyTypeMediaCtrl = 0x00000200;
int const DConnectKeyEventProfileKeyTypeDpadButton = 0x00000400;
int const DConnectKeyEventProfileKeyTypeUser = 0x00000800;

@interface DConnectKeyEventProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectKeyEventProfile

- (NSString *) profileName {
    return DConnectKeyEventProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectKeyEventProfileAttrOnDown]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnDownRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnDownRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else if ([self isEqualToAttribute:attribute cmp:DConnectKeyEventProfileAttrOnUp]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnUpRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnUpRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectKeyEventProfileAttrOnDown]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnDownRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnDownRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectKeyEventProfileAttrOnUp]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnUpRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnUpRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectKeyEventProfileAttrOnDown]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnDownRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnDownRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectKeyEventProfileAttrOnUp]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnUpRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnUpRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToUnknownAttribute];
        }
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

#pragma mark - Setter
+ (void) setKeyEvent:(DConnectMessage *)keyevent target:(DConnectMessage *)message {
    [message setMessage:keyevent forKey:DConnectKeyEventProfileParamKeyEvent];
}

+ (void) setId:(int)id target:(DConnectMessage *)message {
    [message setInteger:id forKey:DConnectKeyEventProfileParamId];
}

+ (void) setConfig:(NSString *)config target:(DConnectMessage *)message {
    [message setString:config forKey:DConnectKeyEventProfileParamConfig];
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
