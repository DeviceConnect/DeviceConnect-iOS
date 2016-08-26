//
//  DPHitoeService.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <DConnectSDK/DConnectServiceInformationProfile.h>
#import "DPHitoeDevice.h"

@interface DPHitoeService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId: (NSString *) serviceId plugin: (id) plugin;

@end
