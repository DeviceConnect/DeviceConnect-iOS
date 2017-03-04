//
//  RESTfulNormalConnectProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalConnectProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalConnectProfileTest
 * @brief Connectプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalConnectProfileTest

/*!
 * @brief WiFi機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connect/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectWifiGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief WiFi機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectWifiPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief WiFi機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connect/wifi?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectWifiDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/wifi?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief WiFi機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/wifichange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnWifiChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onwifichange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
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
 * Path: /connect/wifichange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnWifiChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onwifichange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief Bluetooth機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connect/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */- (void) testHttpNormalConnectBluetoothGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief Bluetooth機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectBluetoothPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief Bluetooth機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connect/bluetooth?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectBluetoothDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/bluetooth?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief Bluetooth機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/bluetoothchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnBluetoothChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onbluetoothchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
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
 * Path: /connect/bluetoothchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnBluetoothChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onbluetoothchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief NFC機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connect/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectNfcGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief NFC機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectNfcPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief NFC機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connect/nfc?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectNfcDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/nfc?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief NFC機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/onnfcchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnNfcChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onnfcchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
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
 * Path: /connect/onnfcchange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnNfcChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onnfcchange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

/*!
 * @brief BLE機能有効状態(ON/OFF)取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /connect/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * ・powerがtrueで返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectBleGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"enable\":true}", request);
}

/*!
 * @brief BLE機能有効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectBlePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief BLE機能無効化テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /connect/ble?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectBleDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/ble?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief BLE機能有効状態変化イベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /connect/onblechange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnBleChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onblechange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
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
 * Path: /connect/onblechange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultが0で返ってくること。
 * </pre>
 */
- (void) testHttpNormalConnectOnBleChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/connect/onblechange?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

@end
