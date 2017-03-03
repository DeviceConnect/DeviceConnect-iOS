//
//  DPLinkingDeviceKeyEventProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceKeyEventProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingDevicePlugin.h"
#import "DPLinkingDeviceButtonOnce.h"

@interface DPLinkingDeviceKeyEventProfile () <DPLinkingDeviceButtonIdDelegate>
@end

@implementation DPLinkingDeviceKeyEventProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        // onKeyDown
        
        NSString *keyDownPath = [self apiPath:nil
                                attributeName:DConnectKeyEventProfileAttrOnDown];

        [self addGetPath: keyDownPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetKeyDown:request response:response];
                     }];
        
        [self addPutPath: keyDownPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onPutKeyDown:request response:response];
                     }];
        
        [self addDeletePath: keyDownPath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteKeyDown:request response:response];
                        }];
        
        // onKeyChange
        
        NSString *keyChangePath = [self apiPath:nil
                                  attributeName:DConnectKeyEventProfileAttrOnKeyChange];

        [self addGetPath: keyChangePath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetKeyChange:request response:response];
                     }];
        
        [self addPutPath: keyChangePath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onPutKeyChange:request response:response];
                     }];
        
        [self addDeletePath: keyChangePath
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteKeyChange:request response:response];
                        }];
    }
    return self;
}

#pragma mark - Private Method

// GET /keyEevent/onKeyChange

- (BOOL) onGetKeyChange:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportButtonId]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceButtonOnce *button = [[DPLinkingDeviceButtonOnce alloc] initWithDevice:device];
    button.type = DPLinkingKeyEventTypeChange;
    button.request = request;
    button.response = response;
    return NO;
}

// PUT /keyEevent/onKeyChange

- (BOOL) onPutKeyChange:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        [deviceMgr enableListenButtonId:device delegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

// DELETE /keyEevent/onKeyChange

- (BOOL) onDeleteKeyChange:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        if ([self isEmptyEventList:serviceId]) {
            [deviceMgr disableListenButtonId:device delegate:self];
        }
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

// GET /keyEevent/onKeyDown

- (BOOL) onGetKeyDown:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportButtonId]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceButtonOnce *button = [[DPLinkingDeviceButtonOnce alloc] initWithDevice:device];
    button.request = request;
    button.response = response;
    return NO;
}

// PUT /keyEevent/onKeyDown

- (BOOL) onPutKeyDown:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        [deviceMgr enableListenButtonId:device delegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

// DELETE /keyEevent/onKeyDown

- (BOOL) onDeleteKeyDown:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceMgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        if ([self isEmptyEventList:serviceId]) {
            [deviceMgr disableListenButtonId:device delegate:self];
        }
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) isEmptyEventList:(NSString *)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *onKeyDownEvents = [mgr eventListForServiceId:serviceId
                                                  profile:DConnectKeyEventProfileName
                                                attribute:DConnectKeyEventProfileAttrOnDown];
    NSArray *onKeyChangeEvents = [mgr eventListForServiceId:serviceId
                                                    profile:DConnectKeyEventProfileName
                                                  attribute:DConnectKeyEventProfileAttrOnKeyChange];
    return onKeyDownEvents.count == 0 && onKeyChangeEvents.count == 0;
}


#pragma mark - DPLinkingDeviceButtonIdDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device buttonId:(int)buttonId
{
    if ([self isEmptyEventList:device.identifier]) {
        DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
        [deviceMgr disableListenButtonId:device delegate:self];
    } else {
        DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
        NSArray *onKeyDownEvents  = [mgr eventListForServiceId:device.identifier
                                                       profile:DConnectKeyEventProfileName
                                                     attribute:DConnectKeyEventProfileAttrOnDown];

        DConnectMessage *keyEvent = [DConnectMessage new];
        [DConnectKeyEventProfile setId:buttonId target:keyEvent];
        
        for (DConnectEvent *event in onKeyDownEvents) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectKeyEventProfile setKeyEvent:keyEvent target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
        
        NSArray *onKeyChangeEvents = [mgr eventListForServiceId:device.identifier
                                                        profile:DConnectKeyEventProfileName
                                                      attribute:DConnectKeyEventProfileAttrOnKeyChange];
        
        for (DConnectEvent *event in onKeyChangeEvents) {
            [keyEvent setString:DConnectKeyEventProfileKeyStateDown forKey:DConnectKeyEventProfileParamState];

            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectKeyEventProfile setKeyEvent:keyEvent target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
    }
}

@end
