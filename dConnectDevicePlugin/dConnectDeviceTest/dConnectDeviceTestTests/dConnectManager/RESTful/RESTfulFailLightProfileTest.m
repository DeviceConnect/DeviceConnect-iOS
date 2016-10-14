//
//  RESTfulFailLightProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailLightProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailLightProfileTest
 * @brief Lightプロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulFailLightProfileTest

/*!
 * @brief ライト一覧取得リクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}


/*!
 * @brief ライト一覧取得リクエストをserviceIdを空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライト一覧取得リクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light?serviceId=12345678"
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトを点灯させるリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light?lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPostNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトを点灯させるリクエストをserviceIdを空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light?serviceId=&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPostEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトを点灯させるリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light?serviceId=&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPostInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=12345678&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトをステータスを変更するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light?lightId=1&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?lightId=1&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトをステータスを変更するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light?serviceId=&lightId=1&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=&lightId=1&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトをステータスを変更するリクエストをs存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light?serviceId=12345678&lightId=1&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=12345678&lightId=1&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトを消灯するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light?lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトを消灯するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light?serviceId=&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトを消灯するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light?serviceId=12345678&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailLightDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light?serviceId=12345678&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


@end
