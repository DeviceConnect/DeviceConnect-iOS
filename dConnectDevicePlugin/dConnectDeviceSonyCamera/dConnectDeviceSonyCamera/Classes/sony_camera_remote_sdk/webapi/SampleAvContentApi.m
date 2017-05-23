/**
 * @file  SampleAvContentApi.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "SampleAvContentApi.h"
#import "DeviceList.h"

@implementation SampleAvContentApi

int idAvContentVal = 1;

+ (int)getId
{
    return idAvContentVal++;
}

/**
 * Calls getMethodTypes API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "getMethodTypes",
 *   "params": [""],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param
 * @return JSON data of response
 */
+ (void)getMethodTypes:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"avContent";
    NSString *aMethod = @"getMethodTypes";
    NSString *aParams = [NSString stringWithFormat:@"[\"\"]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:API_AVCONTENT_getMethodTypes
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getSchemeList API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "getSchemeList",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param
 * @return JSON data of response
 */
+ (void)getSchemeList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_getSchemeList;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getSourceList API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "getSourceList",
 *   "params": ["scheme":"storage"],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param scheme storage
 * @return JSON data of response
 */
+ (void)getSourceList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
               scheme:(NSString *)scheme
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_getSourceList;
    NSString *aParams =
        [NSString stringWithFormat:@"[{\"scheme\":\"%@\"}]", scheme];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getContentList API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "getContentList",
 *   "params": [{
 *        "uri"="storage:memoryCard1",
 *        "view"="date",
 *        "type"=["still","movie_mp4"]}],
 *   "id": 2,
 *   "version": "1.3"
 * }
 * </pre>
 *
 * @param uri  : requested URI of content
 * @param data : data
 * @return JSON data of response
 */

+ (void)getContentList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                   uri:(NSString *)uri
                  view:(NSString *)view
                  type:(NSArray *)type
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_getContentList;
    NSString *aParams;
    if (type == NULL) {
        aParams = [NSString
            stringWithFormat:@"[{\"uri\":\"%@\",\"view\":\"%@\"}]", uri, view];
    } else {
        aParams =
            [NSString stringWithFormat:
                          @"[{\"uri\":\"%@\",\"view\":\"%@\",\"type\":[%@]}]",
                          uri, view, [type componentsJoinedByString:@","]];
    }
    NSString *aVersion = @"1.3";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls setStreamingContent API to the target server. Request JSON data is such
 like
 * as below.
 *
 * <pre>
 * {
 *   "method": "setStreamingContent",
 *   "params": [{ "remotePlayType":"simpleStreaming",
                 "uri":"image:content?contentId=010029" }],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param uri is content URI
 * @return JSON data of response
 */
+ (void)setStreamingContent:
            (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                        uri:(NSString *)uri
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_setStreamingContent;
    NSString *aParams = [NSString
        stringWithFormat:
            @"[{\"remotePlayType\":\"simpleStreaming\",\"uri\":\"%@\"}]", uri];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls startStreaming API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "startStreaming",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param
 * @return JSON data of response
 */
+ (void)startStreaming:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_startStreaming;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls stopStreaming API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "stopStreaming",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param
 * @return JSON data of response
 */
+ (void)stopStreaming:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"avContent";
    NSString *aMethod = API_AVCONTENT_stopStreaming;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleAvContentApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

@end
