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
#import "DConnectProfileSpec.h"
#import "DConnectSpecConstants.h"

NSString *const DConnectServiceInformationProfileName = @"serviceinformation";

NSString *const DConnectServiceInformationProfileParamSupports = @"supports";
NSString *const DConnectServiceInformationProfileParamSupportApis = @"supportApis";

NSString *const DConnectServiceInformationProfileParamConnect = @"connect";
NSString *const DConnectServiceInformationProfileParamWiFi = @"wifi";
NSString *const DConnectServiceInformationProfileParamBluetooth = @"bluetooth";
NSString *const DConnectServiceInformationProfileParamNFC = @"nfc";
NSString *const DConnectServiceInformationProfileParamBLE = @"ble";

static NSString *const DConnectServiceInformationProfileKeyPaths = @"paths";

static NSString *const DConnectServiceInformationProfileKeyInfo = @"info";
static NSString *const DConnectServiceInformationProfileKeyDefinitions = @"definitions";
static NSString *const DConnectServiceInformationProfileKeyResponses = @"responses";
static NSString *const DConnectServiceInformationProfileKeyParameters = @"parameters";
static NSString *const DConnectServiceInformationProfileKeyXEvent = @"x-event";
static NSString *const DConnectServiceInformationProfileKeySummary = @"summary";
static NSString *const DConnectServiceInformationProfileKeyDescription = @"description";

@interface DConnectServiceInformationProfile()

+ (void) message:(DConnectMessage *)message setConnectionState:(DConnectServiceInformationProfileConnectState)state
          forKey:(NSString *)aKey;
@end

@implementation DConnectServiceInformationProfile

- (instancetype) init {
    self = [super init];
    if (self) {
        __weak DConnectServiceInformationProfile *blockSelf = self;
        
        NSString *getInformationApiPath = [self apiPath: nil
                                          attributeName: nil];
        [self addGetPath: getInformationApiPath
                     api:^(DConnectRequestMessage *request, DConnectResponseMessage *response) {
                         
                         NSString *serviceId = [request serviceId];

                         DConnectMessage *connect = [DConnectMessage message];
                         if (blockSelf.dataSource) {
                             if ([blockSelf.dataSource respondsToSelector:@selector(profile:wifiStateForServiceId:)]) {
                                 DConnectServiceInformationProfileConnectState wifiState = [blockSelf.dataSource profile:blockSelf wifiStateForServiceId:serviceId];
                                 [DConnectServiceInformationProfile setWiFiState: wifiState
                                                                          target: connect];
                             }
                             if ([blockSelf.dataSource respondsToSelector:@selector(profile:bleStateForServiceId:)]) {
                                 DConnectServiceInformationProfileConnectState bleState = [blockSelf.dataSource profile:blockSelf bleStateForServiceId:serviceId];
                                 [DConnectServiceInformationProfile setBLEState:bleState
                                                                         target:connect];
                             }
                             if ([blockSelf.dataSource respondsToSelector:@selector(profile:bluetoothStateForServiceId:)]) {
                                 DConnectServiceInformationProfileConnectState bluetoothState = [blockSelf.dataSource profile:blockSelf bluetoothStateForServiceId:serviceId];
                                 [DConnectServiceInformationProfile setBluetoothState:bluetoothState
                                                                               target:connect];
                             }
                             if ([blockSelf.dataSource respondsToSelector:@selector(profile:nfcStateForServiceId:)]) {
                                 DConnectServiceInformationProfileConnectState nfcState = [blockSelf.dataSource profile:blockSelf nfcStateForServiceId:serviceId];
                                 [DConnectServiceInformationProfile setNFCState: nfcState
                                                                         target:connect];
                             }
                         }
                         [DConnectServiceInformationProfile setConnect:connect target:response];
                         
                         // supports, supportApis
                         NSArray *profiles = [[blockSelf provider] profiles];
                         DConnectArray *supports = [DConnectArray array];
                         for (DConnectProfile *profile in profiles) {
                             [supports addString:[profile profileName]];
                         }
                         [DConnectServiceInformationProfile setSupports: supports target: response];
                         NSError *error;
                         if (![DConnectServiceInformationProfile setSupportApis: profiles target: response error: &error]) {
                             [response setErrorToUnknownWithMessage: [error localizedDescription]];
                             return YES;
                         }

                         [response setResult:DConnectMessageResultTypeOk];
                         
                         return YES;
                     }];
        
    }
    return self;
}



