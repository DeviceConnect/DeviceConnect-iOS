//
//  DCMLightProfileAlt.m
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DCMLightProfileAlt.h"

#import <DConnectSDK/DConnectUtil.h>
#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>


@interface DCMLightProfileAlt()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DCMLightProfileAlt

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
                [DCMLightProfileAlt parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfileAlt parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing]];
            
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
                [DCMLightProfileAlt parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfileAlt parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing]];
            
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
            NSArray *pattern = [DCMLightProfileAlt parsePattern:lightIds];
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
                [DCMLightProfileAlt parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *name = [request stringForKey:DCMLightProfileParamName];
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfileAlt parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing]];
            
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
                [DCMLightProfileAlt parseBrightParam:
                 [request objectForKey:DCMLightProfileParamBrightness]];
                if (!brightness) {
                    [response setErrorToInvalidRequestParameterWithMessage:
                     @"Parameter 'brightness' must be a value between 0 and 1.0."];
                    return YES;
                }
            }
            NSString *name = [request stringForKey:DCMLightProfileParamName];
            NSString *color = [request stringForKey:DCMLightProfileParamColor];
            NSArray *flashing =
            [DCMLightProfileAlt parsePattern:
             [request stringForKey:DCMLightProfileParamFlashing]];
            
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
+ (NSArray *) parsePattern:(NSString *)pattern {
    
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
        [result addObject:pattern];
    }
    
    return result;
}
@end
