//
//  DPIRKitVirtualService.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DPIRKitVirtualService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId: (NSString *)serviceId name:(NSString*)name
                            plugin:(id)plugin profileName:(NSString *)profileName;

@end
