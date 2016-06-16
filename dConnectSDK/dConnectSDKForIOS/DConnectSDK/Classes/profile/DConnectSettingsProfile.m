//
//  DConnectSettingsProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSettingsProfile.h"

NSString *const DConnectSettingsProfileName = @"settings";
NSString *const DConnectSettingsProfileInterfaceSound = @"sound";
NSString *const DConnectSettingsProfileInterfaceDisplay = @"display";
NSString *const DConnectSettingsProfileAttrVolume = @"volume";
NSString *const DConnectSettingsProfileAttrDate = @"date";
NSString *const DConnectSettingsProfileAttrLight = @"light";
NSString *const DConnectSettingsProfileAttrSleep = @"sleep";
NSString *const DConnectSettingsProfileParamKind = @"kind";
NSString *const DConnectSettingsProfileParamLevel = @"level";
NSString *const DConnectSettingsProfileParamDate = @"date";
NSString *const DConnectSettingsProfileParamTime = @"time";
const double DConnectSettingsProfileMaxLevel = 1.0;
const double DConnectSettingsProfileMinLevel = 0.0;

@interface DConnectSettingsProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;
+ (void) setLevel:(double)level target:(DConnectMessage *)message;

@end

@implementation DConnectSettingsProfile

- (NSString *) profileName {
    return DConnectSettingsProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (interface) {
        if ([self isEqualToInterface: interface cmp:DConnectSettingsProfileInterfaceSound] &&
            [self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrVolume])
        {
            if ([self hasMethod:@selector(profile:didReceiveGetVolumeRequest:response:serviceId:kind:)
                       response:response])
            {
                send = [_delegate profile:self didReceiveGetVolumeRequest:request response:response
                                 serviceId:serviceId
                                     kind:[DConnectSettingsProfile volumeKindFromRequest:request]];
            }
        } else if ([self isEqualToInterface: interface cmp:DConnectSettingsProfileInterfaceDisplay]) {
            if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrLight]) {
                if ([self hasMethod:@selector(profile:didReceiveGetLightRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveGetLightRequest:request
                                     response:response serviceId:serviceId];
                }
            } else if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrSleep]) {
                if ([self hasMethod:@selector(profile:didReceiveGetSleepRequest:response:serviceId:)
                           response:response])
                {
                    send = [_delegate profile:self didReceiveGetSleepRequest:request
                                     response:response serviceId:serviceId];
                }
            } else {
                [response setErrorToNotSupportProfile];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrDate]) {
        if ([self hasMethod:@selector(profile:didReceiveGetDateRequest:response:serviceId:)
                   response:response])
        {
            send = [_delegate profile:self didReceiveGetDateRequest:request
                             response:response serviceId:serviceId];
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
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (interface) {
        if ([self isEqualToInterface: interface cmp:DConnectSettingsProfileInterfaceSound] &&
            [self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrVolume]) {
            
            if ([self hasMethod:@selector(profile:didReceivePutVolumeRequest:response:serviceId:kind:level:)
                       response:response])
            {
                send = [_delegate profile:self didReceivePutVolumeRequest:request response:response serviceId:serviceId
                                     kind:[DConnectSettingsProfile volumeKindFromRequest:request]
                                    level:[DConnectSettingsProfile levelFromRequest:request]];
            }
        } else if ([self isEqualToInterface: interface cmp:DConnectSettingsProfileInterfaceDisplay]) {
            if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrLight]) {
                if ([self hasMethod:@selector(profile:didReceivePutLightRequest:response:serviceId:level:)
                           response:response])
                {
                    send = [_delegate             profile:self
                                didReceivePutLightRequest:request
                                                 response:response
                                                serviceId:serviceId
                                                    level:[DConnectSettingsProfile
                                                           levelFromRequest:request]];
                }
            } else if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrSleep]) {
                if ([self hasMethod:@selector(profile:didReceivePutSleepRequest:response:serviceId:time:)
                           response:response])
                {
                    send = [_delegate             profile:self
                                didReceivePutSleepRequest:request
                                                 response:response
                                                serviceId:serviceId
                                                     time:[DConnectSettingsProfile
                                                           timeFromRequest:request]];
                }
            } else {
                [response setErrorToNotSupportProfile];
            }
        } else {
            [response setErrorToNotSupportProfile];
        }
    } else if ([self isEqualToAttribute: attribute cmp:DConnectSettingsProfileAttrDate]) {
        if ([self hasMethod:@selector(profile:didReceivePutDateRequest:response:serviceId:date:)
                   response:response])
        {
            send = [_delegate profile:self didReceivePutDateRequest:request response:response serviceId:serviceId
                                 date:[DConnectSettingsProfile dateFromRequest:request]];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Getter

+ (DConnectSettingsProfileVolumeKind) volumeKindFromRequest:(DConnectMessage *)request {
    int code = [request integerForKey:DConnectSettingsProfileParamKind];
    switch (code) {
        case DConnectSettingsProfileVolumeKindUnknown:
        case DConnectSettingsProfileVolumeKindAlarm:
        case DConnectSettingsProfileVolumeKindCall:
        case DConnectSettingsProfileVolumeKindMail:
        case DConnectSettingsProfileVolumeKindRingtone:
        case DConnectSettingsProfileVolumeKindOther:
            return code;
        default:
            return DConnectSettingsProfileVolumeKindUnknown;
    }
}

+ (NSString *) dateFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectSettingsProfileParamDate];
}

+ (NSNumber *) levelFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectSettingsProfileParamLevel];
}

+ (NSNumber *) timeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectSettingsProfileParamTime];
}


#pragma mark - Setter

+ (void) setLevel:(double)level target:(DConnectMessage *)message {
    if (level < DConnectSettingsProfileMinLevel ||
        level > DConnectSettingsProfileMaxLevel) {
        @throw [NSString stringWithFormat:@"level must be between %f and %f.",
                DConnectSettingsProfileMinLevel,
                DConnectSettingsProfileMaxLevel];
    }
    [message setDouble:level forKey:DConnectSettingsProfileParamLevel];
}

+ (void) setVolumeLevel:(double)level target:(DConnectMessage *)message {
    [self setLevel:level target:message];
}

+ (void) setLightLevel:(double)level target:(DConnectMessage *)message {
    [self setLevel:level target:message];
}

+ (void) setDate:(NSString *)date target:(DConnectMessage *)message {
    [message setString:date forKey:DConnectSettingsProfileParamDate];
}

+ (void) setTime:(int)time target:(DConnectMessage *)message {
    [message setInteger:time forKey:DConnectSettingsProfileParamTime];
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
