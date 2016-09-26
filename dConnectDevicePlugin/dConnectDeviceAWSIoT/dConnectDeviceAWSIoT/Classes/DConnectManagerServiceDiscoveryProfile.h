//
//  DConnectManagerServiceDiscoveryProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>

/**
 * DConnectManager用のService Discoveryプロファイル.
 */
@interface DConnectManagerServiceDiscoveryProfile : DConnectServiceDiscoveryProfile

- (BOOL)getServicesRequest : (DConnectRequestMessage *) request response: (DConnectResponseMessage *) response;

@end
