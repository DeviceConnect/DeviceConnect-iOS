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

@interface DConnectLightProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectLightProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DConnectLightProfileName;
}

#pragma mark - DConnectProfile Method

/*
 GETリクエストを振り分ける。
 */
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *attribute = [request attribute];
    if (profile) {
        if ([self isEqualToProfile:profile cmp:DConnectLightProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:didReceiveGetLightRequest:response:serviceId:) response:response])
        {

            send = [_delegate profile:self
            didReceiveGetLightRequest:request
                             response:response
                            serviceId:serviceId];
        } else if ([self isEqualToProfile:profile cmp:DConnectLightProfileName]
                   && attribute
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileInterfaceGroup]
                   && [self hasMethod:@selector(profile:
                                                didReceiveGetLightGroupRequest:
                                                response:
                                                serviceId:)
                             response:response])
        {
            send = [_delegate profile:self
       didReceiveGetLightGroupRequest:request
                             response:response
                            serviceId:serviceId];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}


/*
 POSTリクエストを振り分ける。
 */
- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request
                      response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([self isEqualToProfile:profile cmp:DConnectLightProfileName]
            && !interface
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceivePostLightRequest:
                                         response:
                                         serviceId:
                                         lightId:
                                         brightness:
                                         color:
                                         flashing:)
                      response:response])
        {
            NSString *lightId = [request stringForKey:DConnectLightProfileParamLightId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DConnectLightProfileParamBrightness]) {
                brightness =
                [DConnectLightProfile parseBrightParam:
                 [request objectForKey:DConnectLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DConnectLightProfileParamColor];
            NSArray *flashing =
            [DConnectLightProfile parsePattern:
             [request stringForKey:DConnectLightProfileParamFlashing] isId:NO];
            if (!flashing) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'flashing' invalid."];
                return YES;
            }
            if (![self checkFlash:response flashing:flashing]) {
                return YES;
            }
            send = [_delegate profile:self
           didReceivePostLightRequest:request
                             response:response
                            serviceId:serviceId
                              lightId:lightId
                           brightness:brightness
                                color:color
                             flashing:flashing];
        } else if ([self isEqualToProfile:profile cmp:DConnectLightProfileName]
                   && !interface
                   && attribute
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileInterfaceGroup]
                   && [self hasMethod:@selector(profile:
                                                didReceivePostLightGroupRequest:
                                                response:
                                                serviceId:
                                                groupId:
                                                brightness:
                                                color:
                                                flashing:)
                             response:response])
        {
            NSString *groupId = [request stringForKey:DConnectLightProfileParamGroupId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DConnectLightProfileParamBrightness]) {
                brightness =
                [DConnectLightProfile parseBrightParam:
                 [request objectForKey:DConnectLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DConnectLightProfileParamColor];
            NSArray *flashing =
            [DConnectLightProfile parsePattern:
             [request stringForKey:DConnectLightProfileParamFlashing] isId:NO];
            if (!flashing) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'flashing' invalid."];
                return YES;
            }
            if (![self checkFlash:response flashing:flashing]) {
                return YES;
            }

            send = [_delegate profile:self
      didReceivePostLightGroupRequest:request
                             response:response
                            serviceId:serviceId
                              groupId:groupId
                           brightness:brightness
                                color:color
                             flashing:flashing];
        } else if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
                   && interface
                   && attribute
                   && [self isEqualToInterface: interface cmp:DConnectLightProfileInterfaceGroup]
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileAttrCreate]
                   && [self hasMethod:@selector(profile:
                                                didReceivePostLightGroupCreateRequest:
                                                response:
                                                serviceId:
                                                lightIds:
                                                groupName:)
                             response:response])
        {
            NSString *lightIds = [request stringForKey:DConnectLightProfileParamLightIds];
            NSString *groupName = [request stringForKey:DConnectLightProfileParamGroupName];
            NSArray *pattern = [DConnectLightProfile parsePattern:lightIds isId:YES];
            send = [_delegate profile:self
didReceivePostLightGroupCreateRequest:request
                             response:response
                            serviceId:serviceId
                             lightIds:pattern
                            groupName:groupName];
        } else {
            [response setErrorToNotSupportAttribute];
        }
        
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 PUTリクエストを振り分ける。
 */
- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request
                     response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
            && !interface
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceivePutLightRequest:
                                         response:
                                         serviceId:
                                         lightId:
                                         name:
                                         brightness:
                                         color:
                                         flashing:)
                      response:response])
        {
            NSString *lightId = [request stringForKey:DConnectLightProfileParamLightId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DConnectLightProfileParamBrightness]) {
                brightness =
                [DConnectLightProfile parseBrightParam:
                 [request objectForKey:DConnectLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *name = [request stringForKey:DConnectLightProfileParamName];
            NSString *color = [request stringForKey:DConnectLightProfileParamColor];
            NSArray *flashing =
            [DConnectLightProfile parsePattern:
             [request stringForKey:DConnectLightProfileParamFlashing] isId:NO];
            if (!flashing) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'flashing' invalid."];
                return YES;
            }
            if (![self checkFlash:response flashing:flashing]) {
                return YES;
            }

            
            send = [_delegate profile:self
            didReceivePutLightRequest:request
                             response:response
                            serviceId:serviceId
                              lightId:lightId
                                 name:name
                           brightness:brightness
                                color:color
                             flashing:flashing];
        } else if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
                   && !interface
                   && attribute
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileInterfaceGroup]
                   && [self hasMethod:@selector(profile:
                                                didReceivePutLightGroupRequest:
                                                response:
                                                serviceId:
                                                groupId:
                                                name:
                                                brightness:
                                                color:
                                                flashing:)
                             response:response])
        {
            NSString *groupId = [request stringForKey:DConnectLightProfileParamGroupId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DConnectLightProfileParamBrightness]) {
                brightness =
                [DConnectLightProfile parseBrightParam:
                 [request objectForKey:DConnectLightProfileParamBrightness]];
                if (!brightness
                    || (brightness &&  ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
                
            }
            NSString *name = [request stringForKey:DConnectLightProfileParamName];
            NSString *color = [request stringForKey:DConnectLightProfileParamColor];
            NSArray *flashing =
            [DConnectLightProfile parsePattern:
             [request stringForKey:DConnectLightProfileParamFlashing]
                                     isId:NO];
            if (!flashing) {
                [response setErrorToInvalidRequestParameterWithMessage:
                 @"Parameter 'flashing' invalid."];
                return YES;
            }
            if (![self checkFlash:response flashing:flashing]) {
                return YES;
            }

            send = [_delegate profile:self
       didReceivePutLightGroupRequest:request
                             response:response
                            serviceId:serviceId
                              groupId:groupId
                                 name:name
                           brightness:brightness
                                color:color
                             flashing:flashing];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

/*
 DELETEリクエストを振り分ける。
 */
- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *serviceId = [request serviceId];
    NSString *profile = [request profile];
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (profile) {
        if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
            && !interface
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceiveDeleteLightRequest:
                                         response:
                                         serviceId:
                                         lightId:)
                      response:response])
        {
            NSString *lightId = [request stringForKey:DConnectLightProfileParamLightId];
            send = [_delegate profile:self
         didReceiveDeleteLightRequest:request
                             response:response
                            serviceId:serviceId
                              lightId:lightId];
        } else if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
                   && !interface
                   && attribute
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileInterfaceGroup]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteLightGroupRequest:
                                                response:
                                                serviceId:
                                                groupId:)
                             response:response])
        {
            NSString *groupId = [request stringForKey:DConnectLightProfileParamGroupId];
            send = [_delegate profile:self
    didReceiveDeleteLightGroupRequest:request
                             response:response
                            serviceId:serviceId
                              groupId:groupId];
        } else if ([self isEqualToProfile: profile cmp:DConnectLightProfileName]
                   && interface
                   && attribute
                   && [self isEqualToInterface: interface cmp:DConnectLightProfileInterfaceGroup]
                   && [self isEqualToAttribute: attribute cmp:DConnectLightProfileAttrClear]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteLightGroupClearRequest:
                                                response:
                                                serviceId:
                                                groupId:) response:response])
        {
            NSString *groupId = [request stringForKey:DConnectLightProfileParamGroupId];
            send = [_delegate          profile:self
        didReceiveDeleteLightGroupClearRequest:request
                                      response:response
                                     serviceId:serviceId
                                       groupId:groupId];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
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


/*
 メソッドが存在するかを確認する。
 */
- (BOOL) hasMethod:(SEL)method
          response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

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
            [result addObject:valueStr];
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
    for (NSString *flash in flashing) {
        if (flash && [flash doubleValue] <= 0.0) {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"Parameter 'flashing' must be a x >= 1."];
            return NO;
        } else if (flash && ![DConnectLightProfile existDigitWithString:flash]
                             && [DConnectLightProfile existDecimalWithString:flash]) {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"Parameter 'flashing' must not be decimal."];
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