- (NSString *) profileName {
    return DConnectServiceInformationProfileName;
}

#pragma mark - Setter

+ (void) setSupports:(DConnectArray *)supports target:(DConnectMessage *)message {
    [message setArray:supports forKey:DConnectServiceInformationProfileParamSupports];
}

+ (BOOL) setSupportApis:(NSArray *)profiles target:(DConnectMessage *)message error:(NSError **) error {
    NSMutableDictionary *supportApis = [NSMutableDictionary dictionary];
    for (DConnectProfile *profile in profiles) {
        // API定義JSONファイルのProfileSpecを参照
        DConnectProfileSpec *profileSpec = [profile profileSpec];
        if (profileSpec) {
            NSDictionary *bundle;
            if (![DConnectServiceInformationProfile createSupportApisBundle: profileSpec profile: profile outBundle:&bundle error:error]) {
                return NO;
            }
            // 送信しない情報はここで削除
            [DConnectServiceInformationProfile reduceInformationForApi:bundle outApi:&bundle];
            NSString *profileName = [profile profileName];
            supportApis[profileName] = bundle;
        }
    }
    
    // NSMutableDictionaryをDConnectMessageに変換
    DConnectMessage *supportApisBundle = [self convertToDConnectMessageFromNSDictionary: supportApis];
    [message setMessage:supportApisBundle forKey:DConnectServiceInformationProfileParamSupportApis];
    return YES;
}

+ (BOOL) createSupportApisBundle: (DConnectProfileSpec *) profileSpec profile: (DConnectProfile *) profile outBundle: (NSDictionary **) outBundle error: (NSError **) error {
    
    // bundle全体をmutableディープコピーする
    CFPropertyListRef *tmpBundle_ = (CFPropertyListRef *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                             (CFDictionaryRef)[profileSpec toBundle],
                                                                             kCFPropertyListMutableContainersAndLeaves);
    NSMutableDictionary *tmpBundle = CFBridgingRelease(tmpBundle_);
    
    // API定義(JSONファイルから読み取ったデータ)のうち、プロファイルにAPIが未実装のものは削除する
    NSMutableDictionary *pathsObj = tmpBundle[DConnectServiceInformationProfileKeyPaths];
    if (!pathsObj) {
        *outBundle = tmpBundle;
        return YES;
    }
    NSArray *pathNames = [pathsObj allKeys];
    for (NSString *pathName in pathNames) {
        NSMutableDictionary *pathObj = pathsObj[pathName];
        if (!pathObj) {
            continue;
        }
        NSArray *strMethods = DConnectSpecMethods();
        for (NSString * strMethod in strMethods) {
            NSString *strMethodName = [strMethod lowercaseString];
            NSMutableDictionary *methodObj = pathObj[strMethodName];
            if (!methodObj) {
                continue;
            }
            DConnectSpecMethod method;
            if (![DConnectSpecConstants parseMethod: strMethod outMethod:&method error:error]) {
                return NO;
            }
            if (![profile hasApi: pathName method: method]) {
                [pathObj removeObjectForKey: strMethodName];
            }
        }
        if ([pathObj count] == 0) {
            [pathsObj removeObjectForKey: pathName];
        }
    }
    *outBundle = tmpBundle;
    return YES;
}

