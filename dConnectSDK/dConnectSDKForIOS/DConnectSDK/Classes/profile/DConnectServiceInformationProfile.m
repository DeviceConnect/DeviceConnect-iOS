//
//  DConnectServiceInformationProfile.m
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceInformationProfile.h"
#import "DConnectProfileProvider.h"

NSString *const DConnectServiceInformationProfileName = @"serviceinformation";

NSString *const DConnectServiceInformationProfileParamSupports = @"supports";

NSString *const DConnectServiceInformationProfileParamConnect = @"connect";
NSString *const DConnectServiceInformationProfileParamWiFi = @"wifi";
NSString *const DConnectServiceInformationProfileParamBluetooth = @"bluetooth";
NSString *const DConnectServiceInformationProfileParamNFC = @"nfc";
NSString *const DConnectServiceInformationProfileParamBLE = @"ble";

@interface DConnectServiceInformationProfile()

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response;
+ (void) message:(DConnectMessage *)message setConnectionState:(DConnectServiceInformationProfileConnectState)state
          forKey:(NSString *)aKey;
@end

@implementation DConnectServiceInformationProfile

- (NSString *) profileName {
    return DConnectServiceInformationProfileName;
}

- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (!interface && !attribute) {
        if ([_delegate respondsToSelector:@selector(profile:didReceiveGetInformationRequest:response:serviceId:)])
        {
            send = [_delegate profile:self didReceiveGetInformationRequest:request response:response serviceId:serviceId];
        } else if (_dataSource) {
            
            DConnectMessage *connect = [DConnectMessage message];
            if ([_dataSource respondsToSelector:@selector(profile:wifiStateForServiceId:)]) {
                [DConnectServiceInformationProfile setWiFiState:[_dataSource profile:self wifiStateForServiceId:serviceId]
                                             target:connect];
            }
            if ([_dataSource respondsToSelector:@selector(profile:bleStateForServiceId:)]) {
                [DConnectServiceInformationProfile setBLEState:[_dataSource profile:self bleStateForServiceId:serviceId]
                                            target:connect];
            }
            if ([_dataSource respondsToSelector:@selector(profile:bluetoothStateForServiceId:)]) {
                [DConnectServiceInformationProfile setBluetoothState:[_dataSource profile:self bluetoothStateForServiceId:serviceId]
                                                  target:connect];
            }
            if ([_dataSource respondsToSelector:@selector(profile:nfcStateForServiceId:)]) {
                [DConnectServiceInformationProfile setNFCState:[_dataSource profile:self nfcStateForServiceId:serviceId]
                                            target:connect];
            }
            
            [DConnectServiceInformationProfile setConnect:connect target:response];
            
            DConnectArray *supports = [DConnectArray array];
            NSArray *profiles = [self.provider profiles];
            
            for (DConnectProfile *profile in profiles) {
                [supports addString:[profile profileName]];
            }
            
            [DConnectServiceInformationProfile setSupports:supports target:response];
            [response setResult:DConnectMessageResultTypeOk];
        } else {
            [response setErrorToNotSupportAction];
        }
    } else {
        [response setErrorToUnknownAttribute];
    }
    
    return send;
}

#pragma mark - Setter

+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message {
    [message setArray:supports forKey:DConnectServiceInformationProfileParamSupports];
}

+ (void) setConnect:(DConnectMessage *)connect target:(DConnectMessage *)message {
    [message setMessage:connect forKey:DConnectServiceInformationProfileParamConnect];
}

+ (void) setWiFiState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message setConnectionState:state forKey:DConnectServiceInformationProfileParamWiFi];
}

+ (void) setBluetoothState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message setConnectionState:state forKey:DConnectServiceInformationProfileParamBluetooth];
}

+ (void) setNFCState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message setConnectionState:state forKey:DConnectServiceInformationProfileParamNFC];
}

+ (void) setBLEState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message setConnectionState:state forKey:DConnectServiceInformationProfileParamBLE];
}

#pragma mark - Private Methods

- (BOOL) hasMethod:(SEL)method response:(DConnectResponseMessage *)response {
    BOOL result = [_delegate respondsToSelector:method];
    if (!result) {
        [response setErrorToNotSupportAttribute];
    }
    return result;
}

+ (void) message:(DConnectMessage *)message setConnectionState:(DConnectServiceInformationProfileConnectState)state
          forKey:(NSString *)aKey
{
    switch (state) {
        case DConnectServiceInformationProfileConnectStateOn:
            [message setBool:YES forKey:aKey];
            break;
        case DConnectServiceInformationProfileConnectStateOff:
            [message setBool:NO forKey:aKey];
            break;
        default:
            break;
    }
}

@end
