//
//  RESTfulNormalServiceInformationProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalServiceInformationProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalServiceInformationProfileTest
 * @brief Service Informationプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalServiceInformationProfileTest

/*!
 * @brief デバイスのシステム情報を取得する.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /serviceinformation?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalServiceInformationGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/serviceinformation?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    NSMutableDictionary *connect = [NSMutableDictionary dictionary];
    connect[DConnectServiceInformationProfileParamWiFi] = [NSNumber numberWithBool:NO];
    connect[DConnectServiceInformationProfileParamBluetooth] = [NSNumber numberWithBool:NO];
    connect[DConnectServiceInformationProfileParamNFC] = [NSNumber numberWithBool:NO];
    connect[DConnectServiceInformationProfileParamBLE] = [NSNumber numberWithBool:NO];
    NSMutableString *paramConnect = [NSMutableString string];
    [paramConnect appendString:@"{"];
    int i = (int) connect.count;
    for (NSString *key in connect) {
        [paramConnect appendString:[NSString stringWithFormat:@"\"%@\"", key]];
        [paramConnect appendString:@": "];
        [paramConnect appendString:[NSString stringWithFormat:@"\"%@\"", connect[key]]];
        if (i > 0) {
            [paramConnect appendString:@","];
        }
        i--;
    }
    [paramConnect appendString:@"}"];
    NSMutableArray *supports = [NSMutableArray array];
    // Standard Profiles
    [supports addObject:@"authorization"];
    [supports addObject:@"battery"];
    [supports addObject:@"connect"];
    [supports addObject:@"deviceorientation"];
    [supports addObject:@"fileDescriptor"];
    [supports addObject:@"file"];
    [supports addObject:@"mediaStreamRecording"];
    [supports addObject:@"mediaPlayer"];
    [supports addObject:@"phone"];
    [supports addObject:@"proximity"];
    [supports addObject:@"servicediscovery"];
    [supports addObject:@"serviceinformation"];
    [supports addObject:@"settings"];
    [supports addObject:@"system"];
    [supports addObject:@"vibration"];
    // Extended Profiles of Test Plug-In
    [supports addObject:@"event"];
    [supports addObject:@"ping"];
    [supports addObject:@"timeout"];
    NSMutableString *paramSupports = [NSMutableString string];
    [paramConnect appendString:@"["];
    for (i = 0; i < supports.count; i++) {
        if (i > 0) {
            [paramSupports appendString:@","];
        }
        [paramSupports appendString:[NSString stringWithFormat:@"\"%@\"", supports[i]]];
    }
    [paramConnect appendString:@"]"];
    
    NSString *expectedJson = [NSString stringWithFormat:@"{\"result\":0,\"connect\":%@,\"supports\":%@}", paramConnect, paramSupports];
    CHECK_RESPONSE(expectedJson, request);
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
