//
//  DPHostServiceDiscoveryProfile.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>

extern NSString *const ServiceDiscoveryServiceId;

@interface DPHostServiceDiscoveryProfile : DConnectServiceDiscoveryProfile<DConnectServiceDiscoveryProfileDelegate>

@end
