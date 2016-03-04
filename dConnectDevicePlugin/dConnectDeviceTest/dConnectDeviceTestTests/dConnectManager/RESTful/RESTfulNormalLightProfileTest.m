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
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
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


/*!
 * @brief ライトグループ一覧取得リクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /light/group?serviceId=xxxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・lightGroupsに少なくとも1つ以上のライトグループが発見されること。
 * ・lightGroupsの中に「リビング」のnameを持ったライトグループが存在すること。
 * </pre>
 */
- (void) testHttpNormalLightGroupGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"org.deviceconnect.test" forHTTPHeaderField:@"X-GotAPI-Origin"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request
                                         returningResponse:&response
                                                     error:&error];
    XCTAssertNotNil(data);
    XCTAssertNil(error);
    NSDictionary *actualResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    XCTAssertNotNil(actualResponse);
    NSArray *groups = actualResponse[DConnectLightProfileParamLightGroups];
    XCTAssertTrue(groups.count > 0);
    BOOL found = NO;
    for (NSDictionary *group in groups) {
        NSString *groupName = group[DConnectLightProfileParamName];
        if ([groupName isEqualToString:@"リビング"]) {
            found = YES;
            break;
        }
    }
    XCTAssertTrue(found == YES);
}

/*!
 * @brief ライトグループを点灯させるリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group?serviceId=xxxxx&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group?serviceId=%@&groupId=2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ライトグループのステータスを変更するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /light/group?serviceId=xxxxx&groupId=2&name=room
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group?serviceId=%@&groupId=2&name=room", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ライトグループを消灯するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group?serviceId=xxxxx&lightId=1
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group?serviceId=%@&lightId=1", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ライトグループを作成するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /light/group/create?serviceId=xxxx&groupIds=1,2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・groupId、2が返ってくること。
 * </pre>
 */
- (void) testHttpNormalLightGroupCreatePost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/create?serviceId=%@&groupIds=1,2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    
    CHECK_RESPONSE(@"{\"result\":0, \"groupId\":\"2\"}", request);
}


/*!
 * @brief ライトグループを削除するリクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /light/group/clear?serviceId=xxxxx&groupId=2
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */- (void) testHttpNormalLightGroupClearDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/light/group/clear?serviceId=%@&groupId=2", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
