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

+ (void) setLevel:(double)level target:(DConnectMessage *)message;

@end

@implementation DConnectSettingsProfile

- (NSString *) profileName {
    return DConnectSettingsProfileName;
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

@end
