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
#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectServiceManager.h>

#import "DPHostServiceDiscoveryProfile.h"

#import "DPHostBatteryProfile.h"
#import "DPHostDeviceOrientationProfile.h"
#import "DPHostFileDescriptorProfile.h"
#import "DPHostFileProfile.h"
#import "DPHostMediaPlayerProfile.h"
#import "DPHostMediaStreamRecordingProfile.h"
#import "DPHostNotificationProfile.h"
#import "DPHostPhoneProfile.h"
#import "DPHostProximityProfile.h"
#import "DPHostSettingsProfile.h"
#import "DPHostVibrationProfile.h"
#import "DPHostConnectProfile.h"
#import "DPHostCanvasProfile.h"
#import "DPHostTouchProfile.h"

NSString *const ServiceDiscoveryServiceId = @"host";

@implementation DPHostServiceDiscoveryProfile

- (instancetype)initWithFileManager:(DConnectFileManager *)fileMgr
{
    self = [super init];
    if (self) {
        self.delegate = self;
        self.fileMgr =fileMgr;
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
    [DConnectServiceDiscoveryProfile setScopesWithProvider:self.provider
                                                    target:service];
    NSString *config = [NSString stringWithFormat:@"{\"OS\":\"%@ %@\"}",
                        device.systemName, device.systemVersion];
    [DConnectServiceDiscoveryProfile setConfig:config target:service];
    
    [services addMessage:service];

    [DConnectServiceDiscoveryProfile setServices:services target:response];
    
    [response setResult:DConnectMessageResultTypeOk];
    
    // TODO: 動作確認のため上記の旧処理を残したままにしている。下記のDConnectService処理(レスポンス処理も含む)まで完成したら旧処理を削除する。
    
    // DConnectServiceManagerにDConnectServiceを登録する処理
    DConnectService *service_ = [[DConnectService alloc] initWithServiceId: ServiceDiscoveryServiceId];
    [service_ setName: name];
    [service_ setOnline: YES];
    // TODO:setScopesWithProviderは必要か？
//    [DConnectServiceDiscoveryProfile setScopesWithProvider:self.provider
//                                                    target:service];
    [service_ setConfig:config];
    
    [service_ addProfile:[DPHostBatteryProfile new]];
    [service_ addProfile:[DPHostDeviceOrientationProfile new]];
    [service_ addProfile:[[DPHostFileDescriptorProfile alloc] initWithFileManager:self.fileMgr]];
    [service_ addProfile:[DPHostFileProfile new]];
    [service_ addProfile:[DPHostMediaPlayerProfile new]];
    [service_ addProfile:[DPHostMediaStreamRecordingProfile new]];
    [service_ addProfile:[DPHostNotificationProfile new]];
    [service_ addProfile:[DPHostPhoneProfile new]];
    [service_ addProfile:[DPHostProximityProfile new]];
    [service_ addProfile:[DPHostSettingsProfile new]];
    [service_ addProfile:[DPHostVibrationProfile new]];
    [service_ addProfile:[DPHostConnectProfile new]];
    [service_ addProfile:[DPHostCanvasProfile new]];
    [service_ addProfile:[DConnectServiceInformationProfile new]];
    [service_ addProfile:[DPHostTouchProfile new]];
    DConnectServiceManager *serviceManager = [DConnectServiceManager sharedForClass: self.class];
    [serviceManager addService: service_];
    
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
    return YES;
}

#pragma mark - DConnectEventHandling

- (BOOL) unregisterAllEventsWithSessionkey:(NSString *)sessionKey
{
    return YES;
}

@end
