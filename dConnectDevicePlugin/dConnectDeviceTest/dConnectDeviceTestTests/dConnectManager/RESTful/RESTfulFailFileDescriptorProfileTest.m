//
//  RESTfulFailFileDescriptorProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailFileDescriptorProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailFileDescriptorProfileTest
 * @brief FileDescriptorプロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulFailFileDescriptorProfileTest

/*!
 * @brief serviceIdが無い状態でファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/open?mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/open?flag=r&path=/test/test.png"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/open?serviceId=&mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/open?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/open?serviceId=123456789&mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/open?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定してファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /fileDescriptor/open?serviceId=xxxx&mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/open?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPUTを指定してファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/open?serviceId=xxxx&mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/open?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief メソッドにDELETEを指定してファイルをオープンするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/open?serviceId=xxxx&mediaId=xxxx&flag=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOpenGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/open?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief serviceIdが無い状態でファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/close?mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/close?path=/test/test.png"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/close?serviceId=&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/close?path=/test/test.png&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/close?serviceId=123456789&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/close?path=/test/test.png&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定してファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/close?serviceId=xxxx&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/close?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief メソッドにPOSTを指定してファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /fileDescriptor/close?serviceId=xxxx&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/close?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定してファイルをクローズするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/close?serviceId=xxxx&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorClosePutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/close?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief serviceIdが無い状態でファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/read?mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/read?length=1&path=/test/test.png"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/read?serviceId=&mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/read?length=1&path=/test/test.png&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/read?serviceId=123456789&mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/read?length=1&path=/test/test.png&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定してファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /fileDescriptor/read?serviceId=xxxx&mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/read?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPUTを指定してファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/read?serviceId=xxxx&mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/read?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief メソッドにDELETEを指定してファイルから読み込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/read?serviceId=xxxx&mediaId=xxxx&length=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorReadGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/read?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief serviceIdが無い状態でファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/write?mediaId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/write"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/write?serviceId=&mediaId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/write?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/write?serviceId=123456789&mediId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/write?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定してファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/write?serviceId=xxxx&mediaId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/write?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief メソッドにPOSTを指定してファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /fileDescriptor/write?serviceId=xxxx&mediaId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/write?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定してファイルに書き込むテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/write?serviceId=xxxx&mediaId=xxxx
 * Multipart: media
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorWritePutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/write?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief serviceIdが無い状態でonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/onwatchfile?sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFilePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/onwatchfile?serviceId=&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFilePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/onwatchfile?serviceId=123456789&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFilePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief sessionKey無しでonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /fileDescriptor/onwatchfile?serviceId=123456789&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFilePutNoSessionKey
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
}

/*!
 * @brief serviceIdが無い状態でonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/onwatchfile?sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/onwatchfile?serviceId=&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/onwatchfile?serviceId=123456789&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief sessionKey無しでonwatchfile属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /fileDescriptor/onwatchfile?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileDeleteNoSessionKey
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":10}", request);
}

/*!
 * @brief メソッドにGETを指定してonwatchfile属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /fileDescriptor/onwatchfile?serviceId=xxxx&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":2}", request);
}

/*!
 * @brief メソッドにPOSTを指定してonwatchfile属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /fileDescriptor/onwatchfile?serviceId=xxxx&sessionKey=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailFileDescriptorOnWatchFileInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/fileDescriptor/onwatchfile?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end
