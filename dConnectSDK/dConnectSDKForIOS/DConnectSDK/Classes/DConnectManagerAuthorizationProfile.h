//
//  DConnectManagerAuthorizationProfile.h
//  DConnectSDK
//
//  Copyright (c) 2015 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectAuthorizationProfile+Private.h"

/**
 * アプリケーションの認可を行うプロファイル.
 */
@interface DConnectManagerAuthorizationProfile : DConnectAuthorizationProfile

- (void) didReceiveInvalidOriginRequest:(DConnectRequestMessage *)request
                               response:(DConnectResponseMessage *)response;

@end
