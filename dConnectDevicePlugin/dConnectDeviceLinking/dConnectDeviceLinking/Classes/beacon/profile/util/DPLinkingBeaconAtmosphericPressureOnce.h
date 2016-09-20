//
//  DPLinkingBeaconAtmosphericPressureOnce.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

#import "DPLinkingTimeoutSchedule.h"
#import "DPLinkingBeaconManager.h"

@interface DPLinkingBeaconAtmosphericPressureOnce : DPLinkingTimeoutSchedule <DPLinkingBeaconAtmosphericPressureDelegate>

@property (nonatomic) DConnectRequestMessage *request;
@property (nonatomic) DConnectResponseMessage *response;

- (instancetype) initWithBeacon:(DPLinkingBeacon *)beacon;

@end
