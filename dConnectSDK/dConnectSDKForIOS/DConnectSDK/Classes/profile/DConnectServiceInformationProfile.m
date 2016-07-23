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
#import <DConnectSDK/DConnectProfile.h>

NSString *const DConnectServiceInformationProfileName = @"serviceinformation";

NSString *const DConnectServiceInformationProfileParamSupports = @"supports";
NSString *const DConnectServiceInformationProfileParamSupportApis = @"supportApis";

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

- (instancetype) initWithProvider: (id<DConnectProfileProvider>) provider {
    self = [super initWithProvider: provider];
    if (self) {
        __weak id blockSelf = self;
        __weak id<DConnectProfileProvider> blockProvider = self.provider;
        __weak id<DConnectServiceInformationProfileDataSource> blockDataSource = _dataSource;
        
        NSString *getInformationApiPath = [self apiPathWithProfile: self.profileName
                                                  interfaceName: nil
                                                  attributeName: nil];
        [self addGetPath: getInformationApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];

                         DConnectMessage *connect = [DConnectMessage message];
                         if (blockDataSource) {
                             if ([blockDataSource respondsToSelector:@selector(profile:wifiStateForServiceId:)]) {
                                 [DConnectServiceInformationProfile setWiFiState:
                                  [blockDataSource profile:blockSelf wifiStateForServiceId:serviceId]
                                                                          target:connect];
                             }
                             if ([blockDataSource respondsToSelector:@selector(profile:bleStateForServiceId:)]) {
                                 [DConnectServiceInformationProfile setBLEState:
                                  [blockDataSource profile:blockSelf bleStateForServiceId:serviceId]
                                                                         target:connect];
                             }
                             if ([blockDataSource respondsToSelector:@selector(profile:bluetoothStateForServiceId:)]) {
                                 [DConnectServiceInformationProfile setBluetoothState:
                                  [blockDataSource profile:blockSelf bluetoothStateForServiceId:serviceId]
                                                                               target:connect];
                             }
                             if ([blockDataSource respondsToSelector:@selector(profile:nfcStateForServiceId:)]) {
                                 [DConnectServiceInformationProfile setNFCState:
                                  [blockDataSource profile:blockSelf nfcStateForServiceId:serviceId]
                                                                         target:connect];
                             }
                         }
                         [DConnectServiceInformationProfile setConnect:connect target:response];
                         
                         // supports, supportApis
                         NSArray *profiles = [blockProvider profiles];
                         DConnectArray *supports = [DConnectArray array];
                         for (DConnectProfile *profile in profiles) {
                             [supports addString:[profile profileName]];
                         }
                         [DConnectServiceInformationProfile setSupports: supports target: response];
                         [DConnectServiceInformationProfile setSupportApis: profiles target: response];

                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];
        
    }
    return self;
}



- (NSString *) profileName {
    return DConnectServiceInformationProfileName;
}

/*
- (BOOL) didReceiveGetRequest:(DConnectRequestMessage *)request response:(DConnectResponseMessage *)response {
    BOOL send = YES;
    
    NSString *interface = [request interface];
    NSString *attribute = [request attribute];
    NSString *serviceId = [request serviceId];
    
    if (!interface && !attribute) {
        if ([_delegate respondsToSelector:@selector(profile:didReceiveGetInformationRequest:response:serviceId:)])
        {
            send = [_delegate profile:self didReceiveGetInformationRequest:request
                             response:response serviceId:serviceId];
        } else {
            DConnectMessage *connect = [DConnectMessage message];
            if (_dataSource) {
                if ([_dataSource respondsToSelector:@selector(profile:wifiStateForServiceId:)]) {
                    [DConnectServiceInformationProfile setWiFiState:
                        [_dataSource profile:self wifiStateForServiceId:serviceId]
                                             target:connect];
                }
                if ([_dataSource respondsToSelector:@selector(profile:bleStateForServiceId:)]) {
                    [DConnectServiceInformationProfile setBLEState:
                        [_dataSource profile:self bleStateForServiceId:serviceId]
                                            target:connect];
                }
                if ([_dataSource respondsToSelector:@selector(profile:bluetoothStateForServiceId:)]) {
                    [DConnectServiceInformationProfile setBluetoothState:
                        [_dataSource profile:self bluetoothStateForServiceId:serviceId]
                                                  target:connect];
                }
                if ([_dataSource respondsToSelector:@selector(profile:nfcStateForServiceId:)]) {
                    [DConnectServiceInformationProfile setNFCState:
                        [_dataSource profile:self nfcStateForServiceId:serviceId]
                                            target:connect];
                }
            }
            [DConnectServiceInformationProfile setConnect:connect target:response];
            
            DConnectArray *supports = [DConnectArray array];
            NSArray *profiles = [self.provider profiles];
            for (DConnectProfile *profile in profiles) {
                [supports addString:[profile profileName]];
            }
            [DConnectServiceInformationProfile setSupports:supports target:response];
            [response setResult:DConnectMessageResultTypeOk];
        }
    } else {
        [response setErrorToNotSupportProfile];
    }
    
    return send;
}
*/

#pragma mark - Setter

+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message {
    [message setArray:supports forKey:DConnectServiceInformationProfileParamSupports];
}

+ (void) setSupportApis:(NSArray *)profiles target:(DConnectMessage *)message {
    // TODO: supportApisレスポンス処理未実装(Swagger対応と一緒に実装する予定)
/*
    Bundle supportApisBundle = new Bundle();
    for (final DConnectProfile profile : profileList) {
        DConnectProfileSpec profileSpec = profile.getProfileSpec();
        if (profileSpec != null) {
            Bundle bundle = profileSpec.toBundle(new DConnectApiSpecFilter() {
                @Override
                public boolean filter(final String path, final Method method) {
                    return profile.hasApi(path, method);
                }
            });
            supportApisBundle.putBundle(profile.getProfileName(), bundle);
        }
    }
    [response.putExtra(PARAM_SUPPORT_APIS, supportApisBundle);
*/
//    [message setArray:supportApis forKey:DConnectServiceInformationProfileParamSupportApis];
}

+ (void) setConnect:(DConnectMessage *)connect target:(DConnectMessage *)message {
    [message setMessage:connect forKey:DConnectServiceInformationProfileParamConnect];
}

+ (void) setWiFiState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message
                            setConnectionState:state
                                        forKey:DConnectServiceInformationProfileParamWiFi];
}

+ (void) setBluetoothState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message
                            setConnectionState:state
                                        forKey:DConnectServiceInformationProfileParamBluetooth];
}

+ (void) setNFCState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message
                            setConnectionState:state
                                        forKey:DConnectServiceInformationProfileParamNFC];
}

+ (void) setBLEState:(DConnectServiceInformationProfileConnectState)state target:(DConnectMessage *)message {
    [DConnectServiceInformationProfile message:message
                            setConnectionState:state
                                        forKey:DConnectServiceInformationProfileParamBLE];
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
        case DConnectServiceInformationProfileConnectStateNone:
            [message setBool:NO forKey:aKey];
            break;
        default:
            break;
    }
}
@end

