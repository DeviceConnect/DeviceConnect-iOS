//
//  DPHitoeDevicePlugin.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeManager.h"

@interface DPHitoeDevicePlugin : DConnectDevicePlugin<DPHitoeConnectionDelegate>

@end
