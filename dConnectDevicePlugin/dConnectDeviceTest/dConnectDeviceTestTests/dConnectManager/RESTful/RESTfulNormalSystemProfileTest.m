//
//  RESTfulNormalSystemProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalSystemProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalSystemProfileTest
 * @brief Systemプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalSystemProfileTest

/*!
 * @brief デバイスのシステムプロファイルを取得する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /system
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・versionにString型の値が返ってくること。
 * ・supportsにJSONArray型の値が返ってくること。
 * ・pluginsにテスト用デバイスプラグインの情報が含まれていること。
 * </pre>
 */
- (void) testHttpNormalSystemGet
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/system"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

// MEMO: 下記のテストは手動で行う.
//- (void) testHttpNormalSystemDeviceWakeupPut
//{
//    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/system/device/wakeup?pluginId=DeviceTestPlugin%2Edconnect"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
//    [request setHTTPMethod:@"PUT"];
//
//    CHECK_RESPONSE(@"{\"result\":0}", request);
//}

@end
