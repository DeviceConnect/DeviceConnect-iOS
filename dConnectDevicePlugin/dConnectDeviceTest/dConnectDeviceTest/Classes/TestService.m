//
//  TestService.m
//  dConnectDeviceTest
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "TestService.h"
#import "TestLightProfile.h"
#import "TestBatteryProfile.h"
#import "TestConnectionProfile.h"
#import "TestDeviceOrientationProfile.h"
#import "TestFileDescriptorProfile.h"
#import "TestFileProfile.h"
#import "TestMediaPlayerProfile.h"
#import "TestMediaStreamRecordingProfile.h"
#import "TestNotificationProfile.h"
#import "TestPhoneProfile.h"
#import "TestProximityProfile.h"
#import "TestSettingProfile.h"
#import "TestVibrationProfile.h"
#import "TestUniquePingProfile.h"
#import "TestUniqueTimeoutProfile.h"
#import "TestUniqueEventProfile.h"
#import "TestRemoteControllerProfile.h"
#import "TestDriveControllerProfile.h"
#import "TestOmnidirectionalImageProfile.h"
#import "TestAllGetControlProfile.h"

NSString *const TestNetworkServiceIdSpecialCharacters = @"!#$'()-~¥@[;+:*],._/=?&%^|`\"{}<>";
NSString *const TestNetworkDeviceName = @"Test Success Device";
NSString *const TestNetworkDeviceNameSpecialCharacters = @"Test Service ID Special Characters";
NSString *const TestNetworkDeviceType = @"TEST";

static const BOOL TestNetworkDeviceOnline = YES;
static NSString *const TestNetworkDeviceConfig = @"test config";

@implementation TestService

- (instancetype) initWithServiceId:(NSString *)serviceId serviceName: (NSString *) serviceName plugin:(id)plugin {
    
    self = [super initWithServiceId: serviceId plugin:plugin];
    if (self) {
        
        [self setName: serviceName];
        [self setNetworkType: TestNetworkDeviceType];
        [self setOnline: TestNetworkDeviceOnline];
        [self setConfig:TestNetworkDeviceConfig];
        
        // プロファイルを追加
        [self addProfile:[TestLightProfile new]];
        [self addProfile:[TestBatteryProfile new]];
        [self addProfile:[TestConnectionProfile new]];
        [self addProfile:[TestDeviceOrientationProfile new]];
        [self addProfile:[TestFileDescriptorProfile new]];
        [self addProfile:[TestFileProfile new]];
        [self addProfile:[TestMediaPlayerProfile new]];
        [self addProfile:[TestMediaStreamRecordingProfile new]];
        [self addProfile:[TestNotificationProfile new]];
        [self addProfile:[TestPhoneProfile new]];
        [self addProfile:[TestProximityProfile new]];
        [self addProfile:[TestSettingProfile new]];
        [self addProfile:[TestVibrationProfile new]];
        [self addProfile:[TestRemoteControllerProfile new]];
        [self addProfile:[TestDriveControllerProfile new]];
        [self addProfile:[TestOmnidirectionalImageProfile new]];
        
        [self addProfile:[TestUniquePingProfile new]];
        [self addProfile:[TestUniqueTimeoutProfile new]];
        [self addProfile:[TestUniqueEventProfile new]];
        [self addProfile:[TestAllGetControlProfile new]];
    }
    return self;
    
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
