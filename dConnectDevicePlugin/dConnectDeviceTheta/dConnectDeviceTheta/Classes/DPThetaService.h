//
//  DPThetaService.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>

extern NSString *const DPThetaDeviceServiceId;
extern NSString *const DPThetaRoiServiceId;

@interface DPThetaService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId: (NSString *) serviceId plugin: (id) plugin;

@end