+ (void) reduceInformationForApi:(NSDictionary*)api outApi:(NSDictionary**)outApi {
    CFPropertyListRef *tmpBundle_ = (CFPropertyListRef *)CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                                                                      (CFDictionaryRef)api,
                                                                                      kCFPropertyListMutableContainersAndLeaves);
    NSMutableDictionary *supportApi = CFBridgingRelease(tmpBundle_);
    NSMutableDictionary* infoObj = supportApi[DConnectServiceInformationProfileKeyInfo];
    if (infoObj != nil) {
        [infoObj removeObjectForKey:DConnectServiceInformationProfileKeyDescription];
    }
    NSMutableDictionary *pathsObj = supportApi[DConnectServiceInformationProfileKeyPaths];
    if (pathsObj != nil) {
        for (NSString *pathName in [pathsObj keyEnumerator]) {
            NSMutableDictionary *pathObj = pathsObj[pathName];
            if (pathObj == nil) {
                continue;
            }
            for (NSString *method in DConnectSpecMethods()) {
                NSMutableDictionary *methodObj = pathObj[[method lowercaseString]];
                if (methodObj == nil) {
                    continue;
                }
                [methodObj removeObjectForKey:DConnectServiceInformationProfileKeyResponses];
                [methodObj removeObjectForKey:DConnectServiceInformationProfileKeyXEvent];
                [methodObj removeObjectForKey:DConnectServiceInformationProfileKeySummary];
                [methodObj removeObjectForKey:DConnectServiceInformationProfileKeyDescription];

                NSMutableArray *parameters = methodObj[DConnectServiceInformationProfileKeyParameters];
                if (parameters != nil) {
                    for (NSMutableDictionary *parameter in parameters) {
                        [parameter removeObjectForKey:DConnectServiceInformationProfileKeyDescription];
                    }
                }
            }
        }
    }
    [supportApi removeObjectForKey:DConnectServiceInformationProfileKeyDefinitions];

    *outApi = supportApi;
}
// NSDictionaryをDConnectMessageに変換
+ (DConnectMessage *) convertToDConnectMessageFromNSDictionary: (NSDictionary *)dictionary {
    
    DConnectMessage *message = [DConnectMessage message];
    for (NSString *key in [dictionary allKeys]) {
        id value = dictionary[key];
        if ([value isKindOfClass: [NSDictionary class]]) {
            DConnectMessage *mes = [self convertToDConnectMessageFromNSDictionary: (NSDictionary *)value];
            [message setMessage:mes forKey:key];
        } else if ([value isKindOfClass: [NSArray class]]) {
            DConnectArray *arr = [self convertToDConnectArrayFromNSArray: (NSArray *)value];
            [message setArray:arr forKey:key];
        } else if ([value isKindOfClass: [NSNumber class]]) {
            NSNumber *number = (NSNumber *)value;
            if ([[[number class] description] isEqualToString: @"__NSCFBoolean"]) {
                [message setBool:[number boolValue] forKey:key];
            } else {
                [message setDouble:[number doubleValue] forKey:key];
            }
        } else if ([value isKindOfClass: [NSString class]]) {
            NSString *string = (NSString *)value;
            [message setString:string forKey:key];
        }
    }
    return message;
}

// NSArrayをDConnectArrayに変換
+ (DConnectArray *) convertToDConnectArrayFromNSArray: (NSArray *)array {

    DConnectArray *dcArray = [DConnectArray array];
    for (id value in array) {
        if ([value isKindOfClass: [NSDictionary class]]) {
            DConnectMessage *mes = [self convertToDConnectMessageFromNSDictionary: (NSDictionary *)value];
            [dcArray addMessage: mes];
        } else if ([value isKindOfClass: [NSArray class]]) {
            DConnectArray *arr = [self convertToDConnectArrayFromNSArray: (NSArray *)value];
            [dcArray addArray: arr];
        } else if ([value isKindOfClass: [NSNumber class]]) {
            NSNumber *number = (NSNumber *)value;
            if ([[[number class] description] isEqualToString: @"__NSCFBoolean"]) {
                [dcArray addInteger: [number integerValue]];
            } else {
                [dcArray addDouble:[number doubleValue]];
            }
        } else if ([value isKindOfClass: [NSString class]]) {
            NSString *string = (NSString *) value;
            [dcArray addString: string];
        }
        
    }
    
    return dcArray;
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

