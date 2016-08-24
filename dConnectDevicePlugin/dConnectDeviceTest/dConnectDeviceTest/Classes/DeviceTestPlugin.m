//
//  DeviceTestPlugin.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DeviceTestPlugin.h"
#import "TestService.h"
#import "TestSystemProfile.h"

@interface DeviceTestPlugin() <DConnectServiceInformationProfileDataSource>

@end

@implementation DeviceTestPlugin

- (id) init {
    
    self = [super initWithObject: self];
    
    if (self) {
        self.useLocalOAuth = NO;
        self.pluginName = @"Device Connect Device Plugin for Test";
        
        _fm = [DConnectFileManager fileManagerForPlugin:self];
        
        // プロファイルを追加
        [self addProfile:[TestSystemProfile new]];
        
        [[DConnectEventManager sharedManagerForClass:[self class]]
         setController:[DConnectMemoryCacheController new]];
        
        // 典型的なサービス追加
        DConnectService *service;
        service = [[TestService alloc] initWithServiceId:TDPServiceId serviceName:TestNetworkDeviceName plugin:self];
        [self.serviceProvider addService: service];
        
        // サービスIDが特殊なサービス
        service = [[TestService alloc] initWithServiceId:TestNetworkServiceIdSpecialCharacters serviceName:TestNetworkDeviceNameSpecialCharacters plugin:self];
        [self.serviceProvider addService: service];
    }
    
    return self;
}

- (void) asyncSendEvent:(DConnectMessage *)event {
    [self asyncSendEvent:event delay:DEFAULT_EVENT_DELAY];
}

- (void) asyncSendEvent:(DConnectMessage *)event delay:(NSTimeInterval)delay {
    __block DeviceTestPlugin *_self = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:delay];
        [_self sendEvent:event];
    });

}

#pragma mark DConnectServiceInformationProfileDataSource

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                                    wifiStateForServiceId:(NSString *)serviceId
{
    return DConnectServiceInformationProfileConnectStateOff;
}

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                                    bluetoothStateForServiceId:(NSString *)serviceId
{
    return DConnectServiceInformationProfileConnectStateOff;
}

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                                    nfcStateForServiceId:(NSString *)serviceId
{
    return DConnectServiceInformationProfileConnectStateOff;
}

- (DConnectServiceInformationProfileConnectState) profile:(DConnectServiceInformationProfile *)profile
                                    bleStateForServiceId:(NSString *)serviceId
{
    return DConnectServiceInformationProfileConnectStateOff;
}

@end
