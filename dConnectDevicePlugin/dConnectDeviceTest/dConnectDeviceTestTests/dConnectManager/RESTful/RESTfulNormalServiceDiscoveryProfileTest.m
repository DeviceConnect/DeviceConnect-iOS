//
//  RESTfulNormalServiceDiscoveryProfileTest.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalServiceDiscoveryProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalServiceDiscoveryProfileTest
 * @brief Service Discoveryプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalServiceDiscoveryProfileTest

/*!
 * @brief デバイス一覧取得リクエストを送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /servicediscovery
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・servicesに少なくとも1つ以上のサービスが発見されること。
 * ・servicesの中に「Test Success Device」のnameを持ったサービスが存在すること。
 * </pre>
 */
- (void) testHttpNormalServiceDiscoveryGetNetworkServicesGet
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
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
    
    NSArray *services = [actualResponse objectForKey:DConnectServiceDiscoveryProfileParamServices];
    XCTAssertTrue(services.count > 0);
    BOOL found = NO;
    for (NSDictionary *service in services) {
        NSString *deviceName = [service objectForKey:DConnectServiceDiscoveryProfileParamName];
        if ([deviceName isEqualToString:@"Test Success Device"]) {
            found = YES;
            break;
        }
    }
    XCTAssertTrue(found == YES);
}

/*!
 * @brief デバイス検知イベントのテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT and DELETE
 * Path: /servicediscovery/onservicechange
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * ・「Test Success Device」のnameを持ったサービスの通知をうけること。
 * </pre>
 */
- (void) testHttpNormalServiceDiscoveryOnServiceChangeEvent
{
    // イベント登録
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/servicediscovery/onservicechange?sessionKey=%@", self.clientId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
    // テスト用イベント送信要求
    uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/event?serviceId=%@&sessionKey=%@", self.serviceId, self.clientId]];
    request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
    // 受信したイベントのチェック
    CHECK_EVENT(@"{\"profile\":\"servicediscovery\",\"attribute\":\"onservicechange\",\"sessionKey\":\"test_client\",\"networkService\":{\"id\":\"test_service_id.DeviceTestPlugin.dconnect\",\"name\":\"Test Success Device\",\"online\":true,\"state\":true,\"type\":\"TEST\",\"config\":\"test config\"}}");
    
    // イベント登録解除
    uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/servicediscovery/onservicechange?sessionKey=%@", self.clientId]];
    request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end
