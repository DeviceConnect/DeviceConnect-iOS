//
//  RESTfulFailServiceInformationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailServiceInformationProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailServiceInformationProfileTest
 * @brief Service Informationプロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulFailServiceInformationProfileTest

/*!
 * @brief serviceIdを指定せずにデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /serviceinformation
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/serviceinformation"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdに空文字を指定してデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /serviceinformation?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/serviceinformation?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdを指定してデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /serviceinformation?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/serviceinformation?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief POSTメソッドでデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /serviceinformation?serviceId=123456789&serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/serviceinformation?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief PUTメソッドでデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /serviceinformation?serviceId=123456789&serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/serviceinformation?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief DELETEメソッドでデバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /serviceinformation?serviceId=123456789&serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailServiceInformationGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/serviceinformation?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end