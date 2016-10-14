//
//  DPLinkingBeaconKeyEventProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconKeyEventProfile.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingDevicePlugin.h"
#import "DPLinkingBeaconService.h"
#import "DPLinkingBeaconKeyEventOnce.h"
#import "DPLinkingBeaconUtil.h"

@interface DPLinkingBeaconKeyEventProfile () <DPLinkingBeaconButtonIdDelegate>

@end

@implementation DPLinkingBeaconKeyEventProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        NSString *keyDownPath = [self apiPath: nil
                                attributeName: DConnectKeyEventProfileAttrOnDown];
        [self addGetPath: keyDownPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onGetKeyDown:request response:response];
                     }];
        [self addPutPath: keyDownPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onPutKeyDown:request response:response];
                     }];

        [self addDeletePath: keyDownPath
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onDeleteKeyDown:request response:response];
                     }];
    }
    return self;
}

- (BOOL) onGetKeyDown:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DPLinkingBeaconKeyEventOnce *keyEvent = [[DPLinkingBeaconKeyEventOnce alloc] initWithBeacon:beacon];
    keyEvent.request = request;
    keyEvent.response = response;
    
    return NO;
}

- (BOOL) onPutKeyDown:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr addEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        [response setResult:DConnectMessageResultTypeOk];
        [beaconManager addButtonIdDelegate:self];
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
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    DConnectEventError error = [mgr removeEventForRequest:request];
    if (error == DConnectEventErrorNone) {
        if ([self isEmptyEventList:serviceId]) {
            [beaconManager removeButtonIdDelegate:self];
        }
        if ([DPLinkingBeaconUtil isEmptyEvent]) {
            [beaconManager stopBeaconScan];
        }
        [response setResult:DConnectMessageResultTypeOk];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (DPLinkingBeaconService *) getLinkingBeaconService
{
    return (DPLinkingBeaconService *)self.provider;
}

- (BOOL) isEmptyEventList:(NSString *)serviceId
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events = [mgr eventListForServiceId:serviceId
                                         profile:DConnectBatteryProfileName
                                       attribute:DConnectBatteryProfileAttrOnBatteryChange];
    return events.count == 0;
}

#pragma mark - DPLinkingBeaconButtonIdDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon ButtonId:(int)buttonId
{
    if (![beacon.beaconId isEqualToString:[self getLinkingBeaconService].beacon.beaconId]) {
        return;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:beacon.beaconId
                                          profile:DConnectKeyEventProfileName
                                        attribute:DConnectKeyEventProfileAttrOnDown];
    if (events == 0) {
        DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
        [beaconManager removeButtonIdDelegate:self];
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
