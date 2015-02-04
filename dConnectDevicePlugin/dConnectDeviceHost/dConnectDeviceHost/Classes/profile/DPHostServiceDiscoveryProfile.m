//
//  DPHostServiceDiscoveryProfile.m
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectMessage.h>

#import "DPHostServiceDiscoveryProfile.h"

NSString *const ServiceDiscoveryServiceId = @"host";

@implementation DPHostServiceDiscoveryProfile

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

#pragma mark - DConnectServiceDiscoveryProfileDelegate
#pragma mark Get Methods

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
{
    // ハードウェアプラットフォームを取得。
    UIDevice *device = [UIDevice currentDevice];
    NSString *name = [NSString stringWithFormat:@"Host: %@", device.name];
    
    DConnectArray *services = [DConnectArray array];
    
    DConnectMessage *service = [DConnectMessage message];
    [DConnectServiceDiscoveryProfile setId:ServiceDiscoveryServiceId target:service];
    [DConnectServiceDiscoveryProfile setName:name target:service];
    [DConnectServiceDiscoveryProfile setOnline:YES target:service];
    NSString *config = [NSString stringWithFormat:@"{\"OS\":\"%@ %@\"}",
                        device.systemName, device.systemVersion];
    [DConnectServiceDiscoveryProfile setConfig:config target:service];
    [services addMessage:service];

    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    return YES;
}

#pragma mark - Put Methods

- (BOOL)                    profile:(DConnectServiceDiscoveryProfile *)profile
didReceivePutOnServiceChangeRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    if (!sessionKey) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
        return YES;
    }
    
    // このデバイスプラグインは常駐；常に接続していて、接続が失われることも無いので、イベントの送信は行わない。
    return YES;
}

#pragma mark - Delete Methods

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveDeleteOnServiceChangeRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    if (!sessionKey) {
        [response setErrorToInvalidRequestParameterWithMessage:@"sessionKey must be specified."];
        return YES;
    }
    
    // このデバイスプラグインは常駐；常に接続していて、接続が失われることも無いので、イベントの送信は行わない。
    return YES;
}

#pragma mark - DConnectEventHandling

- (BOOL) unregisterAllEventsWithSessionkey:(NSString *)sessionKey
{
    // このデバイスプラグインは常駐；常に接続していて、接続が失われることも無いので、イベントの送信は行わない。
    return YES;
}

@end
