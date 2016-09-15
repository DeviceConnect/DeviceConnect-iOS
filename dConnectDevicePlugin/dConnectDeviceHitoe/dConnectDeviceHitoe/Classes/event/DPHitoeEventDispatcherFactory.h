//
//  DPHitoeEventDispatcherFactory.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeEventDispatcher.h"
#import "DPHitoeImmediateEventDispatcher.h"
#import "DPHitoeIntervalEventDispatcher.h"

@interface DPHitoeEventDispatcherFactory : NSObject

+ (DPHitoeEventDispatcher*)createEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin
                                                        request:(DConnectRequestMessage*)request;
+ (DPHitoeEventDispatcher*)createIntervalEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin
                                                             periodTime:(int)periodTime;
+ (DPHitoeEventDispatcher*)createImmediateEventDispatcherForDevicePlugin:(DConnectDevicePlugin*)devicePlugin;

@end
