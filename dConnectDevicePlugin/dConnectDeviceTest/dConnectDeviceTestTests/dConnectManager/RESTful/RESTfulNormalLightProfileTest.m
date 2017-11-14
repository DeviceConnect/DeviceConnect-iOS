//
//  RESTfulNormalLightProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalLightProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalLightProfileTest
 * @brief Lightプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalLightProfileTest

/*!
 * @brief ライト一覧取得リクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light?serviceId=xxxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・lightsに少なくとも1つ以上のライトが発見されること。
 * ・lightsの中に「照明」のnameを持ったライトが存在すること。
 * </pre>
 */
- (void) testHttpNormalLightGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[session dataTaskWithRequest:request  completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNotNil(data);
        XCTAssertNil(error);
        NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:NSJSONReadingMutableContainers
                                                                         error:nil];
        XCTAssertNotNil(actualResponse);
        
        NSArray *lights = actualResponse[DConnectLightProfileParamLights];
        XCTAssertTrue(lights.count > 0);
        BOOL found = NO;
        for (NSDictionary *light in lights) {
            NSString *lightName = light[DConnectLightProfileParamName];
            if ([lightName isEqualToString:@"照明"]) {
                found = YES;
                break;
            }
        }
        XCTAssertTrue(found == YES);
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
}

/*!
 * @brief ライトを点灯させるリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light?serviceId=xxxxx&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light?serviceId=%@&lightId=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ライトをステータスを変更するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light?serviceId=xxxxx&lightId=1&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light?serviceId=%@&lightId=1&name=room", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ライトを消灯するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light?serviceId=xxxxx&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light?serviceId=%@&lightId=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
