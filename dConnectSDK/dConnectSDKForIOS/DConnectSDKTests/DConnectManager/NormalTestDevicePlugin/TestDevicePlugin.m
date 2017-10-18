//
//  SuccessTestDevicePlugin.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "TestDevicePlugin.h"

NSString *const TestDevicePluginAppName = @"Test Device Plugin v0.1";

// Service Discoveryの定数

NSString *const TestDevicePluginName = @"TestDevicePlugin";
NSString *const TestDevicePluginId = @"0";
NSString *const TestDevicePluginType = @"TEST";

// System Profileの定数

NSString *const TestDevicePluginSystemVersion = @"2.0.0";


/** デバイスプラグインのバッテリーチャージフラグを定義. */
const BOOL TestDevicePluginBatteryCharging = YES;
/** デバイスプラグインのバッテリーチャージ時間を定義. */
const long TestDevicePluginBatteryChargingTime = 50000;
/** デバイスプラグインのバッテリー放電時間を定義. */
const long TestDevicePluginBatteryDischargingTime = 10000;
/** デバイスプラグインのバッテリーレベルを定義. */
const float TestDevicePluginBatteryLevel = 0.5;


@interface TestDevicePlugin : DConnectDevicePlugin <DConnectServiceDiscoveryProfileDelegate, DConnectSystemProfileDelegate, DConnectBatteryProfileDelegate, DConnectSystemProfileDataSource>

/*!
 * サービスIDの正当性をチェックする.
 * @param serviceId サービスID
 * @return 正常な場合はtrue、それ以外はfalse
 */
- (BOOL) checkServiceId:(NSString *)serviceId;

@end

@implementation TestDevicePlugin

- (id) init {
    self = [super initWithObject: self];
    if (self) {
        // プラグインの名前を設定
        self.pluginName = TestDevicePluginAppName;
        
        // イベント管理クラス
        [DConnectEventManager sharedManagerForClass:[self class]];
        
        // Service Discovery Profileの追加
        DConnectServiceDiscoveryProfile *networkProfile = [DConnectServiceDiscoveryProfile new];
        networkProfile.delegate = self;
        
        // System Profileの追加
        DConnectSystemProfile *systemProfile = [DConnectSystemProfile new];
        systemProfile.delegate = self;
        systemProfile.dataSource = self;
        
        // Battery Profileの追加
        DConnectBatteryProfile *batteryProfile = [DConnectBatteryProfile new];
        batteryProfile.delegate = self;
        
        // 各プロファイルの追加
        [self addProfile:networkProfile];
        [self addProfile:systemProfile];
        [self addProfile:batteryProfile];
    }
    return self;
}

#pragma mark - Public Methods -

- (BOOL) checkServiceId:(NSString *)serviceId {
    return [TestDevicePluginId isEqualToString:serviceId];
}


#pragma mark - DConnectServiceDiscoveryProfileDelegate

- (BOOL)                       profile:(DConnectServiceDiscoveryProfile *)profile
didReceiveGetServicesRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
{
    DConnectArray *services = [DConnectArray array];
    
    DConnectMessage *service = [DConnectMessage message];
    [DConnectServiceDiscoveryProfile setId:TestDevicePluginId target:service];
    [DConnectServiceDiscoveryProfile setName:TestDevicePluginName target:service];
    [DConnectServiceDiscoveryProfile setType:TestDevicePluginType
                                             target:service];
    [DConnectServiceDiscoveryProfile setOnline:YES target:service];
    [services addMessage:service];
    
    [response setInteger:DConnectMessageResultTypeOk forKey:DConnectMessageResult];
    [response setArray:services forKey:DConnectServiceDiscoveryProfileParamServices];
    
    return YES;
}

#pragma mark - DConnectSystemProfileDelegate


#pragma mark - DConnectSystemProfileDataSource

