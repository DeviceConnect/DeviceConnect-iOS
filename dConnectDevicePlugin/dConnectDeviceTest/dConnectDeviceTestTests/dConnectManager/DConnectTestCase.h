//
//  DConnectTestCase.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <XCTest/XCTest.h>
#import <DConnectSDK/DConnectSDK.h>
#import <DConnectSDK/DConnectUtil.h>
#import "AccessToken.h"

/*! dConnectManagerのホスト名. */
extern NSString *const DConnectHost;
/*! dConnectManagerのポート番号. */
extern int DConnectPort;

@interface DConnectTestCase : XCTestCase

/**
 * テスト用のデバイスプラグインのIDを保持する.
 */
@property (nonatomic) NSString *serviceId;

/**
 * テスト用のクライアントIDを保持する.
 */
@property (nonatomic) NSString *clientId;

- (void) createClientWithCompletion:(void (^)(NSArray* client))completion;


@end
