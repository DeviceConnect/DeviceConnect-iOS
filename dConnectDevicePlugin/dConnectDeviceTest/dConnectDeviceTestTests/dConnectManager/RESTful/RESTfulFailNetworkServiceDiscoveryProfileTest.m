//
//  RESTfulFailServiceDiscoveryProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailServiceDiscoveryProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailServiceDiscoveryProfileTest
 * @brief Service Discovery プロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulFailServiceDiscoveryProfileTest

/*!
 * @brief POSTメソッドでデバイスの探索を行う.
 *
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /servicediscovery
 * </pre>
 *
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceDiscoveryGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief PUTメソッドでデバイスの探索を行う.
 *
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /servicediscovery
 * </pre>
 *
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceDiscoveryGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief DELETEメソッドでデバイスの探索を行う.
 *
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /servicediscovery
 * </pre>
 *
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceDiscoveryServicesGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end
