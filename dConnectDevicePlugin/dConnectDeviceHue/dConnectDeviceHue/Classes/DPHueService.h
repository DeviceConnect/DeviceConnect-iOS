//
//  DPHueService.h
//  dConnectDeviceHue
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectFileManager.h>

@interface DPHueService : DConnectService

- (instancetype) initWithBridgeKey: (NSString *) bridgeKey
                       bridgeValue: (NSString *) bridgeValue;

@end
