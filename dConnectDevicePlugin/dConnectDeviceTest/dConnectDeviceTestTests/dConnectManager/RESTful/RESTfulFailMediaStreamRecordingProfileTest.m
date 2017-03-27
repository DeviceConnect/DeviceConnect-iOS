//
//  RESTfulFailMediaStreamRecordingProfileTest.m
//  dConnectDeviceTest
//
//  Copyright (c) 2014 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <DConnectSDK/DConnectSDK.h>
#import "RESTfulTestCase.h"

/*!
 * @class RESTfulFailMediaStreamRecordingProfileTest
 * @brief MediaStreamRecordingプロファイルの異常系テスト.
 * @author NTT DOCOMO, INC.
 */
@interface RESTfulFailMediaStreamRecordingProfileTest : RESTfulTestCase

@end

@implementation RESTfulFailMediaStreamRecordingProfileTest

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/mediarecorder
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/mediarecorder"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/mediarecorder?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/mediarecorder?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/mediarecorder?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/mediarecorder?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/mediarecorder?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:@"http://localhost:4035/gotapi/"
                   "mediaStreamRecording/mediarecorder?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @biref メソッドにPUTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/mediarecorder?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/mediarecorder?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/mediarecorder?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMediaRecorderGetInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/mediarecorder?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/takephoto
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/takephoto"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/takephoto?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/takephoto?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/takephoto?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/takephoto?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/takephoto?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/takephoto?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPUTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/takephoto?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/takephoto?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/takephoto?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingTakePhotoPostInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/takephoto?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/record
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/record"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/record?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/record?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/record?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/record?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/record?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/record?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPUTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/record?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostInvalidMethodPut
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/record?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/record?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingRecordPostInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/record?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/pause
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/pause"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/pause?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/pause?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/pause?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/pause?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/pause?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/pause?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/pause?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/pause?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/pause?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingPausePutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/pause?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/resume
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/resume"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/resume?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/resume?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/resume?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/resume?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/resume?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/resume?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/resume?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/resume?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/resume?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingResumePutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/resume?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/stop
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/stop"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/stop?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/stop?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/stop?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/stop?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/stop?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/stop?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/stop?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/stop?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/stop?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingStopPutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/stop?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/mutetrack
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/mutetrack?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/mutetrack?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/mutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定して動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/mutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して動画撮影や音声録音のミュート依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/mutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingMuteTrackPutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/mutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに動画撮影や音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/unmutetrack
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で動画撮影や音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/unmutetrack
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで動画撮影や音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/unmutetrack?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにGETを指定して動画撮影や
 *         音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/unmutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定して動画撮影や
 *        音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/unmutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して
 *         動画撮影や音声録音のミュート解除依頼を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/unmutetrack?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingUnmuteTrackPutInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/unmutetrack?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdを指定せずに再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/options
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsGetNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/options"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/options?serviceId=
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsGetEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/options?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/options?serviceId=123456789
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsGetInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/options?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief serviceId無しで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/options?imageHeight=1080&target=test_camera_id&mimeType=video/mp4&imageWidth=1920
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/options?"
                  "imageHeight=1080&target=test_camera_id&mimeType=video/mp4&imageWidth=1920"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態で再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/options?
 *          serviceId=&imageHeight=1080&
 *            target=test_camera_id&mimeType=video/mp4&imageWidth=1920
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/options?"
                  "imageHeight=1080&target=test_camera_id&mimeType=video/mp4&imageWidth=1920&serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdで再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/options?
 *          serviceId=122345678&imageHeight=1080&
 *          target=test_camera_id&mimeType=video/mp4&imageWidth=1920
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/options?"
                  "imageHeight=1080&target=test_camera_id&mimeType=video/mp4&imageWidth=1920&serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief メソッドにPOSTを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/options?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:
                                       @"http://localhost:4035/gotapi/mediaStreamRecording/options?serviceId=%@",
                                       self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにDELETEを指定して再生コンテンツの変更要求を送信するテスト.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/options?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOptionsInvalidMethodDelete
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                    @"http://localhost:4035/gotapi/mediaStreamRecording/options?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdが無い状態でonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onphoto?accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoPutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onphoto?serviceId=&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoPutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonphoto属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onphoto?serviceId=123456789&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoPutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでonphoto属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onphoto?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoPutNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:
                    [NSString stringWithFormat:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=%@",
                            self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief serviceIdが無い状態でonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onphoto?accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onphoto?serviceId=&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onphoto?serviceId=123456789&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでonphoto属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onphoto?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoDeleteNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief メソッドにGETを指定してonphoto属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/onphoto?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:
                  [NSString stringWithFormat:
                    @"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=%@",
                   self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定してonphoto属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/onphoto?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnPhotoInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:
                    [NSString stringWithFormat:
                        @"http://localhost:4035/gotapi/mediaStreamRecording/onphoto?serviceId=%@",
                     self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief serviceIdが無い状態でonrecordingchange属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onrecordingchange?accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangePutNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonrecordingchange属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangePutEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:
                    @"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonrecordingchange属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=123456789&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangePutInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでonrecordingchange属性のコールバック登録テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: PUT
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangePutNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:
                    [NSString stringWithFormat:
                        @"http://localhost:4035/gotapi/"
                            "mediaStreamRecording/onrecordingchange?serviceId=%@",
                                self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"PUT"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief serviceIdが無い状態でonrecordingchange属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onrecordingchange?accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeDeleteNoServiceId
{
    NSURL *uri = [NSURL URLWithString:@"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":5}", request);
}

/*!
 * @brief serviceIdが空状態でonrecordingchange属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeDeleteEmptyServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange?serviceId="];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief 存在しないserviceIdでonrecordingchange属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=123456789&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeDeleteInvalidServiceId
{
    NSURL *uri = [NSURL URLWithString:
                  @"http://localhost:4035/gotapi/"
                    "mediaStreamRecording/onrecordingchange?serviceId=12345678"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":6}", request);
}

/*!
 * @brief accessToken無しでonrecordingchange属性のコールバック解除テストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: DELETE
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeDeleteNoAccessToken
{
    [DConnectManager sharedManager].settings.useLocalOAuth = YES;
    [DConnectManager sharedManager].settings.useOriginEnable = YES;
    NSURL *uri = [NSURL URLWithString:
                    [NSString stringWithFormat:
                        @"http://localhost:4035/gotapi/"
                            "mediaStreamRecording/onrecordingchange?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"DELETE"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":13}", request);
    [DConnectManager sharedManager].settings.useLocalOAuth = NO;
    [DConnectManager sharedManager].settings.useOriginEnable = NO;
}

/*!
 * @brief メソッドにGETを指定してonrecordingchange属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: GET
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeInvalidMethodGet
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"GET"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

/*!
 * @brief メソッドにPOSTを指定してonrecordingchange属性のリクエストテストを行う.
 * <pre>
 * 【HTTP通信】
 * Method: POST
 * Path: /mediaStreamRecording/onrecordingchange?serviceId=xxxx&accessToken=xxxx
 * </pre>
 * <pre>
 * 【期待する動作】
 * ・resultに1が返ってくること。
 * </pre>
 */
- (void) testHttpFailMediaStreamRecordingOnRecordingChangeInvalidMethodPost
{
    NSURL *uri = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:4035/gotapi/mediaStreamRecording/onrecordingchange?serviceId=%@", self.serviceId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri];
    [request setHTTPMethod:@"POST"];

    CHECK_RESPONSE(@"{\"result\":1,\"errorCode\":3}", request);
}

@end
