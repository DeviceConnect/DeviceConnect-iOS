//
//  GHDeviceUtil.h
//  dConnectBrowserForIOS9
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import <Foundation/Foundation.h>
#import <DConnectSDK/DConnectSDK.h>

typedef void (^DiscoverDeviceCompletion)(DConnectArray *result);
typedef void (^RecieveDeviceList)(DConnectArray *deviceList);

@interface GHDeviceUtil : NSObject
@property (nonatomic, strong) DConnectArray* currentDevices;
@property (nonatomic, copy) RecieveDeviceList recieveDeviceList;
+ (GHDeviceUtil*)shareManager;
- (void)updateDeviceList;
- (void)discoverDevices:(DiscoverDeviceCompletion)completion;

@end
