//
//  DPAWSIoTService.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>

@interface DPAWSIoTService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId:(NSString *)serviceId deviceName: (NSString *) deviceName plugin: (id) plugin;

@end
