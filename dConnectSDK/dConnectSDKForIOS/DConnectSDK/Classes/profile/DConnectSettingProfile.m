//
//  DConnectSettingProfile.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSettingProfile.h"

NSString *const DConnectSettingProfileName = @"setting";
NSString *const DConnectSettingProfileInterfaceSound = @"sound";
NSString *const DConnectSettingProfileInterfaceDisplay = @"display";
NSString *const DConnectSettingProfileAttrVolume = @"volume";
NSString *const DConnectSettingProfileAttrDate = @"date";
NSString *const DConnectSettingProfileAttrBrightness = @"brightness";
NSString *const DConnectSettingProfileAttrSleep = @"sleep";
NSString *const DConnectSettingProfileParamKind = @"kind";
NSString *const DConnectSettingProfileParamLevel = @"level";
NSString *const DConnectSettingProfileParamDate = @"date";
NSString *const DConnectSettingProfileParamTime = @"time";
const double DConnectSettingProfileMaxLevel = 1.0;
const double DConnectSettingProfileMinLevel = 0.0;

@interface DConnectSettingProfile()

+ (void) setLevel:(double)level target:(DConnectMessage *)message;

@end

@implementation DConnectSettingProfile

- (NSString *) profileName {
    return DConnectSettingProfileName;
}

#pragma mark - Getter

+ (DConnectSettingProfileVolumeKind) volumeKindFromRequest:(DConnectMessage *)request {
    int code = [request integerForKey:DConnectSettingProfileParamKind];
    switch (code) {
        case DConnectSettingProfileVolumeKindUnknown:
        case DConnectSettingProfileVolumeKindAlarm:
        case DConnectSettingProfileVolumeKindCall:
        case DConnectSettingProfileVolumeKindMail:
        case DConnectSettingProfileVolumeKindRingtone:
        case DConnectSettingProfileVolumeKindOther:
            return code;
        default:
            return DConnectSettingProfileVolumeKindUnknown;
    }
}

+ (NSString *) dateFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectSettingProfileParamDate];
}

+ (NSNumber *) levelFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectSettingProfileParamLevel];
}

+ (NSNumber *) timeFromRequest:(DConnectMessage *)request {
    return [request numberForKey:DConnectSettingProfileParamTime];
}


#pragma mark - Setter

+ (void) setLevel:(double)level target:(DConnectMessage *)message {
    if (level < DConnectSettingProfileMinLevel ||
        level > DConnectSettingProfileMaxLevel) {
        @throw [NSString stringWithFormat:@"level must be between %f and %f.",
                DConnectSettingProfileMinLevel,
                DConnectSettingProfileMaxLevel];
    }
    [message setDouble:level forKey:DConnectSettingProfileParamLevel];
}

+ (void) setVolumeLevel:(double)level target:(DConnectMessage *)message {
    [self setLevel:level target:message];
}

+ (void) setLightLevel:(double)level target:(DConnectMessage *)message {
    [self setLevel:level target:message];
}

+ (void) setDate:(NSString *)date target:(DConnectMessage *)message {
    [message setString:date forKey:DConnectSettingProfileParamDate];
}

+ (void) setTime:(int)time target:(DConnectMessage *)message {
    [message setInteger:time forKey:DConnectSettingProfileParamTime];
}

@end
