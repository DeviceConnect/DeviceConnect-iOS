//
//  DPAllJoynService.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import "DPAllJoynHandler.h"

@interface DPAllJoynService : DConnectService

- (instancetype) initWithServiceId: (NSString *) serviceId serviceName: (NSString *)serviceName plugin: (id) plugin handler: (DPAllJoynHandler *) handler;
@end
