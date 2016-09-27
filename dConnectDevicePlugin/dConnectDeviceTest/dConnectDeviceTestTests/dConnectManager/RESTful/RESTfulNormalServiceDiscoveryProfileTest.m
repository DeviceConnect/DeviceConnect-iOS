//
//  RESTfulNormalServiceDiscoveryProfileTest.m
//  dConnectDeviceTest
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
- (void) testHttpNormalServiceDiscoveryGet
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/servicediscovery"];
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
    
    NSArray *services = actualResponse[DConnectServiceDiscoveryProfileParamServices];
    XCTAssertTrue(services.count > 0);
    BOOL found = NO;
    for (NSDictionary *service in services) {
        NSString *deviceName = service[DConnectServiceDiscoveryProfileParamName];
        if ([deviceName isEqualToString:@"Test Success Device"]) {
            found = YES;
            break;
        }
    }
    XCTAssertTrue(found == YES);
}

@end
