//
//  DPLinkingServiceDiscoveryProfile.m
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <DConnectSDK/DConnectService.h>

#import "DPLinkingServiceDiscoveryProfile.h"
#import "DPLinkingDeviceManager.h"
#import "DPLinkingBeaconManager.h"
#import "DPLinkingDeviceService.h"
#import "DPLinkingBeaconService.h"

@implementation DPLinkingServiceDiscoveryProfile {
    DPLinkingDeviceManager *_deviceManager;
    DPLinkingBeaconManager *_beaconManager;
    DConnectServiceProvider *_serviceProvider;
}

- (instancetype) initWithServiceProvider: (DConnectServiceProvider *) serviceProvider {
    self = [super init];
    if (self) {
        __weak typeof(self) _self = self;

        _deviceManager = [DPLinkingDeviceManager sharedInstance];
        _beaconManager = [DPLinkingBeaconManager sharedInstance];
        _serviceProvider = serviceProvider;
        
        [self addGetPath:[self apiPath:nil attributeName:nil]
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         return [_self onGetService:request response:response];
                     }];

    }
    return self;
}

#pragma mark - Private Method

- (BOOL) onGetService:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response
{
    [_serviceProvider removeAllServices];

    [[DPLinkingBeaconManager sharedInstance] startBeaconScanWithTimeout:10];
    
    [self createLinkingDeviceList];
    [self createLinkingBeaconList];
    
    DConnectArray *services = [DConnectArray array];
    
    for (DConnectService *serviceEntity in [_serviceProvider services]) {
        NSString *serviceId = [serviceEntity serviceId];
        
        DConnectMessage *service = [DConnectMessage message];
        
        [DConnectServiceDiscoveryProfile setId:serviceId target:service];
        [DConnectServiceDiscoveryProfile setName:[serviceEntity name] target:service];
        [DConnectServiceDiscoveryProfile setType:[serviceEntity networkType] target:service];
        [DConnectServiceDiscoveryProfile setOnline:[serviceEntity online] target:service];

        // TODO: scopes
        NSArray *profiles = [serviceEntity profiles];
        DConnectArray *scopes = [DConnectArray array];
        for (DConnectProfile *profile in profiles) {
            [scopes addString:[profile profileName]];
        }
        [service setArray:scopes forKey:@"scopes"];
        
        [services addMessage:service];
    }
    
    [DConnectServiceDiscoveryProfile setServices:services target:response];
    [response setResult:DConnectMessageResultTypeOk];
    return YES;
}

- (void) createLinkingDeviceList
{
    __weak DConnectServiceProvider *_provider = _serviceProvider;
    __weak DConnectDevicePlugin *_plugin = self.plugin;

    NSArray *devices = [_deviceManager getDPLinkingDevices];
    [devices enumerateObjectsUsingBlock:^(DPLinkingDevice *device, NSUInteger idx, BOOL *stop) {
        [_provider addService:[[DPLinkingDeviceService alloc] initWithDevice:device plugin:_plugin]];
    }];
}

- (void) createLinkingBeaconList
{
    __weak DConnectServiceProvider *_provider = _serviceProvider;
    __weak DConnectDevicePlugin *_plugin = self.plugin;
    
    NSArray *beacons = [_beaconManager getBeacons];
    [beacons enumerateObjectsUsingBlock:^(DPLinkingBeacon *beacon, NSUInteger idx, BOOL *stop) {
        [_provider addService:[[DPLinkingBeaconService alloc] initWithBeacon:beacon plugin:_plugin]];
    }];
}

@end
