//
//  DPLinkingDeviceSensorHolder.h
//  dConnectDeviceLinking
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPLinkingDeviceManager.h"

@interface DPLinkingDeviceSensorHolder : NSObject

@property (nonatomic) DPLinkingDevice *device;
@property (nonatomic) DConnectMessage *orientation;

- (instancetype) initWithDevice:(DPLinkingDevice *)device;

- (BOOL) isFlag;
- (void) clearFlag;
- (void) setSensorData:(DPLinkingSensorData *)data;

@end
