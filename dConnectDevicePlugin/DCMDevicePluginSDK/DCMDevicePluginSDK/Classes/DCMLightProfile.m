//
//  DCMLightProfileName.m
//  DCMDevicePluginSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMLightProfile.h"
#import <DConnectSDK/DConnectUtil.h>

static NSString * const DCMRegexDecimalPoint = @"^[-+]?([0-9]*)?(\\.)?([0-9]*)?$";
static NSString * const DCMRegexDigit = @"^([0-9]*)?$";
NSString *const DCMLightProfileName = @"light";
NSString *const DCMLightProfileInterfaceGroup = @"group";
NSString *const DCMLightProfileAttrCreate = @"create";
NSString *const DCMLightProfileAttrClear = @"clear";
NSString *const DCMLightProfileParamLightId = @"lightId";
NSString *const DCMLightProfileParamName = @"name";
NSString *const DCMLightProfileParamColor = @"color";
NSString *const DCMLightProfileParamBrightness = @"brightness";
NSString *const DCMLightProfileParamFlashing = @"flashing";
NSString *const DCMLightProfileParamLights = @"lights";
NSString *const DCMLightProfileParamOn = @"on";
NSString *const DCMLightProfileParamConfig = @"config";
NSString *const DCMLightProfileParamGroupId = @"groupId";
NSString *const DCMLightProfileParamLightGroups = @"lightGroups";
NSString *const DCMLightProfileParamLightIds = @"lightIds";
NSString *const DCMLightProfileParamGroupName = @"groupName";

@interface DCMLightProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DCMLightProfile

/*
 プロファイル名。
 */
- (NSString *) profileName {
    return DCMLightProfileName;
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
        if ([profile isEqualToString:DCMLightProfileName]
            && !attribute
            && [self hasMethod:@selector(profile:didReceiveGetLightRequest:response:serviceId:) response:response])
        {

            send = [_delegate profile:self
            didReceiveGetLightRequest:request
                             response:response
                            serviceId:serviceId];
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && attribute
                   && [attribute isEqualToString:DCMLightProfileInterfaceGroup]
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
        if ([profile isEqualToString:DCMLightProfileName]
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
            NSString *lightId = [request stringForKey:DCMLightProfileParamLightId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DCMLightProfileParamBrightness]) {
                brightness =
                [DCMLightProfile parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfile parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing] isId:NO];
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
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && !interface
                   && attribute
                   && [attribute isEqualToString:DCMLightProfileInterfaceGroup]
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
            NSString *groupId = [request stringForKey:DCMLightProfileParamGroupId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DCMLightProfileParamBrightness]) {
                brightness =
                [DCMLightProfile parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfile parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing] isId:NO];
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
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && interface
                   && attribute
                   && [interface isEqualToString:DCMLightProfileInterfaceGroup]
                   && [attribute isEqualToString:DCMLightProfileAttrCreate]
                   && [self hasMethod:@selector(profile:
                                                didReceivePostLightGroupCreateRequest:
                                                response:
                                                serviceId:
                                                lightIds:
                                                groupName:)
                             response:response])
        {
            NSString *lightIds = [request stringForKey:DCMLightProfileParamLightIds];
            NSString *groupName = [request stringForKey:DCMLightProfileParamGroupName];
            NSArray *pattern = [DCMLightProfile parsePattern:lightIds isId:YES];
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
        if ([profile isEqualToString:DCMLightProfileName]
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
            NSString *lightId = [request stringForKey:DCMLightProfileParamLightId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DCMLightProfileParamBrightness]) {
                brightness =
                [DCMLightProfile parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness
                    || (brightness && ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *name = [request stringForKey:DCMLightProfileParamName];
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfile parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing] isId:NO];
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
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && !interface
                   && attribute
                   && [attribute isEqualToString:DCMLightProfileInterfaceGroup]
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
            NSString *groupId = [request stringForKey:DCMLightProfileParamGroupId];
            NSNumber *brightness = nil;
            if ([request objectForKey:DCMLightProfileParamBrightness]) {
                brightness =
                [DCMLightProfile parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness
                    || (brightness &&  ([brightness doubleValue] < 0.0 || [brightness doubleValue] > 1.0))) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
                
            }
            NSString *name = [request stringForKey:DCMLightProfileParamName];
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfile parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing]
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
        if ([profile isEqualToString:DCMLightProfileName]
            && !interface
            && !attribute
            && [self hasMethod:@selector(profile:
                                         didReceiveDeleteLightRequest:
                                         response:
                                         serviceId:
                                         lightId:)
                      response:response])
        {
            NSString *lightId = [request stringForKey:DCMLightProfileParamLightId];
            send = [_delegate profile:self
         didReceiveDeleteLightRequest:request
                             response:response
                            serviceId:serviceId
                              lightId:lightId];
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && !interface
                   && attribute
                   && [attribute isEqualToString:DCMLightProfileInterfaceGroup]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteLightGroupRequest:
                                                response:
                                                serviceId:
                                                groupId:)
                             response:response])
        {
            NSString *groupId = [request stringForKey:DCMLightProfileParamGroupId];
            send = [_delegate profile:self
    didReceiveDeleteLightGroupRequest:request
                             response:response
                            serviceId:serviceId
                              groupId:groupId];
        } else if ([profile isEqualToString:DCMLightProfileName]
                   && interface
                   && attribute
                   && [interface isEqualToString:DCMLightProfileInterfaceGroup]
                   && [attribute isEqualToString:DCMLightProfileAttrClear]
                   && [self hasMethod:@selector(profile:
                                                didReceiveDeleteLightGroupClearRequest:
                                                response:
                                                serviceId:
                                                groupId:) response:response])
        {
            NSString *groupId = [request stringForKey:DCMLightProfileParamGroupId];
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
        if (!isId && ![DCMLightProfile existDigitWithString:pattern]) {
            return nil;
        }
        [result addObject:pattern];
    }
    
    return result;
}

- (BOOL)checkFlash:(DConnectResponseMessage *)response flashing:(NSArray *)flashing
{
    for (NSString *flash in flashing) {
        if (flash && [flash doubleValue] < 0.0) {
            [response setErrorToInvalidRequestParameterWithMessage:
             @"Parameter 'flashing' must be a x >= 0.0."];
            return NO;
        } else if (flash && [DCMLightProfile existDecimalWithString:flash]) {
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
