//
//  DPHueServiceDiscoveryProfile.h
//  dConnectDeviceHue
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

/*! @file
 @brief Hue用 Service Discovery プロファイル。
 @author NTT DOCOMO
 @date 作成日(2014.7.15)
 */
#import <UIKit/UIKit.h>
#import <DConnectSDK/DConnectSDK.h>

/*!
 @class DPHueServiceDiscoveryProfile
 @brief Hue用 Service Discovery プロファイル。
 */
@interface DPHueServiceDiscoveryProfile: DConnectServiceDiscoveryProfile<DConnectServiceDiscoveryProfileDelegate>

@end
