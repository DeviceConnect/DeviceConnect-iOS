//
//  RESTfulNormalFileProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalFileProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalFileProfileTest
 * @brief Fileプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalFileProfileTest

/*!
 * @brief ファイルの送信を行う.
 * <pre>
 * Method: POST
 * Path: /file?serviceId=xxxx&filename=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalFileSendPost
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/file?serviceId=%@&path=%%2Ftest%%2Ftest%%2Epng",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    Multipart* multi = [Multipart new];
    [multi addData:[@"test_media" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data"];
    [request setValue:multi.contentType forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:multi.body];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 0byteのファイルの送信を行う.
 * <pre>
 * Method: POST
 * Path: /file?serviceId=xxxx&filename=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalFileSendPostZeroByte
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/file?serviceId=%@&path=%%2Ftest%%2Fzero%%2Edat",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    Multipart* multi = [Multipart new];
    [multi addData:[NSData data] forKey:@"data"];
    [request setValue:multi.contentType forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:multi.body];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ファイル受信テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /file?serviceId=xxxx&mediaid=xxxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalFileReceiveGet
{
    [self testHttpNormalFileSendPost];
    
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/file?serviceId=%@&path=%%2Ftest%%2Ftest%%2Epng",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.devicecconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    NSString *expectedJson = @"{\"result\":0,\"mimeType\":\"image/png\"}";
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    NSDictionary *expectedResponse = [NSJSONSerialization JSONObjectWithData:
                                      [expectedJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    XCTAssertNotNil(actualResponse);
    XCTAssertTrue([self assertDictionary:expectedResponse actual:actualResponse],
                  "expected=%@, but actual=%@", expectedResponse, actualResponse);
    
    // uriのチェック
    NSString *paramUri = actualResponse[@"uri"];
    XCTAssertNotNil(paramUri);
    XCTAssertTrue([paramUri hasPrefix:@"http://localhost:4035/gotapi/files?uri="], @"Invalid uri: %@", paramUri);
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: paramUri]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.devicecconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    data = [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:&response
                                             error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
}

/*!
 * @brief 0byteのファイル受信テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /file?serviceId=xxxx&mediaid=xxxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalFileReceiveGetZeroByte
{
    [self testHttpNormalFileSendPostZeroByte];
    
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                    @"http://localhost:4035/gotapi/file?serviceId=%@&path=%%2Ftest%%2Fzero%%2Edat",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.devicecconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    NSString *expectedJson = @"{\"result\":0}";
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    NSDictionary *expectedResponse = [NSJSONSerialization JSONObjectWithData:
                                      [expectedJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    XCTAssertNotNil(actualResponse);
    XCTAssertTrue([self assertDictionary:expectedResponse actual:actualResponse],
                  "expected=%@, but actual=%@", expectedResponse, actualResponse);
    
    // uriのチェック
    NSString *paramUri = actualResponse[@"uri"];
    XCTAssertNotNil(paramUri);
    XCTAssertTrue([paramUri hasPrefix:@"http://localhost:4035/gotapi/files?uri="], @"Invalid uri: %@", paramUri);
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: paramUri]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.devicecconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    data = [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:&response
                                             error:&error];
    
    XCTAssertNotNil(data);
    XCTAssertEqual(0, data.length);
    XCTAssertNil(error);
}

/*!
 * @brief ファイル一覧取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /file/list?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・
 * </pre>
 */
- (void) testHttpNormalFileListGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/file/list?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"files\":[{\"fileSize\":64000,\"fileType\":0,\"fileName\":\"test.png\","
                   "\"path\":\"/test.png\",\"mimeType\":\"image/png\"}],\"result\":0,\"count\":1}",
                   request);
}

/*!
 * @brief ファイルの削除を行う.
 * <pre>
 * Method: Delete
 * Path: /file/remove?serviceId=xxxx&filename=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalFileRemoveDelete
{
    // あとで削除するためのファイルを送信しておく.
    [self testHttpNormalFileSendPost];
    
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/file?"
                   "serviceId=%@&path=%%2Ftest%%2Ftest%%2Epng", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
