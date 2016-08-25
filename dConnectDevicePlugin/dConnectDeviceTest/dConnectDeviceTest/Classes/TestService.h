//
//  TestService.h
//  dConnectDeviceTest
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectServiceInformationProfile.h>

extern NSString *const TestNetworkServiceIdSpecialCharacters;
extern NSString *const TestNetworkDeviceName;
extern NSString *const TestNetworkDeviceNameSpecialCharacters;
extern NSString *const TestNetworkDeviceType;

@interface TestService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId:(NSString *)serviceId serviceName:(NSString *) serviceName plugin:(id)plugin;

@end
