//
//  RESTfulFailDeviceOrientationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "RESTfulTestCase.h"

@interface RESTfulFailDeviceOrientationProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulFailDeviceOrientationProfileTest
 * @brief DeviceOrientationプロファイルの異常系テスト.
 */
@implementation RESTfulFailDeviceOrientationProfileTest

/*!
 * @brief serviceIdが無い状態でondeviceorientation属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /deviceorientation/ondeviceorientation
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でondeviceorientation属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /deviceorientation/ondeviceorientation?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでondeviceorientation属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /deviceorientation/ondeviceorientation?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでondeviceorientation属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /deviceorientation/ondeviceorientation?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationPutNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief serviceIdが無い状態でondeviceorientation属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /deviceorientation/ondeviceorientation
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でondeviceorientation属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /deviceorientation/ondeviceorientation?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでondeviceorientation属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /deviceorientation/ondeviceorientation?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでondeviceorientation属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /deviceorientation/ondeviceorientation?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationDeleteNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief メソッドをPOSTに指定して/deviceorientation/ondeviceorientationにアクセスするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /deviceorientation/ondeviceorientation?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailDeviceOrientationOnDeviceOrientationEventInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end
