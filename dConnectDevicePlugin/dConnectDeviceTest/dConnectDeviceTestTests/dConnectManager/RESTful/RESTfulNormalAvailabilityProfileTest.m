//
//  RESTfulNormalAvailabilityProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalAvailabilityProfileTest : RESTfulTestCase

@end

/*!
 @class RESTfulNormalAvailabilityProfileTest
 @brief RESTful Availabilityプロファイルの正常系テスト。
 */
@implementation RESTfulNormalAvailabilityProfileTest

/*!
 * @brief サーバ起動確認テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /availability
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalAvailability
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/availability"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

@end