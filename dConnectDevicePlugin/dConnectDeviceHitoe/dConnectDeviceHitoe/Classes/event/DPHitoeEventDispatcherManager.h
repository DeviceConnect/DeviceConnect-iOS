//
//  DPHitoeEventDispatcherManager.h
//  dConnectDeviceHitoe
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>
#import "DPHitoeEventDispatcher.h"

@interface DPHitoeEventDispatcherManager : NSObject
- (void)addEventDispatcherForServiceId:(NSString *)serviceId dispatcher:(DPHitoeEventDispatcher*)dispatcher;
- (void)removeEventDispacherForServiceId:(NSString*)serviceId;
- (void)removeAllEventDispatcher;
- (BOOL)containsEventDispacherForServiceId:(NSString*)serviceId;
- (void)sendEventForServiceId:(NSString*)serviceId message:(DConnectMessage*)message;
@end