- (UIViewController *) profile:(DConnectSystemProfile *)sender
         settingPageForRequest:(DConnectRequestMessage *)request
{
    return nil;
}

#pragma mark - DConnectBatteryProfileDelegate

- (BOOL)        profile:(DConnectBatteryProfile *)profile
didReceiveGetAllRequest:(DConnectRequestMessage *)request
               response:(DConnectResponseMessage *)response
               serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else if (![self checkServiceId:serviceId]) {
        [response setErrorToNotFoundService];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setCharging:TestDevicePluginBatteryCharging target:response];
        [DConnectBatteryProfile setChargingTime:TestDevicePluginBatteryChargingTime target:response];
        [DConnectBatteryProfile setDischargingTime:TestDevicePluginBatteryDischargingTime target:response];
        [DConnectBatteryProfile setLevel:TestDevicePluginBatteryLevel target:response];
    }
    return YES;
}

- (BOOL)          profile:(DConnectBatteryProfile *)profile
didReceiveGetLevelRequest:(DConnectRequestMessage *)request
                 response:(DConnectResponseMessage *)response
                 serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else if (![self checkServiceId:serviceId]) {
        [response setErrorToNotFoundService];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setLevel:TestDevicePluginBatteryLevel target:response];
    }
    return YES;
}

- (BOOL)             profile:(DConnectBatteryProfile *)profile
didReceiveGetChargingRequest:(DConnectRequestMessage *)request
                    response:(DConnectResponseMessage *)response
                    serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else if (![self checkServiceId:serviceId]) {
        [response setErrorToNotFoundService];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setCharging:TestDevicePluginBatteryCharging target:response];
    }
    return YES;
}

- (BOOL)                 profile:(DConnectBatteryProfile *)profile
didReceiveGetChargingTimeRequest:(DConnectRequestMessage *)request
                        response:(DConnectResponseMessage *)response
                        serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else if (![self checkServiceId:serviceId]) {
        [response setErrorToNotFoundService];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setChargingTime:TestDevicePluginBatteryChargingTime target:response];
    }
    return YES;
}

- (BOOL)                    profile:(DConnectBatteryProfile *)profile
didReceiveGetDischargingTimeRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
{
    if (!serviceId) {
        [response setErrorToEmptyServiceId];
    } else if (![self checkServiceId:serviceId]) {
        [response setErrorToNotFoundService];
    } else {
        [response setResult:DConnectMessageResultTypeOk];
        [DConnectBatteryProfile setDischargingTime:TestDevicePluginBatteryDischargingTime target:response];
    }
    return YES;
}

#pragma mark DConnectBatteryProfileDelegate Event Registration

- (BOOL)                     profile:(DConnectBatteryProfile *)profile
didReceivePutOnChargingChangeRequest:(DConnectRequestMessage *)request
                            response:(DConnectResponseMessage *)response
                            serviceId:(NSString *)serviceId
                          sessionKey:(NSString *)sessionKey
{
    return YES;
}

- (BOOL)                    profile:(DConnectBatteryProfile *)profile
didReceivePutOnBatteryChangeRequest:(DConnectRequestMessage *)request
                           response:(DConnectResponseMessage *)response
                           serviceId:(NSString *)serviceId
                         sessionKey:(NSString *)sessionKey
{
    return YES;
}

#pragma mark DConnectBatteryProfileDelegate Event Unregistration

- (BOOL)                        profile:(DConnectBatteryProfile *)profile
didReceiveDeleteOnChargingChangeRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response
                               serviceId:(NSString *)serviceId
                             sessionKey:(NSString *)sessionKey
{
    return YES;
}

- (BOOL)                       profile:(DConnectBatteryProfile *)profile
didReceiveDeleteOnBatteryChangeRequest:(DConnectRequestMessage *)request
                              response:(DConnectResponseMessage *)response
                              serviceId:(NSString *)serviceId
                            sessionKey:(NSString *)sessionKey
{
    return YES;
}

@end
