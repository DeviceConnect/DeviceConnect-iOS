//
//  DConnectTestCase.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <XCTest/XCTest.h>
#import "TestDevicePlugin.h"
#import "DConnectURIBuilder.h"

/*! dConnectManagerのホスト名. */
extern NSString *const DConnectHost;
/*! dConnectManagerのポート番号. */
extern int DConnectPort;

@interface DConnectNormalTestCase : XCTestCase

/**
 * テスト用のデバイスプラグインのIDを保持する.
 */
@property (nonatomic) NSString *serviceId;

/**
 * デバイスプラグインのIDを検索して、serviceIdに設定する.
 */
- (void) searchTestDevicePlugin;

@end
