//
//  DConnectPhoneProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectPhoneProfile.h"

NSString *const DConnectPhoneProfileName = @"phone";
NSString *const DConnectPhoneProfileAttrCall = @"call";
NSString *const DConnectPhoneProfileAttrSet = @"set";
NSString *const DConnectPhoneProfileAttrOnConnect = @"onconnect";
NSString *const DConnectPhoneProfileParamPhoneNumber = @"phoneNumber";
NSString *const DConnectPhoneProfileParamMode = @"mode";
NSString *const DConnectPhoneProfileParamPhoneStatus = @"phoneStatus";
NSString *const DConnectPhoneProfileParamState = @"state";

@implementation DConnectPhoneProfile

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectPhoneProfileName;
}
#pragma mark - Getter

+ (NSString *) phoneNumberFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectPhoneProfileParamPhoneNumber];
}

+ (NSNumber *) modeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectPhoneProfileParamMode];
}

#pragma mark - Setter

+ (void) setPhoneStatus:(DConnectMessage *)phoneStatus target:(DConnectMessage *)message {
    [message setMessage:phoneStatus forKey:DConnectPhoneProfileParamPhoneStatus];
}

+ (void) setState:(DConnectPhoneProfileCallState)state target:(DConnectMessage *)message {
    [message setInteger:state forKey:DConnectPhoneProfileParamState];
}

+ (void) setPhoneNumber:(NSString *)phoneNumber target:(DConnectMessage *)message {
    [message setString:phoneNumber forKey:DConnectPhoneProfileParamPhoneNumber];
}

@end
