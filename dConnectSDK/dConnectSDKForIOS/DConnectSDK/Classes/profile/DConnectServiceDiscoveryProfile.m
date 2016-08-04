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

NSString *const DConnectServiceDiscoveryProfileName = @"servicediscovery";
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

@interface DConnectServiceDiscoveryProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;

@end

@implementation DConnectServiceDiscoveryProfile

- (instancetype) initWithServiceProvider: (DConnectServiceProvider *) serviceProvider {
    self = [super init];
    if (self) {
        __weak id blockSelf = self;
        __weak id blockDelegate = self.delegate;
        
        NSString *getServicesApiPath = [self apiPathWithProfile: self.profileName
                                                  interfaceName: nil
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
                             /***/
                             NSLog(@"appendServiceList: serviceId: %@", serviceId);
                             NSLog(@"appendServiceList: name: %@", [serviceEntity name]);
                             /***/
                             [DConnectServiceDiscoveryProfile setType:[serviceEntity networkType]
                                                               target:service];
                             [DConnectServiceDiscoveryProfile setOnline:[serviceEntity online] target:service];
                             [services addMessage:service];
                         }
                         [DConnectServiceDiscoveryProfile setServices:services target:response];
                         [response setResult:DConnectMessageResultTypeOk];
                         return YES;
                     }];
        
        NSString *putOnServiceChangeApiPath = [self apiPathWithProfile: self.profileName
                                                         interfaceName: nil
                                                         attributeName: DConnectServiceDiscoveryProfileAttrOnServiceChange];
        [self addPutPath: putOnServiceChangeApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         BOOL send = YES;
                         if ([blockSelf hasMethod:@selector(profile:
                                                                               didReceivePutOnServiceChangeRequest:
                                                                               response:
                                                                               serviceId:
                                                                               sessionKey:)
                                                            response:response]) {
                             send = [blockDelegate profile:blockSelf
                                               didReceivePutOnServiceChangeRequest:request
                                                                          response:response
                                                                         serviceId:[request serviceId]
                                                                        sessionKey:[request sessionKey]];
                         }
                         return send;
                     }];

        NSString *deleteOnServiceChangeApiPath = [self apiPathWithProfile: self.profileName
                                                            interfaceName: nil
                                                            attributeName: DConnectServiceDiscoveryProfileAttrOnServiceChange];
        [self addDeletePath: deleteOnServiceChangeApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         BOOL send = YES;
                         if ([blockSelf hasMethod:@selector(profile:
                                                                               didReceiveDeleteOnServiceChangeRequest:
                                                                               response:
                                                                               serviceId:
                                                                               sessionKey:)
                                                            response:response]) {
                             send = [blockDelegate profile:blockSelf
                                            didReceiveDeleteOnServiceChangeRequest:request response:response
                                                                         serviceId:[request serviceId]
                                                                        sessionKey:[request sessionKey]];
                         }
                         return send;
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

#pragma mark - Private Methods

// TODO: 削除する
- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

@end
