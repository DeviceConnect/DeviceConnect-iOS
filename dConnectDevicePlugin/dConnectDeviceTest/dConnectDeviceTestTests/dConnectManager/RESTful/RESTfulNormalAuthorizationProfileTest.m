//
//  RESTfulNormalAuthorizationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalAuthorizationProfileTest : RESTfulTestCase

@end

/*!
 @class RESTfulNormalAuthorizationProfileTest
 @brief RESTful Authorizationプロファイルの正常系テスト。
 */
@implementation RESTfulNormalAuthorizationProfileTest

/*!
 * @brief
 * クライアント作成テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/grant
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・clientIdにstring型の値が返ること。
 * ・clientSecretにstring型の値が返ること。
 * </pre>
 */
- (void) testHttpNormalCreateClient
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client[0], @"clientId must not be nil.");
    }];
}

/*!
 * @brief
 * クライアント作成済みのパッケージについてクライアントを作成し直すテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/grant
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・異なるclientIdが返ること。
 * ・異なるclientSecretが返ること。
 * </pre>
 */
- (void) testHttpNormalCreateClientOverwrite
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client[0], @"clientId must not be nil.");
        __block NSArray *oldClient = client;
         [self createClientWithCompletion:^(NSArray *client) {
             XCTAssertNotNil(client[0], @"clientId must not be nil.");
             XCTAssertNotEqual(oldClient[0], client[0]);
         }];
    }];
}

@end
