//
//  RESTfulNormalMediaPlayerProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RESTfulTestCase.h"

@interface RESTfulNormalMediaPlayerProfileTest : RESTfulTestCase

@end

/*!
 * @class RESTfulNormalMediaPlayerProfileTest
 * @brief MediaStreamsPlayプロファイルの正常系テスト.
 * @author NTT DOCOMO, INC.
 */
@implementation RESTfulNormalMediaPlayerProfileTest

/*!
 * @brief 再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/media?serviceId=xxxx&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMediaPut
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaPlayer/media?serviceId=%@&mediaId=0", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 再生コンテンツ情報の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/media?serviceId=xxxx&mediaId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMediaGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                     @"http://localhost:4035/gotapi/mediaPlayer/media?serviceId=%@&mediaId=0", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"creators\":[{\"role\":\"test composer\",\"creator\":\"test creator\"}],"
                 "\"result\":0,\"duration\":60000,\"title\":\"test title\",\"keywords\":[\"keyword1\",\"keyword2\"],"
                  "\"genres\":[\"test1\",\"test2\"],\"description\":\"test description\","
                   "\"language\":\"ja\",\"type\":\"test type\",\"mimeType\":\"audio/mp3\"}", request);
}

/*!
 * @brief 再生コンテンツ一覧の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/mediaList?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMediaListGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaPlayer/mediaList?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"count\":1,\"media\":[{\"creators\":[{\"role\":\"test composer\","
                  "\"creator\":\"test creator\"}],\"duration\":60000,\"title\":\"test title\","
                   "\"keywords\":[\"keyword1\",\"keyword2\"],\"genres\":[\"test1\",\"test2\"],"
                   "\"description\":\"test description\",\"language\":\"ja\",\"type\":\"test type\""
                   ",\"mimeType\":\"audio/mp3\"}]}", request);
}

/*!
 * @brief コンテンツ再生状態の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/playStatus?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerPlayStatusGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/playStatus?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"status\":\"play\"}", request);
}

/*!
 * @brief メディアプレイヤーの再生要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/play?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerPlayPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                    @"http://localhost:4035/gotapi/mediaPlayer/play?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief メディアプレイヤーの停止要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/stop?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerStopPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/stop?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief メディアプレイヤーの一時停止要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/pause?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerPausePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/pause?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief メディアプレイヤーの一時停止解除要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/resume?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerResumePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/resume?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 再生位置の変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/seek?serviceId=xxxx&pos=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerSeekPut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/seek?serviceId=%@&pos=0",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 再生位置の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/seek?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerSeekGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/seek?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"pos\":0}", request);
}

/*!
 * @brief 再生音量の変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/volume?serviceId=xxxx&volume=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerVolumePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/volume?serviceId=%@&volume=0",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief 再生音量の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/volume?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerVolumeGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/volume?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"volume\":0}", request);
}

/*!
 * @brief ミュートを有効にする要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/mute?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMutePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/mute?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ミュートを無効にする要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaPlayer/mute?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMuteDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/mute?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
}

/*!
 * @brief ミュート状態の取得要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaPlayer/mute?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerMuteGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/mute?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];
    
    CHECK_RESPONSE(@"{\"result\":0,\"mute\":true}", request);
}

/*!
 * @brief コンテンツ再生状態変化通知のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaPlayer/onstatuschange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerOnStatusChangePut
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/onstatuschange?"
                                       "accessToken=%@&serviceId=%@",
                                       self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    CHECK_EVENT(@"{\"mediaPlayer\":{\"mediaId\":\"test.mp4\",\"status\":\"play\","
                "\"volume\":0.5,\"mimeType\":\"video/mp4\",\"pos\":0}}");
}

/*!
 * @brief 再生コンテンツ再生状態変化通知のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaPlayer/onstatuschange?serviceId=xxxx&session_key=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに0が返ってくること。
 * </pre>
 */
- (void) testHttpNormalMediaPlayerOnStatusChangeDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaPlayer/onstatuschange?"
                                       "accessToken=%@&serviceId=%@",
                                       self.clientId, self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];
    
    CHECK_RESPONSE(@"{\"result\":0}", request);
    
}

@end
