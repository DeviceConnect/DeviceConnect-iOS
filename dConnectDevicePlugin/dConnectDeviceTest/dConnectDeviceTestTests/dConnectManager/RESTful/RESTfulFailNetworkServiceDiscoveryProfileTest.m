//
//  RESTfulFailServiceDiscoveryProfileTest.m
//  DConnectSDK
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
 * @brief POSTメソッドでgetnetworkservicesでデバイスの探索を行う.
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
- (void) testHttpFailServiceDiscoveryGetNetworkServicesGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief PUTメソッドでgetnetworkservicesでデバイスの探索を行う.
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
- (void) testHttpFailServiceDiscoveryGetNetworkServicesGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":8}", request);
}

/*!
 * @brief DELETEメソッドでgetnetworkservicesでデバイスの探索を行う.
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
- (void) testHttpFailServiceDiscoveryGetNetworkServicesGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":8}", request);
}

@end
