//
//  RESTfulNormalPhoneProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalPhoneProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalPhoneProfileTest
 * @brief Phoneプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalPhoneProfileTest

/*!
 * @brief 電話発信要求テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /phone/call?serviceId=xxxx&mediaid=yyyy
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalPhoneCallPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/phone/call?serviceId=%@&phoneNumber=090xxxxxxxx", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 電話に関する設定項目(サイレント・マナー・音あり)の設定テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /phone/set?serviceId=xxxx&mode=0
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalPhoneSetPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/phone/set?serviceId=%@&mode=0", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 通話関連イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /phone/onconnect?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalPhoneOnConnectPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/phone/onconnect?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"phoneStatus\":{\"phoneNumber\":\"090xxxxxxxx\",\"state\":2}}");
}

/*!
 * @brief 通話関連イベントのコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /phone/onconnect?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalPhoneOnConnectDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/phone/onconnect?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
