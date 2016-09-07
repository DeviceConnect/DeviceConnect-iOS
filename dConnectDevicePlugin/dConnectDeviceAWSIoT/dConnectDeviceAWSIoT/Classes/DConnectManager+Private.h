//
//  DConnectManager+Private.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "DConnectDevicePluginManager.h"

@interface DConnectManager ()

@property (nonatomic) DConnectDevicePluginManager *mDeviceManager;

- (DConnectProfile *) profileWithName:(NSString *)name;

@end
