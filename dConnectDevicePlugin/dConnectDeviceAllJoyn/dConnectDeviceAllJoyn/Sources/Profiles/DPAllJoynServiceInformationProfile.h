//
//  DPAllJoynServiceInformationProfile.h
//  dConnectDeviceAllJoyn
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DPAllJoynHandler.h"


@interface DPAllJoynServiceInformationProfile : DConnectServiceInformationProfile

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithProvider:(id<DConnectProfileProvider>)provider
                         handler:(DPAllJoynHandler *)handler
                         version:(NSString *)version NS_DESIGNATED_INITIALIZER;

@end
