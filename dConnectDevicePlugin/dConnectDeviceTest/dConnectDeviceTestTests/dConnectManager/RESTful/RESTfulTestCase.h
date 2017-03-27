//
//  RESTfulTestCase.h
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectTestCase.h"
#import "Multipart.h"
#import "SRWebSocket.h"

//======================================================
// レスポンス・イベントのチェック用マクロ
//
// マクロとして定義した理由:
// 　テスト失敗の理由がテストメソッド毎に表示されるようにするため.
//------------------------------------------------------

#define DCONNECT_MANAGER_APP_NAME @"Device Connect Manager"
#define DCONNECT_MANAGER_VERSION_NAME @"2.0.0"

#define CHECK_RESPONSE(expectedJson, req) {\
    [req setValue:@"http://localhost:4035/" forHTTPHeaderField:@"X-GotAPI-Origin"]; \
    NSURLResponse *response = nil; \
    NSError *error = nil; \
    NSData *data = [NSURLConnection sendSynchronousRequest:req \
                                         returningResponse:&response \
                                                     error:&error]; \
    XCTAssertNotNil(data); \
    XCTAssertNil(error); \
    NSMutableDictionary *expectedResponse = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:[expectedJson dataUsingEncoding:NSUTF8StringEncoding] \
                                                                     options:NSJSONReadingMutableContainers \
                                                                       error:nil]]; \
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data \
                                                               options:NSJSONReadingMutableContainers \
                                                                 error:nil]; \
    NSLog(@"********** actualResponse: %@", actualResponse); \
    XCTAssertNotNil(actualResponse); \
    XCTAssertTrue([self assertDictionary:expectedResponse actual:actualResponse], "expected=%@, but actual=%@", expectedResponse, actualResponse); \
}

#define CHECK_EVENT(expectedJson) {\
    NSDictionary *expectedEvent = [NSJSONSerialization JSONObjectWithData:[expectedJson dataUsingEncoding:NSUTF8StringEncoding] \
                                                                  options:NSJSONReadingMutableContainers \
                                                                    error:nil]; \
    NSDictionary *actualEvent = [self waitForEvent]; \
    XCTAssertNotNil(actualEvent); \
    XCTAssertTrue([self assertDictionary:expectedEvent actual:actualEvent], "expected=%@, but actual=%@", expectedEvent, actualEvent); \
}

@interface RESTfulTestCase : DConnectTestCase <SRWebSocketDelegate>

/**
 * デバイスプラグインのIDを検索して、serviceIdに設定する.
 */
- (void) searchTestDevicePlugin;

/**
 * イベントを受信するために一定時間ブロックする.
 */
- (NSDictionary *) waitForEvent;

/**
 * JSONオブジェクトを比較する.
 */
- (BOOL) assertDictionary:(NSDictionary *)expectedObject actual:(NSDictionary *)actualObject;

#pragma mark - SRWebSocketDelegate

- (void) webSocketDidOpen:(SRWebSocket *)webSocket;
- (void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
- (void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
- (void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;

@end
