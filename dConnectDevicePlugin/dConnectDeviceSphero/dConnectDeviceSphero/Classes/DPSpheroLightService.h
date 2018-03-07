//
//  DPSpheroLightService.h
//  dConnectDeviceSphero
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <DConnectSDK/DConnectService.h>

@interface DPSpheroLightService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId:(NSString *)serviceId
                           lightId:(NSString *)lightId
                        deviceName: (NSString *) deviceName
                            plugin: (id) plugin;

@end
