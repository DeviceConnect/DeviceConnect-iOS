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
NSString *const DConnectKeyEventProfileAttrOnKeyChange = @"onkeychange";
NSString *const DConnectKeyEventProfileParamKeyEvent = @"keyevent";
NSString *const DConnectKeyEventProfileParamId = @"id";
NSString *const DConnectKeyEventProfileParamConfig = @"config";
NSString *const DConnectKeyEventProfileParamState = @"state";
int const DConnectKeyEventProfileKeyTypeStdKey = 0x00000000;
int const DConnectKeyEventProfileKeyTypeMediaCtrl = 0x00000200;
int const DConnectKeyEventProfileKeyTypeDpadButton = 0x00000400;
int const DConnectKeyEventProfileKeyTypeUser = 0x00000800;
NSString *const DConnectKeyEventProfileKeyStateDown = @"down";
NSString *const DConnectKeyEventProfileKeyStateUp = @"up";
@implementation DConnectKeyEventProfile

- (NSString *) profileName {
    return DConnectKeyEventProfileName;
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

+ (void) setState:(NSString *)state target:(DConnectMessage *)message {
    [message setString:state forKey:DConnectKeyEventProfileParamState];
}

@end
