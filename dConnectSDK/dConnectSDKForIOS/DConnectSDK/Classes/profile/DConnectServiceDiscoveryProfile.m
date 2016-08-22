//
//  DConnectServiceDiscoveryProfile.m
//  dConnectManager
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceDiscoveryProfile.h"
#import <DConnectSDK/DConnectService.h>

NSString *const DConnectServiceDiscoveryProfileName = @"serviceDiscovery";
NSString *const DConnectServiceDiscoveryProfileAttrOnServiceChange = @"onservicechange";
NSString *const DConnectServiceDiscoveryProfileParamNetworkService = @"networkService";
NSString *const DConnectServiceDiscoveryProfileParamServices = @"services";
NSString *const DConnectServiceDiscoveryProfileParamState = @"state";
NSString *const DConnectServiceDiscoveryProfileParamId = @"id";
NSString *const DConnectServiceDiscoveryProfileParamName = @"name";
NSString *const DConnectServiceDiscoveryProfileParamType = @"type";
NSString *const DConnectServiceDiscoveryProfileParamOnline = @"online";
NSString *const DConnectServiceDiscoveryProfileParamConfig = @"config";
NSString *const DConnectServiceDiscoveryProfileParamScopes = @"scopes";

NSString *const DConnectServiceDiscoveryProfileNetworkTypeUnknown = @"Unknown";
NSString *const DConnectServiceDiscoveryProfileNetworkTypeWiFi = @"WiFi";
NSString *const DConnectServiceDiscoveryProfileNetworkTypeBluetooth = @"Bluetooth";
NSString *const DConnectServiceDiscoveryProfileNetworkTypeNFC = @"NFC";
NSString *const DConnectServiceDiscoveryProfileNetworkTypeBLE = @"BLE";

@implementation DConnectServiceDiscoveryProfile

- (instancetype) initWithServiceProvider: (DConnectServiceProvider *) serviceProvider {
    self = [super init];
    if (self) {
        
        NSString *getServicesApiPath = [self apiPath: nil
                                       attributeName: nil];
        [self addGetPath: getServicesApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         DConnectArray *services = [DConnectArray array];
                         
                         for (DConnectService *serviceEntity in [serviceProvider services]) {
                             DConnectMessage *service = [DConnectMessage message];
                             NSString *serviceId = [serviceEntity serviceId];
                             [DConnectServiceDiscoveryProfile setId:serviceId
                                                             target:service];
                             [DConnectServiceDiscoveryProfile setName:[serviceEntity name]
                                                               target:service];
                             [DConnectServiceDiscoveryProfile setType:[serviceEntity networkType]
                                                               target:service];
                             [DConnectServiceDiscoveryProfile setOnline:[serviceEntity online] target:service];
                             [services addMessage:service];
                         }
                         [DConnectServiceDiscoveryProfile setServices:services target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
    }
    return self;
}

#pragma mark - DConnectProfile Methods -

- (NSString *) profileName {
    return DConnectServiceDiscoveryProfileName;
}

#pragma mark - Setter
+ (void) setServices:(DConnectArray *)services target:(DConnectMessage *)message {
    [message setArray:services forKey:DConnectServiceDiscoveryProfileParamServices];
}

+ (void) setNetworkService:(DConnectMessage *)networkService target:(DConnectMessage *)message {
    [message setMessage:networkService forKey:DConnectServiceDiscoveryProfileParamNetworkService];
}

+ (void) setId:(NSString *)serviceId target:(DConnectMessage *)message {
    [message setString:serviceId forKey:DConnectServiceDiscoveryProfileParamId];
}

+ (void) setName:(NSString *)name target:(DConnectMessage *)message {
    [message setString:name forKey:DConnectServiceDiscoveryProfileParamName];
}

+ (void) setType:(NSString *)type target:(DConnectMessage *)message {
    [message setString:type forKey:DConnectServiceDiscoveryProfileParamType];
}

+ (void) setOnline:(BOOL)online target:(DConnectMessage *)message {
    [message setBool:online forKey:DConnectServiceDiscoveryProfileParamOnline];
}

+ (void) setConfig:(NSString *)config target:(DConnectMessage *)message {
    [message setString:config forKey:DConnectServiceDiscoveryProfileParamConfig];
}

+ (void) setScopesWithProvider:(DConnectProfileProvider *)provider
                        target:(DConnectMessage *)message
{
    NSArray *profiles = [provider profiles];
    if (profiles) {
        DConnectArray *names = [DConnectArray array];
        for (int i = 0; i < profiles.count; i++) {
            DConnectProfile *profile = (DConnectProfile *) profiles[i];
            [names addString:profile.profileName];
        }
        [message setArray:names forKey:DConnectServiceDiscoveryProfileParamScopes];
    }
}

+ (void) setState:(BOOL)state target:(DConnectMessage *)message {
    [message setBool:state forKey:DConnectServiceDiscoveryProfileParamState];
}

@end
