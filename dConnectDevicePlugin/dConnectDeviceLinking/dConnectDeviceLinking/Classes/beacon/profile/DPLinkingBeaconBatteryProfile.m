//
//  DPLinkingBeaconBatteryProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPLinkingBeaconBatteryProfile.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingBeaconBatteryOnce.h"
#import "DPLinkingDevicePlugin.h"
#import "DPLinkingBeaconService.h"
#import "DPLinkingBeaconUtil.h"

@interface DPLinkingBeaconBatteryProfile () <DPLinkingBeaconBatteryDelegate>
@end

@implementation DPLinkingBeaconBatteryProfile

- (instancetype) init
{
    self = [super init];
    if (self) {
        __weak typeof(self) weakSelf = self;
        
        [self addGetPath: @"/"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onGetBattery:request response:response];
                     }];
        
        [self addGetPath: @"/level"
                     api:^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onGetBattery:request response:response];
                     }];
        
        NSString *onBatteryChangePath = [self apiPath: nil
                                        attributeName: DConnectBatteryProfileAttrOnBatteryChange];
        [self addPutPath: onBatteryChangePath
                     api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onPutBatteryChange:request response:response];
                     }];

        [self addDeletePath: onBatteryChangePath
                     api: ^BOOL(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [weakSelf onDeleteBatteryChange:request response:response];
                     }];
    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetBattery:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    NSString *serviceId = [request serviceId];
    
    DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
    DPLinkingBeacon *beacon = [beaconManager findBeaconByBeaconId:serviceId];
    if (!beacon) {
        [response setErrorToNotFoundService];
        return YES;
    }
    
    DPLinkingBeaconBatteryOnce *battery = [[DPLinkingBeaconBatteryOnce alloc] initWithBeacon:beacon];
    battery.request = request;
    battery.response = response;
    
    return NO;
}

- (BOOL) onPutBatteryChange:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
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
        [beaconManager addBatteryDelegate:self];
    } else if (error == DConnectEventErrorInvalidParameter) {
        [response setErrorToInvalidRequestParameterWithMessage:@"origin must be specified."];
    } else {
        [response setErrorToUnknown];
    }
    return YES;
}

- (BOOL) onDeleteBatteryChange:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
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
            [beaconManager removeBatteryDelegate:self];
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

#pragma mark - DPLinkingBeaconBatteryDelegate

- (void) didReceivedBeacon:(DPLinkingBeacon *)beacon battery:(DPLinkingBattryData *)battery
{
    if (![beacon.beaconId isEqualToString:[self getLinkingBeaconService].beacon.beaconId]) {
        return;
    }
    
    DConnectEventManager *mgr = [DConnectEventManager sharedManagerForClass:[DPLinkingDevicePlugin class]];
    NSArray *events  = [mgr eventListForServiceId:beacon.beaconId
                                          profile:DConnectBatteryProfileName
                                        attribute:DConnectBatteryProfileAttrOnBatteryChange];
    if (events == 0) {
        DPLinkingBeaconManager *beaconManager = [DPLinkingBeaconManager sharedInstance];
        [beaconManager removeBatteryDelegate:self];
    } else {
        DConnectMessage *batteryMsg = [DConnectMessage new];
        [DConnectBatteryProfile setLevel:battery.batteryLevel / 100.0f target:batteryMsg];
        
        for (DConnectEvent *event in events) {
            DConnectMessage *eventMsg = [DConnectEventManager createEventMessageWithEvent:event];
            [DConnectBatteryProfile setBattery:batteryMsg target:eventMsg];
            DConnectDevicePlugin *plugin = (DConnectDevicePlugin *) self.plugin;
            [plugin sendEvent:eventMsg];
        }
    }
}

@end
