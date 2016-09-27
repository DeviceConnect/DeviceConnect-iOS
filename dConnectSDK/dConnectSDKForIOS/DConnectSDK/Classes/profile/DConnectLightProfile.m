//
//  DConnectLightProfileName.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectLightProfile.h"
#import <DConnectSDK/DConnectUtil.h>

static NSString * const DCMRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const DCMRegexDigit = @"^([0-9]*)?$";

NSString *const DConnectLightProfileName = @"light";
NSString *const DConnectLightProfileInterfaceGroup = @"group";
NSString *const DConnectLightProfileAttrCreate = @"create";
NSString *const DConnectLightProfileAttrClear = @"clear";
NSString *const DConnectLightProfileParamLightId = @"lightId";
NSString *const DConnectLightProfileParamName = @"name";
NSString *const DConnectLightProfileParamColor = @"color";
NSString *const DConnectLightProfileParamBrightness = @"brightness";
NSString *const DConnectLightProfileParamFlashing = @"flashing";
NSString *const DConnectLightProfileParamLights = @"lights";
NSString *const DConnectLightProfileParamOn = @"on";
NSString *const DConnectLightProfileParamConfig = @"config";
NSString *const DConnectLightProfileParamGroupId = @"groupId";
NSString *const DConnectLightProfileParamLightGroups = @"lightGroups";
NSString *const DConnectLightProfileParamLightIds = @"lightIds";
NSString *const DConnectLightProfileParamGroupName = @"groupName";

@implementation DConnectLightProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DConnectLightProfileName;
}

#pragma mark - Getter

+ (NSString *) lightIdFromRequest: (DConnectRequestMessage *) request {
    NSString *lightId = [request stringForKey:DConnectLightProfileParamLightId];
    return lightId;
}

+ (NSString *) lightIdsFromRequest: (DConnectRequestMessage *) request {
    NSString *lightIds = [request stringForKey:DConnectLightProfileParamLightIds];
    return lightIds;
}

+ (NSNumber *) brightnessFromRequest: (DConnectRequestMessage *) request {
    NSNumber *brightness = nil;
    if ([request objectForKey:DConnectLightProfileParamBrightness]) {
        brightness =
        [DConnectLightProfile parseBrightParam:
         [request objectForKey:DConnectLightProfileParamBrightness]];
    }
    return brightness;
}

+ (NSString *) nameFromRequest: (DConnectRequestMessage *) request {
    NSString *name = [request stringForKey:DConnectLightProfileParamName];
    return name;
}

+ (NSString *) colorFromRequest: (DConnectRequestMessage *) request {
    NSString *color = [request stringForKey:DConnectLightProfileParamColor];
    return color;
}

+ (NSString *) flashingFromRequest: (DConnectRequestMessage *) request {
    NSString *flashing = [request stringForKey:DConnectLightProfileParamFlashing];
    return flashing;
}

+ (NSString *) groupIdFromRequest: (DConnectRequestMessage *) request {
    NSString *groupId = [request stringForKey:DConnectLightProfileParamGroupId];
    return groupId;
}

+ (NSString *) groupNameFromRequest: (DConnectRequestMessage *) request {
    NSString *groupName = [request stringForKey:DConnectLightProfileParamGroupName];
    return groupName;
}

#pragma mark - Setter
+ (void) setLights:(DConnectArray *)lights target:(DConnectMessage *)message {
    [message setArray:lights forKey:DConnectLightProfileParamLights];
}

+ (void) setLightId:(NSString*)lightId target:(DConnectMessage *)message {
    [message setString:lightId forKey:DConnectLightProfileParamLightId];
}

+ (void) setLightName:(NSString*)lightName target:(DConnectMessage *)message {
    [message setString:lightName forKey:DConnectLightProfileParamName];
}

+ (void) setLightOn:(BOOL)isOn target:(DConnectMessage *)message {
    [message setBool:isOn forKey:DConnectLightProfileParamOn];
}

+ (void) setLightConfig:(NSString*)config target:(DConnectMessage *)message {
    [message setString:config forKey:DConnectLightProfileParamConfig];
}


+ (void) setLightGroups:(DConnectArray *)lightGroups target:(DConnectMessage *)message {
    [message setArray:lightGroups forKey:DConnectLightProfileParamLightGroups];
}

+ (void) setLightGroupId:(NSString*)lightGroupId target:(DConnectMessage *)message {
    [message setString:lightGroupId forKey:DConnectLightProfileParamGroupId];
}

+ (void) setLightGroupName:(NSString*)lightGroupName target:(DConnectMessage *)message {
    [message setString:lightGroupName forKey:DConnectLightProfileParamName];
}


#pragma mark - Private Methods


+ (NSNumber *) parseBrightParam:(NSString *)brightnessParam
{
    if (![brightnessParam isKindOfClass:NSString.class]) {
        return nil;
    }
    NSScanner *scanner = [NSScanner scannerWithString:brightnessParam];
    double tmpDouble;
    if (![scanner scanDouble:&tmpDouble]) {
        return nil;
    }
    return @(tmpDouble);
}

/*
 flashingをパースする。
 */
+ (NSArray *) parsePattern:(NSString *)pattern
                      isId:(BOOL)isId
{
    
    NSMutableArray *result = [NSMutableArray array];
    if (!pattern) {
        return result;  //中身がない場合は長さが0の配列を返す
    }
    
    NSRange range = [pattern rangeOfString:DConnectVibrationProfileVibrationDurationDelim];
    if (range.location != NSNotFound) {
        NSArray *times = [pattern componentsSeparatedByString:DConnectVibrationProfileVibrationDurationDelim];
        for (NSString *time in times) {
            NSString *valueStr = [time stringByTrimmingCharactersInSet:
                                  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (valueStr.length == 0) {
                if (result.count != times.count - 1) {
                    // 数値の間にスペースがある場合はフォーマットエラー
                    // ex. 100, , 100
                    [result removeAllObjects];
                }
                break;
            }
            [result addObject:@([valueStr intValue])];
        }
        
        if (result.count == 0) {
            [result removeAllObjects];
        }
    } else {
        if (!isId && ![DConnectLightProfile existDigitWithString:pattern]) {
            return nil;
        }
        [result addObject:pattern];
    }
    
    return result;
}

- (BOOL)checkFlash:(DConnectResponseMessage *)response flashing:(NSArray *)flashing
{
    for (NSNumber *flash in flashing) {
        if (flash && [flash doubleValue] <= 0.0) {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"Parameter 'flashing' must be a x >= 1."];
            return NO;
        }
    }
    return YES;
}


+ (BOOL)existNumberWithString:(NSString *)numberString Regex:(NSString*)regex {
    NSRange match = [numberString rangeOfString:regex options:NSRegularExpressionSearch];
    //数値の場合
    return match.location != NSNotFound;
}
// 整数かどうかを判定する。 true:存在する
+ (BOOL)existDigitWithString:(NSString*)digit {
    return [self existNumberWithString:digit Regex:DCMRegexDigit];
}

// 少数かどうかを判定する。
+ (BOOL)existDecimalWithString:(NSString*)decimal {
    return [self existNumberWithString:decimal Regex:DCMRegexDecimalPoint];
}

@end
