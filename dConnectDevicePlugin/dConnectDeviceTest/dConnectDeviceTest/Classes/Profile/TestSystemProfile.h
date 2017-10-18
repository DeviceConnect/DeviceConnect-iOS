//
//  TestSystemProfile.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface TestSystemProfile : DConnectSystemProfile<DConnectSystemProfileDataSource>

#pragma mark - DConnectSystemProfileDataSource
- (UIViewController *) profile:(DConnectSystemProfile *)sender settingPageForRequest:(DConnectRequestMessage *)request;

@end
