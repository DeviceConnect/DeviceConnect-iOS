//
//  DPAllJoynServiceDiscoveryProfile.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPAllJoynHandler.h"


@interface DPAllJoynServiceDiscoveryProfile : DConnectServiceDiscoveryProfile

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithHandler:(DPAllJoynHandler *)handler
NS_DESIGNATED_INITIALIZER;

@end
