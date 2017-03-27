//
//  RESTfulNormalConnectionProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalConnectionProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalConnectionProfileTest
 * @brief Connectプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalConnectionProfileTest

/*!
 * @brief WiFi機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connection/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionWifiGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief WiFi機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionWifiPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief WiFi機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionWifiDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief WiFi機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/wifichange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnWifiChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onwifichange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"connectStatus\":{\"enable\":true}}");
}

/*!
 * @brief WiFi機能有効状態変化イベントのコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/wifichange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnWifiChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onwifichange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief Bluetooth機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connection/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */- (void) testHttpNormalConnectionBluetoothGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief Bluetooth機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionBluetoothPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief Bluetooth機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionBluetoothDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief Bluetooth機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/bluetoothchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnBluetoothChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onbluetoothchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"connectStatus\":{\"enable\":true}}");
}

/*!
 * @brief Bluetooth機能有効状態変化イベントのコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/bluetoothchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnBluetoothChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onbluetoothchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief NFC機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connection/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionNfcGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief NFC機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionNfcPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief NFC機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionNfcDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief NFC機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/onnfcchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnNfcChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onnfcchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"connectStatus\":{\"enable\":true}}");
}

/*!
 * @brief NFC機能有効状態変化イベントのコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/onnfcchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnNfcChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onnfcchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief BLE機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connection/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionBleGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief BLE機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionBlePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief BLE機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionBleDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief BLE機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connection/onblechange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnBleChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onblechange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"connectStatus\":{\"enable\":true}}");
}

/*!
 * @brief BLE機能有効状態変化イベントのコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connection/onblechange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectionOnBleChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connection/onblechange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

@end
