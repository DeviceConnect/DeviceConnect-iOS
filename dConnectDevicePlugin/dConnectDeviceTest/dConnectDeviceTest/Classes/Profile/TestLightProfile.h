//
//  TestLightProfile.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectLightProfile.h>

@class DeviceTestPlugin;
@interface TestLightProfile : DConnectLightProfile<DConnectLightProfileDelegate>
@property (nonatomic, strong) DeviceTestPlugin *plugin;
- (id) initWithDevicePlugin:(DeviceTestPlugin *)plugin;


@end
