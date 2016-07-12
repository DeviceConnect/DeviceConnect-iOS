//
//  DPHostServiceDiscoveryProfile.h
//  dConnectDeviceHost
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectServiceDiscoveryProfile.h>
#import <DConnectSDK/DConnectFileManager.h>

extern NSString *const ServiceDiscoveryServiceId;

@interface DPHostServiceDiscoveryProfile : DConnectServiceDiscoveryProfile<DConnectServiceDiscoveryProfileDelegate>

/// このデバイスプラグイン用のファイル管理用オブジェクト
@property DConnectFileManager *fileMgr;

- (instancetype)initWithFileManager:(DConnectFileManager *)fileMgr;

@end
