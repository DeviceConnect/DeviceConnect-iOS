//
//  DPLinkingDeviceProximityProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingDeviceProximityProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingDevicePlugin.h"
#import "DPLinkingDeviceProximityOnce.h"

@interface DPLinkingDeviceProximityProfile () <DPLinkingDeviceRangeDelegate>

@end

@implementation DPLinkingDeviceProximityProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;
        
        NSString *path = [self apiPath:nil
                         attributeName:DConnectProximityProfileAttrOnDeviceProximity];
        [self addGetPath: path
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetDeviceProximity:request response:response];
                     }];
        
        [self addPutPath: path
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onPutDeviceProximity:request response:response];
                     }];
        
        [self addDeletePath: path
                        api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                            return [_self onDeleteDeviceProximity:request response:response];
                        }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetDeviceProximity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *mgr = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [mgr findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    if (![device isSupportSensor]) {
        [response setErrorToNotSupportProfile];
        return YES;
    }
    
    DPLinkingDeviceProximityOnce *proximity = [[DPLinkingDeviceProximityOnce alloc] initWithDevice:device];
    proximity.request = request;
    proximity.response = response;
    
    return NO;
}

- (BOOL) onPutDeviceProximity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];

    DPLinkingDeviceManager *deviceManager = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceManager findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        [deviceManager enableListenRange:device delegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) onDeleteDeviceProximity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingDeviceManager *deviceManager = [DPLinkingDeviceManager sharedInstance];
    DPLinkingDevice *device = [deviceManager findDPLinkingDeviceByServiceId:serviceId];
    if (!device) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        if ([self isEmptyEventList:serviceId]) {
            [deviceManager disableListenRange:device delegate:self];
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
                                         profile:DConnectProximityProfileName
                                       attribute:DConnectProximityProfileAttrOnDeviceProximity];
    return events.count == 0;
}

- (NSString *) convertRange:(DPLinkingRange)range
{
    switch (range) {
        case DPLinkingRangeImmediate:
            return DConnectProximityProfileRangeImmediate;
        case DPLinkingRangeNear:
            return DConnectProximityProfileRangeNear;
        case DPLinkingRangeFar:
            return DConnectProximityProfileRangeFar;
        default:
            return DConnectProximityProfileRangeUnknown;
    }
}

#pragma mark - DPLinkingDeviceRangeDelegate

- (void) didReceivedDevice:(DPLinkingDevice *)device range:(DPLinkingRange)range
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:device.identifier
                                          profile:DConnectProximityProfileName
                                        attribute:DConnectProximityProfileAttrOnDeviceProximity];
    if (events == 0) {
        DPLinkingDeviceManager *deviceMgr = [DPLinkingDeviceManager sharedInstance];
        [deviceMgr disableListenRange:device delegate:self];
    } else {
        DConnectMessage *proximity = [DConnectMessage new];
        [DConnectProximityProfile setRange:[self convertRange:range] target:proximity];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectProximityProfile setProximity:proximity target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
    }
}

@end
