//
//  DPLinkingBeaconProximityProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconProximityProfile.h"
#import "DPLinkingBeaconProximityOnce.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingDevicePlugin.h"

@interface DPLinkingBeaconProximityProfile () <DPLinkingBeaconGattDataDelegate>

@end

@implementation DPLinkingBeaconProximityProfile

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
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DPLinkingBeaconProximityOnce *proximity = [[DPLinkingBeaconProximityOnce alloc] initWithBeacon:beacon];
    proximity.request = request;
    proximity.response = response;
    
    return NO;
}

- (BOOL) onPutDeviceProximity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
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
        [beaconManager addGattDataDelegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) onDeleteDeviceProximity:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
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
        [response setResult:DConnectMessageResultTypeOk];
        [beaconManager removeGattDataDelegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

#pragma mark - DPLinkingBeaconGattDataDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon gattData:(DPLinkingGattData *)gatt
{
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:beacon.beaconId
                                          profile:DConnectProximityProfileName
                                        attribute:DConnectProximityProfileAttrOnDeviceProximity];
    if (events == 0) {
        DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
        [beaconManager removeGattDataDelegate:self];
    } else {
        DConnectMessage *proximity = [DConnectMessage new];
        [DConnectProximityProfile setValue:gatt.distance target:proximity];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectProximityProfile setProximity:proximity target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
    }
}

@end
