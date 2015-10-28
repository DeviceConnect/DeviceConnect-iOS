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


/*!
 * @brief ライトグループ一覧取得リクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトグループ一覧取得リクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトグループ一覧取得リクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group?serviceId=12345678
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトグループを点灯させるリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group?groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupPostNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}


/*!
 * @brief ライトグループを点灯させるリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group?serviceId=&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupPostEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=&groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトグループを点灯させるリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group?serviceId=12345678&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupPostInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=12345678&groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトグループのステータスを変更するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group?groupId=2&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?groupId=2&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトグループのステータスを変更するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group?serviceId=&groupId=2&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=&groupId=2&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトグループのステータスを変更するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group?serviceId=12345678&groupId=2&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=12345678&groupId=2&name=room"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}



/*!
 * @brief ライトグループを消灯するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group?lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトグループを消灯するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group?serviceId=&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトグループを消灯するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group?serviceId=12345678&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group?serviceId=12345678&lightId=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}


/*!
 * @brief ライトグループを作成するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group/create?groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupCreatePostNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/create?groupIds=1,2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}


/*!
 * @brief ライトグループを作成するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group/create?serviceId=&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePostEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/create?groupIds=1,2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトグループを作成するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group/create?serviceId=12345678&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePostInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/create?serviceId=12345678&groupIds=1,2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief GETメソッドでライトグループを作成するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group/create?serviceId=xxxxx&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePostInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/create?serviceId=%@&groupIds=1,2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}


/*!
 * @brief PUTメソッドでライトグループを作成するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group/create?serviceId=xxxxx&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePostInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/create?serviceId=%@&groupIds=1,2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}

/*!
 * @brief DELETEメソッドでライトグループを作成するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group/create?serviceId=xxxxx&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePostInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/create?serviceId=%@&groupIds=1,2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}

/*!
 * @brief ライトグループを削除するリクエストをserviceIdを指定せずに送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group/clear?groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupClearDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/clear?groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief ライトグループを削除するリクエストをserviceIdに空文字を指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group/clear?serviceId=&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupClearDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/clear?serviceId=&groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief ライトグループを削除するリクエストを存在しないserviceIdを指定して送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group/clear?serviceId=12345678&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupClearDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/light/group/clear?serviceId=12345678&groupId=2"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief GETメソッドでライトグループを削除するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group/clear?serviceId=xxxxx&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupClearDeleteInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/clear?serviceId=%@&groupId=2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}

/*!
 * @brief POSTメソッドでライトグループを削除するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group/clear?serviceId=xxxxx&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupClearDeleteInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/clear?serviceId=%@&groupId=2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}


/*!
 * @brief PUTメソッドでライトグループを削除するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group/clear?serviceId=xxxxx&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupClearDeleteInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/clear?serviceId=%@&groupId=2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":4}", request);
}


@end
