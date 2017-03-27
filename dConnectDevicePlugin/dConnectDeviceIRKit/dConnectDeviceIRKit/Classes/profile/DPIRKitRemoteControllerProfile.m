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

@property(nonatomic, strong) DPIRKitManager *irkit;

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
        
        __weak DPIRKitRemoteControllerProfile *weakSelf = self;
        
        // API登録(didReceiveGetRequest相当)
        NSString *getRequestApiPath = [self apiPath: nil
                                      attributeName: nil];
        [self addGetPath: getRequestApiPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         BOOL send = YES;
                         DPIRKitDevice *device = [weakSelf.plugin deviceForServiceId:request.serviceId];
                         if (device) {
                             send = NO;
                             [weakSelf.irkit fetchMessageWithHostName:device.hostName completion:^(NSString *message) {
                                 
                                 if (message) {
                                     [weakSelf setMessage:message target:response];
                                     response.result = DConnectMessageResultTypeOk;
                                 } else {
                                     [response setErrorToUnknown];
                                 }
                                 [[DConnectManager sharedManager] sendResponse:response];
                             }];
                         } else {
                             [response setErrorToNotFoundService];
                         }
                         
                         return send;
                     }];
        
        // API登録(didReceivePostRequest相当)
        NSString *postRequestApiPath = [self apiPath: nil
                                       attributeName: nil];
        [self addPostPath: postRequestApiPath
                      api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                          BOOL send = YES;
                          DPIRKitDevice *device = [weakSelf.plugin deviceForServiceId:request.serviceId];
                          if (device) {
                              
                              NSString *message = [weakSelf messageFromRequest:request];
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
                                  [weakSelf.irkit sendMessage:message withHostName:device.hostName completion:^(BOOL success) {
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
                         
                          return send;
                      }];
        
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

#pragma mark - DConnectProfile Delegate

- (NSString *) profileName {
    return DPIRKitRemoteControllerProfileName;
}

/*
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    if ([request.attribute length] != 0) {
        [response setErrorToNotSupportProfile];
    } else if (self.plugin) {
        
        __weak typeof(self) _self = self;
        DPIRKitDevice *device = [self.plugin deviceForServiceId:request.serviceId];
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
*/
/*
- (BOOL) didReceivePostRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    
    BOOL send = YES;
    if ([request.attribute length] != 0) {
        [response setErrorToNotSupportProfile];
    } else if (self.plugin) {
        
        DPIRKitDevice *device = [self.plugin deviceForServiceId:request.serviceId];
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
*/

@end
