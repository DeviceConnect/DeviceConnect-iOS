//
//  RESTfuleNormalAllGetControlTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"


@interface RESTfulNormalAllGetControlTest : RESTfulTestCase

@end
/*!
 @class RESTfulNormalAllGetControlTest
 @brief RESTful 全てGETで操作する機能の正常系テスト。
 */
@implementation RESTfulNormalAllGetControlTest


/*!
 * @brief /profileのとき、methodにGETが指定されている時でも、正常にリクエストが処理されること。
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/allGetControl?serviceId=xxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testGetRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"PROFILE_OK\"}", request);
}

/*!
 * @brief /profile/attributeのとき、methodにGETが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 *
 */
- (void) testGetRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"ATTRIBUTE_OK\"}", request);
}

/*!
 * @brief /profile/interface/attributeのとき、methodにGETが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testGetRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"INTERFACE_OK\"}", request);
}


/*!
 * @brief /profileのとき、methodにPOSTが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testPostRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"PROFILE_OK\"}", request);
}

/*!
 * @brief /profile/attributeのとき、methodにPOSTが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 *
 */
- (void) testPostRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"ATTRIBUTE_OK\"}", request);
}

/*!
 * @brief /profile/interface/attributeのとき、methodにPOSTが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POSt/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testPostRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"INTERFACE_OK\"}", request);
}


/*!
 * @brief /profileのとき、methodにPUTが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testPutRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"PROFILE_OK\"}", request);
}

/*!
 * @brief /profile/attributeのとき、methodにPUTが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 *
 */
- (void) testPutRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"ATTRIBUTE_OK\"}", request);
}

/*!
 * @brief /profile/interface/attributeのとき、methodにGETが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testPutRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"INTERFACE_OK\"}", request);
}


/*!
 * @brief /profileのとき、methodにDELEteが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 *
 */
- (void) testDeleteRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"PROFILE_OK\"}", request);
}

/*!
 * @brief /profile/attributeのとき、methodにDELETEが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testDeleteRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"ATTRIBUTE_OK\"}", request);
}

/*!
 * @brief /profile/interface/attributeのとき、methodにDELETEが指定されている時でも、正常にリクエストが処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・デバイスプラグインで指定されているレスポンスがそのまま返されること
 * </pre>
 */
- (void) testDeleteRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"key\":\"INTERFACE_OK\"}", request);
}

@end
