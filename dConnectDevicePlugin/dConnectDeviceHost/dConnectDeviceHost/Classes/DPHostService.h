//
//  DPHostService.h
//  dConnectDeviceHost
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <DConnectSDK/DConnectServiceInformationProfile.h>

extern NSString *const DPHostDevicePluginServiceId;

@interface DPHostService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithFileManager: (DConnectFileManager *) fileMgr plugin: (id) plugin;

@end
