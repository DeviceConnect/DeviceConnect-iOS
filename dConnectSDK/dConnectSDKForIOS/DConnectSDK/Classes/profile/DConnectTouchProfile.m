//
//  DConnectTouchProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectTouchProfile.h"

NSString *const DConnectTouchProfileName = @"touch";
NSString *const DConnectTouchProfileAttrOnTouch = @"ontouch";
NSString *const DConnectTouchProfileAttrOnTouchStart = @"ontouchstart";
NSString *const DConnectTouchProfileAttrOnTouchEnd = @"ontouchend";
NSString *const DConnectTouchProfileAttrOnDoubleTap = @"ondoubletap";
NSString *const DConnectTouchProfileAttrOnTouchMove = @"ontouchmove";
NSString *const DConnectTouchProfileAttrOnTouchCancel = @"ontouchcancel";
NSString *const DConnectTouchProfileParamTouch = @"touch";
NSString *const DConnectTouchProfileParamTouches = @"touches";
NSString *const DConnectTouchProfileParamId = @"id";
NSString *const DConnectTouchProfileParamX = @"x";
NSString *const DConnectTouchProfileParamY = @"y";

@interface DConnectTouchProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectTouchProfile

- (NSString *) profileName {
    return DConnectTouchProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    
    if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouch]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnTouchRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnTouchRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchStart]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnTouchStartRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnTouchStartRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchEnd]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnTouchEndRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnTouchEndRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnDoubleTap]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnDoubleTapRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnDoubleTapRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchMove]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnTouchMoveRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnTouchMoveRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchCancel]) {
        if ([self hasMethod:@selector(profile:didReceiveGetOnTouchCancelRequest:response:serviceId:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            send = [_delegate profile:self didReceiveGetOnTouchCancelRequest:request
                             response:response serviceId:serviceId];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
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
    
    if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouch]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnTouchRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnTouchRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchStart]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnTouchStartRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnTouchStartRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchEnd]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnTouchEndRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnTouchEndRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnDoubleTap]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnDoubleTapRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnDoubleTapRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchMove]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnTouchMoveRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnTouchMoveRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchCancel]) {
        if ([self hasMethod:@selector(profile:didReceivePutOnTouchCancelRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceivePutOnTouchCancelRequest:request
                             response:response serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
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
    
    if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouch]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnTouchRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnTouchRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchStart]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnTouchStartRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnTouchStartRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchEnd]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnTouchEndRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnTouchEndRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnDoubleTap]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnDoubleTapRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnDoubleTapRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchMove]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnTouchMoveRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnTouchMoveRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectTouchProfileAttrOnTouchCancel]) {
        if ([self hasMethod:@selector(profile:didReceiveDeleteOnTouchCancelRequest:response:serviceId:sessionKey:)
                   response:response])
        {
            NSString *serviceId = [request serviceId];
            NSString *sessionKey = [request sessionKey];
            send = [_delegate profile:self didReceiveDeleteOnTouchCancelRequest:request response:response
                             serviceId:serviceId sessionKey:sessionKey];
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter
+ (void) setTouch:(DConnectMessage *)touch target:(DConnectMessage *)message {
    [message setMessage:touch forKey:DConnectTouchProfileParamTouch];
}

+ (void) setTouches:(DConnectArray *)touches target:(DConnectMessage *)message {
    [message setArray:touches forKey:DConnectTouchProfileParamTouches];
}

+ (void) setId:(int)id target:(DConnectMessage *)message {
    [message setInteger:id forKey:DConnectTouchProfileParamId];
}
+ (void) setX:(int)x target:(DConnectMessage *)message {
    [message setInteger:x forKey:DConnectTouchProfileParamX];
}

+ (void) setY:(int)y target:(DConnectMessage *)message {
    [message setInteger:y forKey:DConnectTouchProfileParamY];
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
