//
//  DPLinkingServiceDiscoveryProfile.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DPLinkingServiceDiscoveryProfile : DConnectServiceDiscoveryProfile

- (instancetype) initWithServiceProvider:(DConnectServiceProvider *) serviceProvider;

@end
