//
//  DPSpheroService.h
//  dConnectDeviceSphero
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>

@interface DPSpheroService : DConnectService

- (instancetype) initWithServiceId:(NSString *)serviceId deviceName: (NSString *) deviceName;

@end