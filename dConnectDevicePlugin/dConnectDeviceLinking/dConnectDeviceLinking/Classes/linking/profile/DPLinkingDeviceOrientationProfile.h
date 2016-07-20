//
//  DPLinkingDeviceOrientationProfile.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPLinkingSensorData.h"

@interface DPLinkingDeviceOrientationProfile : DConnectDeviceOrientationProfile

+ (void) updateSensorData:(DPLinkingSensorData *)sensor to:(DConnectMessage *)message;

@end
