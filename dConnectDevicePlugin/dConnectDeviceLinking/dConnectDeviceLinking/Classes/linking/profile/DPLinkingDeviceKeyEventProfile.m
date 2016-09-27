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

@interface DPLinkingDeviceKeyEventProfile () <DPLinkingDeviceButtonIdDelegate>
@end

@implementation DPLinkingDeviceKeyEventProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        NSString *path = [self apiPath:nil
                         attributeName:DConnectKeyEventProfileAttrOnDown];

        [self addPutPath: path
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onPutKeyDown:request response:response];
                     }];
        
        [self addDeletePath: path
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteKeyDown:request response:response];
                        }];

    }
    return self;
}

#pragma mark - Private Method

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
    NSArray *events = [mgr eventListForServiceId:serviceId
                                         profile:DConnectKeyEventProfileName
                                       attribute:DConnectKeyEventProfileAttrOnDown];
    return events.count == 0;
}


#pragma mark - DPLinkingDeviceButtonIdDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device buttonId:(int)buttonId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:device.identifier
                                          profile:DConnectKeyEventProfileName
                                        attribute:DConnectKeyEventProfileAttrOnDown];
    if (events == 0) {
        DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
        [deviceMgr disableListenButtonId:device delegate:self];
    } else {
        DConnectMessage *keyEvent = [DConnectMessage new];
        [DConnectKeyEventProfile setId:buttonId target:keyEvent];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectKeyEventProfile setKeyEvent:keyEvent target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
    }
}

@end
