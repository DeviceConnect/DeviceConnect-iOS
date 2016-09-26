//
//  DPLinkingBeaconService.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectService.h>
#import "DPLinkingBeaconManager.h"

@interface DPLinkingBeaconService : DConnectService

@property (nonatomic) DPLinkingBeacon *beacon;

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon plugin:(DConnectDevicePlugin *)plugin;

@end
