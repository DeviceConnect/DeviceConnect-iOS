//
//  DPLinkingDeviceService.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectService.h>
#import "DPLinkingDeviceManager.h"

@interface DPLinkingDeviceService : DConnectService

- (instancetype) initWithDevice: (DPLinkingDevice *)device plugin:(DConnectDevicePlugin *)plugin;

@end
