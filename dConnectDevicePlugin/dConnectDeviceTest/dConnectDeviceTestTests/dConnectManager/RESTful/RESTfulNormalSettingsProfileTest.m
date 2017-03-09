//
//  RESTfulNormalSettingProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalSettingProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalSettingProfileTest
 * @brief Settingプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalSettingProfileTest

/*!
 * @brief スマートデバイスの音量取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /setting/volume?serviceId=xxxx&kind=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・levelが0.5で返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsSoundVolumeGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/sound/volume?serviceId=%@&kind=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"level\":0.5}", request);
}

/*!
 * @brief スマートデバイスの音量設定テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /setting/volume?serviceId=xxxx&kind=1&level=xxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsSoundVolumePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/sound/volume?serviceId=%@&level=0.5&kind=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief スマートデバイスの日時取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /setting/date?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・dateが"2014-01-01T01:01:01+09:00"で返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDateGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/date?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"date\":\"2014-01-01T01:01:01+09:00\"}", request);
}

/*!
 * @brief スマートデバイスの日時設定テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /setting/date?serviceId=xxxx&date=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDatePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/date?serviceId=%@&date=2014-01-01T01:01:01+09:00", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief スマートデバイスのライト明度取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /setting/display/brightness?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・levelが50で返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDisplayLightGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/display/brightness?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"level\":0.5}", request);
}

/*!
 * @brief スマートデバイスのライト明度設定テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /setting/display/brightness?serviceId=xxxx&level=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDisplayLightPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/display/brightness?serviceId=%@&level=0.5", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief スマートデバイスのライト明度取得テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /setting/display/sleep?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・levelが50で返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDisplaySleepGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/display/sleep?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"time\":1}", request);
}

/*!
 * @brief スマートデバイスのライト明度設定テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /setting/display/sleep?serviceId=xxxx&kind=1&level=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalSettingsDisplaySleepPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/setting/display/sleep?serviceId=%@&time=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
