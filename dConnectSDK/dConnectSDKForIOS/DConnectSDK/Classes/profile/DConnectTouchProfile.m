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
NSString *const DConnectTouchProfileParamState = @"state";
NSString *const DConnectTouchProfileParamTouch = @"touch";
NSString *const DConnectTouchProfileParamTouches = @"touches";
NSString *const DConnectTouchProfileParamId = @"id";
NSString *const DConnectTouchProfileParamX = @"x";
NSString *const DConnectTouchProfileParamY = @"y";

@implementation DConnectTouchProfile

- (NSString *) profileName {
    return DConnectTouchProfileName;
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


@end
