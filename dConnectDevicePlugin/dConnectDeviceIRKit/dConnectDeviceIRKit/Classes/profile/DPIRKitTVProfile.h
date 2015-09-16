//
//  DPIRKitTVProfile.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <DCMDevicePluginSDK/DCMDevicePluginSDK.h>
#import "DPIRKitDevicePlugin.h"
@interface DPIRKitTVProfile : DCMTVProfile<DCMTVProfileDelegate>
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin;
@end
