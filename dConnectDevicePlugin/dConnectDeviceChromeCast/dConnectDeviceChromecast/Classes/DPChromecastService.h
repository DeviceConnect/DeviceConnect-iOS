//
//  DPChromecastService.h
//  dConnectDeviceChromecast
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectService.h>

@interface DPChromecastService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId: (NSString *) serviceId deviceName: (NSString *) deviceName plugin: (id) plugin;

@end
