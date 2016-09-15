//
//  DPHitoeEventDispatcher.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

@interface DPHitoeEventDispatcher : NSObject

- (instancetype)initWithDevicePlugin:(DConnectDevicePlugin *)devicePlugin;
- (void)sendEventForMessge:(DConnectMessage *)message;
- (void)start;
- (void)stop;
- (void)sendEventInternalForMessage:(DConnectMessage *)message;

@end
