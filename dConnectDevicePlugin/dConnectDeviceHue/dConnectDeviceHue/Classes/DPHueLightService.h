//
//  DPHueLightService.h
//  dConnectDeviceHue
//
//  Copyright (c) 2018 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectService.h>
#import <DConnectSDK/DConnectFileManager.h>
#import <DConnectSDK/DConnectServiceInformationProfile.h>


@interface DPHueLightService : DConnectService<DConnectServiceInformationProfileDataSource>
- (instancetype) initWithBridgeKey: (NSString *) bridgeKey
                       bridgeValue: (NSString *) bridgeValue
                           lightId: (NSString *) lightId
                         lightName: (NSString *) lightName
                            plugin: (id) plugin;
@end
