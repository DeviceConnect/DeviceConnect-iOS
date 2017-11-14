//
//  RESTfulFailAuthorizationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

NSString *GRANT_TYPE = @"authorization_code";

@interface RESTfulFailAuthorizationProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailAuthorizationProfileTest
 * @brief Authorizationプロファイルの異常系テスト.
 */
@implementation RESTfulFailAuthorizationProfileTest

/*!
 * @brief
 * メソッドにPOSTを指定してクライアント作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /authorization/grant
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailCreateClientGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/authorization/grant"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief
 * メソッドにPUTを指定してクライアント作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /authorization/grant
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailCreateClientGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/authorization/grant"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief
 * メソッドにDELETEを指定してクライアント作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /authorization/grant
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailCreateClientGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/authorization/grant"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief
 * clientIdが無い状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?gscope=xxxx&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetNoClientId
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                      @"http://localhost:4035/gotapi/authorization/accesstoken?"
                      "scope=battery&applicationName=test"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * clientIdに空文字を指定した状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?clintId=&scope=xxxx&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetEmptyClientId
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                      @"http://localhost:4035/gotapi/authorization/accesstoken?"
                      "clientId=&scope=battery&applicationName=test"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * scopeが無い状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?clientId=xxxx&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetNoScope
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                            @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                "clientId=%@&applicationName=test",
                                    client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * scopeに空文字を指定した状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?
 *           clientId=xxxx&scope=&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetEmptyScope
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                                @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                    "clientId=%@&scope=&applicationName=test",
                                        client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * applicationNameが無い状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?clientId=xxxx&scope=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetNoApplicationName
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                            @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                 "clientId=%@&scope=battery",
                            client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * applicationに空文字を指定した状態でアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /authorization/accesstoken?
 *           clientId=xxxx&scope=xxxx&applicationName=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetEmptyApplicationName
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                            @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                "clientId=%@&scope=battery&applicationName=",
                                    client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"GET"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
    }];
}

/*!
 * @brief
 * メソッドにPOSTを指定してアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /authorization/accesstoken?
 *           clientId=xxxx&scope=xxxx&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetInvalidMethodPost
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                                @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                    "clientId=%@&scope=battery&applicationName=test",
                                        client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"POST"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
    }];
}

/*!
 * @brief
 * メソッドにPUTを指定してアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /authorization/accesstoken?
 *           clientId=xxxx&scope=xxxx&applicationName=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetInvalidMethodPut
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                            [NSString stringWithFormat:
                                    @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                        "clientId=%@&scope=battery&applicationName=test",
                                            client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"PUT"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
    }];
}

/*!
 * @brief
 * メソッドにDELETEを指定してアクセストークン作成を行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /authorization/accesstoken?
 *           clientId=xxxx&grantType=xxxx&scope=xxxx&applicationName=xxxxsignature=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailRequestAccessTokenGetInvalidMethodDelete
{
    [self createClientWithCompletion:^(NSArray *client) {
        XCTAssertNotNil(client);
        XCTAssertNotNil(client[0]);
        
        NSURL *uri = [NSURL URLWithString:
                        [NSString stringWithFormat:
                                @"http://localhost:4035/gotapi/authorization/accesstoken?"
                                    "clientId=%@&scope=battery&applicationName=test",
                                        client[0]]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
        [request setHTTPMethod:@"DELETE"];
        
        CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
    }];
}

@end
