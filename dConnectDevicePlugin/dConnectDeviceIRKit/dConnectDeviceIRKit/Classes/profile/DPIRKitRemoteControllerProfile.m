//
//  DPIRKitRemoteControllerProfile.m
//  dConnectDeviceIRKit
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPIRKitRemoteControllerProfile.h"
#import "DPIRKit.h"
#import "DPIRKitDevicePlugin.h"
#import "DPIRKit_irkit.h"

NSString *const DPIRKitRemoteControllerProfileName = @"remoteController";
NSString *const DPIRKitRemoteControllerProfileParamMessage = @"message";

@interface DPIRKitRemoteControllerProfile()
{
    DPIRKitManager *_irkit;
}
@property (nonatomic, weak) DPIRKitDevicePlugin *plugin;

- (void) setMessage:(NSString *)message target:(DConnectMessage *)target;
- (NSString *) messageFromRequest:(DConnectRequestMessage *)request;

@end

@implementation DPIRKitRemoteControllerProfile

#pragma mark - Initialization

- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin {
    
    self = [super init];
    
    if (self) {
        self.plugin = plugin;
        _irkit = [DPIRKitManager sharedInstance];
    }
    
    return self;
}

#pragma mark - Setter

- (void) setMessage:(NSString *)message target:(DConnectMessage *)target {
    [target setString:message forKey:DPIRKitRemoteControllerProfileParamMessage];
}

#pragma mark - Getter

- (NSString *) messageFromRequest:(DConnectRequestMessage *)request {
    return [request stringForKey:DPIRKitRemoteControllerProfileParamMessage];
}

#pragma mark - DConnectProfile Override

- (NSString *) profileName {
    return DPIRKitRemoteControllerProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    if ([request.attribute length] != 0) {
        [response setErrorToNotSupportProfile];
    } else if (_plugin) {
        
        __weak typeof(self) _self = self;
        DPIRKitDevice *device = [_plugin deviceForServiceId:request.serviceId];
        if (device) {
            send = NO;
            [_irkit fetchMessageWithHostName:device.hostName completion:^(NSString *message) {
                
                if (message) {
                    [_self setMessage:message target:response];
                    response.result = DConnectMessageResultTypeOk;
                } else {
                    [response setErrorToUnknown];
                }
                [[DConnectManager sharedManager] sendResponse:response];
            }];
        } else {
            [response setErrorToNotFoundService];
        }
        
    } else {
        [response setErrorToUnknown];
    }
    
    return send;
}

- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    if ([request.attribute length] != 0) {
        [response setErrorToNotSupportProfile];
    } else if (_plugin) {
        
        DPIRKitDevice *device = [_plugin deviceForServiceId:request.serviceId];
        if (device) {
            
            NSString *message = [self messageFromRequest:request];
            if (message) {
                NSData *jsonData = [message dataUsingEncoding:NSUnicodeStringEncoding];
                id jsonObj = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:NULL];
                if (![NSJSONSerialization isValidJSONObject:jsonObj]) {
                    [response setErrorToInvalidRequestParameter];
                    return YES;
                }
            }
            
            if (!message) {
                [response setErrorToInvalidRequestParameter];
            } else {
                send = NO;
                [_irkit sendMessage:message withHostName:device.hostName completion:^(BOOL success) {
                    if (success) {
                        response.result = DConnectMessageResultTypeOk;
                    } else {
                        [response setErrorToUnknown];
                    }
                    
                    [[DConnectManager sharedManager] sendResponse:response];
                }];
            }
        } else {
            [response setErrorToNotFoundService];
        }
        
    } else {
        [response setErrorToUnknown];
    }
    
    return send;
}

@end
