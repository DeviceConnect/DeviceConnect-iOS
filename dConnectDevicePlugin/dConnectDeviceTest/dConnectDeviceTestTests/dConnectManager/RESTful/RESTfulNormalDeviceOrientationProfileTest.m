//
//  RESTfulNormalDeviceOrientationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalDeviceOrientationProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalDeviceOrientationProfileTest
 * @brief DeviceOrientationプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalDeviceOrientationProfileTest

/*!
 * @brief メソッドをGETに指定して/deviceorientation/ondeviceorientationにアクセスするテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /deviceorientation/ondeviceorientation?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalDeviceOrientationOnDeviceOrientationGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"orientation\":{\"accelerationIncludingGravity\":{\"z\":0,\"y\":0,\"x\":0},\"interval\":0,\"acceleration\":{\"z\":0,\"y\":0,\"x\":0},\"rotationRate\":{\"gamma\":0,\"alpha\":0,\"beta\":0}}}", request);
}

/*!
 * @brief ondeviceorientationイベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /deviceorientation/ondeviceorientation?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・コールバック登録後にイベントを受信すること。
 * </pre>
 */
- (void) testHttpNormalDeviceOrientationOnDeviceOrientationPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"orientation\":{\"accelerationIncludingGravity\":{\"z\":0,\"y\":0,\"x\":0},\"interval\":0,\"acceleration\":{\"z\":0,\"y\":0,\"x\":0},\"rotationRate\":{\"gamma\":0,\"alpha\":0,\"beta\":0}}}");
}

/*!
 * @brief ondeviceorientationイベントのコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /deviceorientation/ondeviceorientation?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalDeviceOrientationOnDeviceOrientationDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/deviceorientation/ondeviceorientation?accessToken=%@&serviceId=%@", self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
