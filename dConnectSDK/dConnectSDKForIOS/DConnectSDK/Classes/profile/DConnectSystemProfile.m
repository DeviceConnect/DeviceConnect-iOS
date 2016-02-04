//
//  DConnectSystemProfile.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectSystemProfile.h"
#import "DConnectProfileProvider.h"
#import "DConnectManager+Private.h"

NSString *const DConnectSystemProfileName = @"system";

NSString *const DConnectSystemProfileInterfaceDevice = @"device";
NSString *const DConnectSystemProfileAttrWakeUp = @"wakeup";
NSString *const DConnectSystemProfileAttrKeyword = @"keyword";
NSString *const DConnectSystemProfileAttrEvents = @"events";

NSString *const DConnectSystemProfileParamSupports = @"supports";
NSString *const DConnectSystemProfileParamPlugins = @"plugins";
NSString *const DConnectSystemProfileParamPluginId = @"pluginId";
NSString *const DConnectSystemProfileParamId = @"id";
NSString *const DConnectSystemProfileParamName = @"name";
NSString *const DConnectSystemProfileParamVersion = @"version";

@interface DConnectSystemProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;
@end

@implementation DConnectSystemProfile

- (NSString *) profileName {
    return DConnectSystemProfileName;
}

- (BOOL) didReceivePutRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    
    if (interface && attribute && [attribute isEqualToString:DConnectSystemProfileAttrWakeUp] && _dataSource)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *viewController = [_dataSource profile:self settingPageForRequest:request];
            if (viewController) {
                UIViewController *rootView;
                DCPutPresentedViewController(rootView);
                
                [rootView presentViewController:viewController animated:YES completion:nil];
                [response setResult:DConnectMessageResultTypeOk];
            } else {
                [response setErrorToNotSupportAttribute];
            }
            
            [[DConnectManager sharedManager] sendResponse:response];
        });
        send = NO;
    } else if ([attribute isEqualToString:DConnectSystemProfileAttrKeyword]) {
        if (_delegate && [_delegate respondsToSelector:@selector(profile:didReceivePutKeywordRequest:response:)])
        {
            send = [_delegate profile:self didReceivePutKeywordRequest:request response:response];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

- (BOOL) didReceiveDeleteRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    
    if (!_delegate) {
        [response setErrorToNotSupportAction];
        return send;
    }
    
    NSString *attribute = [request attribute];
    if ([DConnectSystemProfileAttrEvents isEqualToString:attribute]) {
        if ([_delegate respondsToSelector:@selector(profile:
                                                    didReceiveDeleteEventsRequest:
                                                    response:
                                                    sessionKey:)]) {
            [_delegate                    profile:self
                    didReceiveDeleteEventsRequest:request
                                         response:response
                                       sessionKey:[request sessionKey]];
        } else {
            [response setErrorToNotSupportAttribute];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message {
    [message setArray:supports forKey:DConnectSystemProfileParamSupports];
}

+ (void) setPlugins:(DConnectArray *)plugins target:(DConnectMessage *)message {
    [message setArray:plugins forKey:DConnectSystemProfileParamPlugins];
}

+ (void) setId:(NSString *)pluginId target:(DConnectMessage *)message {
    [message setString:pluginId forKey:DConnectSystemProfileParamId];
}

+ (void) setName:(NSString *)name target:(DConnectMessage *)message {
    [message setString:name forKey:DConnectSystemProfileParamName];
}

#pragma mark - Getter Methods

+ (NSString *) pluginIdFromRequest:(DConnectMessage *)request {
    return [request stringForKey:DConnectSystemProfileParamPluginId];
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
