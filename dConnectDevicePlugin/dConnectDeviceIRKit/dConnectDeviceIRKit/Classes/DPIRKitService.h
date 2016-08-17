//
//  DPIRKitService.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>

@interface DPIRKitService : DConnectService

- (instancetype) initWithServiceId: (NSString *)serviceId plugin: (id) plugin;

@end
