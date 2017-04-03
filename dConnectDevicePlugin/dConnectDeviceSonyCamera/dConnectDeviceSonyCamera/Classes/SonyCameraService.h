//
//  SonyCameraService.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import "SampleLiveviewManager.h"
#import "SonyCameraRemoteApiUtil.h"

@interface SonyCameraService : DConnectService<DConnectServiceInformationProfileDataSource>

- (instancetype) initWithServiceId:(NSString *)serviceId
                        deviceName:(NSString *)deviceName
                            plugin:(id)plugin;

@end
