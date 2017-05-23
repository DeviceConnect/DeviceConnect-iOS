/**
 * @file  SampleCameraApi.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "SampleCameraApi.h"
#import "DeviceList.h"

@implementation SampleCameraApi

int idCameraVal = 1;

+ (int)getId
{
    return idCameraVal++;
}

/**
 * Calls getAvailableApiList API to the target server. Request JSON data is
 * such like as below.
 *
 * <pre>
 * {
 *   "method": "getAvailableApiList",
 *   "params": [""],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (NSData *)getAvailableApiList:
                (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                         isSync:(BOOL)isSync
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getAvailableApiList;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    if (isSync) {
        return [[[HttpSynchronousRequest alloc] init] call:url
                                                postParams:requestJson];
    } else {
        [[[HttpAsynchronousRequest alloc] init] call:url
                                          postParams:requestJson
                                             apiName:aMethod
                                      parserDelegate:parserDelegate];
    }
    return nil;
}

/**
 * Calls getApplicationInfo API to the target server. Request JSON data is
 * such like as below.
 *
 * <pre>
 * {
 *   "method": "getApplicationInfo",
 *   "params": [""],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (NSData *)getApplicationInfo:
                (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                        isSync:(BOOL)isSync
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getApplicationInfo;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    if (isSync) {
        return [[[HttpSynchronousRequest alloc] init] call:url
                                                postParams:requestJson];
    } else {
        [[[HttpAsynchronousRequest alloc] init] call:url
                                          postParams:requestJson
                                             apiName:aMethod
                                      parserDelegate:parserDelegate];
    }
    return nil;
}

/**
 * Calls getMethodTypes API to the target server. Request JSON data is
 * such like as below.
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
 * @return JSON data of response
 */
+ (void)getMethodTypes:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = @"getMethodTypes";
    NSString *aParams = [NSString stringWithFormat:@"[\"\"]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:API_CAMERA_getMethodTypes
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getShootMode API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "getShootMode",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)getShootMode:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getShootMode;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls setShootMode API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "setShootMode",
 *   "params": ["still"],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param shootMode shoot mode (ex. "still")
 * @return JSON data of response
 */
+ (void)setShootMode:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
           shootMode:(NSString *)shootMode
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_setShootMode;
    NSString *aParams = [NSString stringWithFormat:@"[\"%@\"]", shootMode];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getAvailableShootMode API to the target server. Request JSON data
 * is such like as below.
 *
 * <pre>
 * {
 *   "method": "getAvailableShootMode",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)getAvailableShootMode:
    (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getAvailableShootMode;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getSupportedShootMode API to the target server. Request JSON data
 * is such like as below.
 *
 * <pre>
 * {
 *   "method": "getSupportedShootMode",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)getSupportedShootMode:
    (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getSupportedShootMode;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls startLiveview API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "startLiveview",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)startLiveview:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_startLiveview;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls stopLiveview API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "stopLiveview",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)stopLiveview:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_stopLiveview;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls startRecMode API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "startRecMode",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (NSData *)startRecMode:
                (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                  isSync:(BOOL)isSync
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_startRecMode;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    if (isSync) {
        return [[[HttpSynchronousRequest alloc] init] call:url
                                                postParams:requestJson];
    } else {
        [[[HttpAsynchronousRequest alloc] init] call:url
                                          postParams:requestJson
                                             apiName:aMethod
                                      parserDelegate:parserDelegate];
    }
    return nil;
}

/**
 * Calls actTakePicture API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "actTakePicture",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)actTakePicture:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_actTakePicture;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls startMovieRec API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "startMovieRec",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)startMovieRec:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_startMovieRec;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls stopMovieRec API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "stopMovieRec",
 *   "params": [],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)stopMovieRec:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_stopMovieRec;
    NSString *aParams = [NSString stringWithFormat:@"[]"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls actZoom API to the target server. Request JSON data is such
 * like as below.
 *
 * <pre>
 * {
 *   "method": "actZoom",
 *   "params": ["in","stop"],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @return JSON data of response
 */
+ (void)actZoom:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
      direction:(NSString *)direction
       movement:(NSString *)movement
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_actZoom;
    NSString *aParams =
        [NSString stringWithFormat:@"[\"%@\",\"%@\"]", direction, movement];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls getEvent API to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "getEvent",
 *   "params": [true],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param longPollingFlag true means long polling request.
 * @return JSON data of response
 */
+ (void)getEvent:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
 longPollingFlag:(BOOL)longPollingFlag
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_getEvent;
    NSString *aParams = [NSString
        stringWithFormat:@"[%@]", longPollingFlag ? @"true" : @"false"];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

/**
 * Calls setCameraFunction to the target server. Request JSON data is such like
 * as below.
 *
 * <pre>
 * {
 *   "method": "setCameraFunction",
 *   "params": ["ContentsTransfer"],
 *   "id": 2,
 *   "version": "1.0"
 * }
 * </pre>
 *
 * @param function is the camera mode
 * @return JSON data of response
 */
+ (void)setCameraFunction:
            (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                 function:(NSString *)function
{
    NSString *aService = @"camera";
    NSString *aMethod = API_CAMERA_setCameraFunction;
    NSString *aParams = [NSString stringWithFormat:@"[\"%@\"]", function];
    NSString *aVersion = @"1.0";
    NSString *requestJson = [NSString
        stringWithFormat:
            @"{ \"method\":\"%@\",\"params\":%@,\"version\":\"%@\",\"id\":%d }",
            aMethod, aParams, aVersion, [self getId]];
    NSString *url = [[DeviceList getSelectedDevice] findActionListUrl:aService];

//    NSLog(@"SampleCameraApi Request: %@ ", requestJson);
    [[[HttpAsynchronousRequest alloc] init] call:url
                                      postParams:requestJson
                                         apiName:aMethod
                                  parserDelegate:parserDelegate];
}

@end
