//
//  DeviceTestPlugin.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>

@interface DeviceTestPlugin : DConnectDevicePlugin

@property (nonatomic, strong) DConnectFileManager * fm;

- (void) asyncSendEvent:(DConnectMessage *)event;
- (void) asyncSendEvent:(DConnectMessage *)event delay:(NSTimeInterval)delay;

@end
