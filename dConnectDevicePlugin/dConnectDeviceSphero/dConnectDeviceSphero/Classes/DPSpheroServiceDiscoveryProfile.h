//
//  DPSpheroServiceDiscoveryProfile.h
//  dConnectDeviceSphero
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
/*! @file
 @brief SpheroデバイスプラグインのServiceDiscoveryProfile機能を提供する。
 @author NTT DOCOMO
 @date 作成日(2014.6.23)
 */
#import <DConnectSDK/DConnectSDK.h>

/*!
 @class DPSpheroServiceDiscoveryProfile
 @brief SpheroデバイスプラグインのServiceDiscoveryProfile機能を提供する
 */
@interface DPSpheroServiceDiscoveryProfile : DConnectServiceDiscoveryProfile<DConnectServiceDiscoveryProfileDelegate>

@end
