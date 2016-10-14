//
//  DPIRKitLightProfile.h
//  dConnectDeviceIRKit
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectLightProfile.h>
#import "DPIRKitDevicePlugin.h"
@interface DPIRKitLightProfile : DConnectLightProfile
- (id) initWithDevicePlugin:(DPIRKitDevicePlugin *)plugin;
@end
