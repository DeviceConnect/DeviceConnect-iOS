//
//  RESTfulFailAllGetControlTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailAllGetControlTest : RESTfulTestCase

@end

@implementation RESTfulFailAllGetControlTest

#pragma mark - POST invalid test
/*!
 * @brief HTTPメソッドがPOSTで、/profileのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /GET/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostGetRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/attributeのとき、methodにGETが指定されている時に、エラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /GET/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostGetRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /GET/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostGetRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profileのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /POST/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPostRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、 /profile/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /POST/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPostRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/interface/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /POST/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPostRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}


/*!
 * @brief HTTPメソッドがPOSTで、/profileのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /PUT/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPutRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/attributeのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /PUT/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPutRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、 /profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /PUT/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostPutRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @briefHTTPメソッドがPOSTで、 /profileのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /DELETE/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostDeleteRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /DELETE/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostDeleteRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPOSTで、/profile/interface/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /DELETE/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPostDeleteRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

#pragma mark - PUT invalid test
/*!
 * @brief HTTPメソッドがPUTで、/profileのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /GET/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutGetRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/attributeのとき、methodにGETが指定されている時に、エラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /GET/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutGetRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /GET/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutGetRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profileのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /POST/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPostRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、 /profile/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /POST/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPostRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/interface/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /POST/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPostRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}


/*!
 * @brief HTTPメソッドがPUTで、/profileのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /PUT/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPutRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/attributeのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /PUT/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPutRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、 /profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /PUT/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutPutRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、 /profileのとき、methodにDELEteが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /DELETE/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutDeleteRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /DELETE/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutDeleteRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがPUTで、/profile/interface/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /DELETE/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodPutDeleteRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}


#pragma mark - DELETE invalid test
/*!
 * @brief HTTPメソッドがDELETEで、/profileのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /GET/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteGetRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/attributeのとき、methodにGETが指定されている時に、エラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /GET/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteGetRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /GET/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteGetRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profileのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /POST/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePostRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、 /profile/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /POST/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePostRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/interface/attributeのとき、methodにPOSTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /POST/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePostRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}


/*!
 * @brief HTTPメソッドがDELETEで、/profileのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /PUT/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePutRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/attributeのとき、methodにPUTが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /PUT/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePutRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、 /profile/interface/attributeのとき、methodにGETが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /PUT/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeletePutRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、 /profileのとき、methodにDELEteが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /DELETE/allGetControl?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteDeleteRequestProfile
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /DELETE/allGetControl/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteDeleteRequestProfileAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}

/*!
 * @brief HTTPメソッドがDELETEで、/profile/interface/attributeのとき、methodにDELETEが指定されている時にエラー処理されること.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /DELETE/allGetControl/test/ping?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid urlエラーが返って来ること。
 * </pre>
 */
- (void) testHttpMethodDeleteDeleteRequestProfileInterfaceAttribute
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/allGetControl/test/ping?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":19}", request);
}


#pragma mark - Method指定時にProfileにHttpメソッドが指定されている
/*!
 * @brief methodが指定されていない時、profile名にGETが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodGetByNormal
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodが指定されていない時、profile名にPOSTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPostByNormal
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodが指定されていない時、profile名にPUTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPutByNormal
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodが指定されていない時、profile名にDELETEが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodDeleteByNormal
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}


#pragma mark - Method指定時にProfileにHttpメソッドが指定されている
/*!
 * @brief methodがGETで指定されている時、profile名にGETが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/GET?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodGetGetByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/GET?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @briefmethodがGETで指定されている時、profile名にGETが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/POST?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodGetPostByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/POST?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にGETが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/PUT?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodGetPutByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/PUT?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にGETが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /GET/DELETE?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodGetDeleteByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/GET/DELETE?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}


/*!
 * @brief methodがGETで指定されている時、profile名にPOSTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/GET?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPostGetByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/GET?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief  methodがGETで指定されている時、profile名にPOSTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/POST?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPostPostByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/POST?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPOSTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/PUT?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPostPutByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/PUT?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPOSTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /POST/DELETE?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPostDeleteByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/POST/DELETE?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPUTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/GET?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPutGetByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/GET?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPUTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/POST?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPutPostByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/POST?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPUTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/PUT?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPutPutByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/PUT?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にPUTが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /PUT/DELETE?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodPutDeleteByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/PUT/DELETE?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}


/*!
 * @brief methodがGETで指定されている時、profile名にDELETEが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/GET?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodDeleteGetByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/GET?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にDELETEが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/POST?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodDeletePostByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/POST?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にDELETEが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/PUT?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodDeletePutByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/PUT?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}

/*!
 * @brief methodがGETで指定されている時、profile名にDELETEが指定されている場合はエラー処理する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /DELETE/DELETE?serviceId&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * ・Invalid profileエラーが返って来ること。
 * </pre>
 */
- (void) testProfileHttpMethodDeleteByAllGetControl
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/DELETE/DELETE?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":20}", request);
}


@end
