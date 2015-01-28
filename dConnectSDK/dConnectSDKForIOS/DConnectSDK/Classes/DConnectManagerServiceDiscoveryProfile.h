//
//  DConnectManagerServiceDiscoveryProfile.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServiceDiscoveryProfile.h"

/**
 * DConnectManager用のService Discoveryプロファイル.
 */
@interface DConnectManagerServiceDiscoveryProfile : DConnectServiceDiscoveryProfile
<DConnectServiceDiscoveryProfileDelegate>

- (BOOL) profile:(DConnectServiceDiscoveryProfile *)profile didReceiveGetGetNetworkServicesRequest:(DConnectRequestMessage *)request
        response:(DConnectResponseMessage *)response;

@end
