//
//  RESTfulFailSettingsProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulFailSettingsProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailSettingsProfileTest
 * @brief Settingsプロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulFailSettingsProfileTest

/*!
 * @brief serviceIdを指定せずに音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/sound/volume?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumeGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?kind=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/sound/volume?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumeGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?kind=1&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdで音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/sound/volume?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumeGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?kind=1&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief serviceIdを指定せずに音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/sound/volume?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?level=0.5&kind=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/sound/volume?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?level=0.5&kind=1&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdで音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/sound/volume?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/sound/volume?level=0.5&kind=1&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定して音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /settings/sound/volume?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumeInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/sound/volume?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して音量取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /settings/sound/volume?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsSoundVolumePutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/sound/volume?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/date?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDateGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/date?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDateGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdで日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/date?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDateGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief serviceIdを指定せずに日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/date?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDatePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/date?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDatePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdで日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/date?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDatePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/date?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定して日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /settings/date?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDateInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/date?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して日時取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /settings/date?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDateInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/date?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずにバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/light?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/light?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdでバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/light?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief serviceIdを指定せずにバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/light?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light?level=0.5"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/light?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light?level=0.5&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdでバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/light?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/light?level=0.5&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定してバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /settings/display/light?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/display/light?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定してバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /settings/display/light?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplayLightInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/display/light?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずにバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/sleep?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/sleep?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdでバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /settings/display/sleep?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief serviceIdを指定せずにバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/sleep?kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep?time=1"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/sleep?serviceId=&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep?time=1&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief 存在しないserviceIdでバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /settings/display/sleep?serviceId=123456789&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/settings/display/sleep?time=1&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定してバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /settings/display/sleep?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepPutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/display/sleep?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定してバックライト明度取得要求を送信するテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /settings/display/sleep?serviceId=xxxx&kind=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailSettingsDisplaySleepPutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/settings/display/sleep?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end
