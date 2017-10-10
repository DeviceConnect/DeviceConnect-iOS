//
//  DConnectServerManager.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServerManager.h"
#import "DConnectManager+Private.h"
#import "DConnectMessage+Private.h"
#import "DConnectHttpServer.h"
#import "DConnectHttpConnection.h"
#import "DConnectFilesProfile.h"
#import "DConnectFileManager.h"
#import "DConnectMultipartParser.h"
#import "DConnectURIBuilder.h"

/// 内部用タイプを定義する。
#define EXTRA_INNER_TYPE @"_type"

/// HTTPからの通信タイプを定義する。
#define EXTRA_TYPE_HTTP @"http"

/// JSONのマイムタイプ。
#define MIME_TYPE_JSON @"application/json; charset=UTF-8"

typedef NS_ENUM(NSInteger, RequestExceptionType) {
    HAVE_NO_API_EXCEPTION,
    HAVE_NO_PROFILE_EXCEPTION,
    NOT_SUPPORT_ACTION_EXCEPTION,
    INVALID_URL_EXCEPTION,
    INVALID_PROFILE_EXCEPTION
};


@implementation DConnectServerManager {
    DConnectHttpServer *_httpServer;
    NSDateFormatter *_dateFormatter;
}

- (BOOL) startServer
{
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    _dateFormatter = [NSDateFormatter new];
    _dateFormatter.locale = locale;
    _dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss z";
    _dateFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    
    _httpServer = [DConnectHttpServer new];
    
    [_httpServer setConnectionClass:[DConnectHttpConnection class]];
    [_httpServer setPort:self.settings.port];
    [_httpServer setDefaultHeader:@"Connection" value:@"close"];
    [_httpServer setDefaultHeader:@"Cache-Control" value:@"private, max-age=0, no-cache"];
    [_httpServer setDefaultHeader:@"Server" value:@"DeviceConnect/1.0"];
    [_httpServer setDefaultHeader:@"Access-Control-Allow-Origin" value:@"*"];
    [_httpServer get:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [_httpServer post:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [_httpServer put:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [_httpServer delete:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [_httpServer handleMethod:@"OPTIONS" withPath:@"/*" block:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    
    NSError *error;
    if([_httpServer start:&error]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)stopServer
{
    if ([_httpServer isRunning]) {
        [_httpServer stop];
    }
}

- (void) sendEvent:(NSString *)event forReceiverId:(NSString *)receiverId
{
    if (_httpServer) {
        [_httpServer sendEvent:event forReceiverId:receiverId];
    }
}

- (NSArray *) getWebSockets
{
    return [_httpServer getWebSockets];
}

+ (void) convertUriOfMessage:(DConnectMessage *) response
{
    NSArray *keys = [response allKeys];
    for (NSString *key in keys) {
        NSObject *obj = [response objectForKey:key];
        if ([obj isKindOfClass:[NSString class]] && [key isEqualToString:@"uri"]) {
            NSString *uri = (NSString *)obj;
            
            // http, httpsで指定されているURLは直接アクセスできるのでFilesAPIを利用しない
            NSString *pattern = @"^https?://.+";
            NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                                        options:0 error:nil];
            NSTextCheckingResult *result = [expression firstMatchInString:uri
                                                                  options:0
                                                                    range:NSMakeRange(0, uri.length)];
            if (!result || result.numberOfRanges < 1) {
                // http, https以外の場合はuriパラメータ値を
                // DeviceConnectManager Files API向けURLに置き換える。
                DConnectURIBuilder *builder = [DConnectURIBuilder new];
                [builder setProfile:DConnectFilesProfileName];
                [builder addParameter:uri forName:DConnectFilesProfileParamUri];
                [response setString:[[builder build] absoluteString] forKey:@"uri"];
            }
        } else if ([obj isKindOfClass:[DConnectMessage class]]) {
            [self convertUriOfMessage:(DConnectMessage *)obj];
        } else if ([obj isKindOfClass:[DConnectArray class]]) {
            DConnectArray *arr = (DConnectArray *) obj;
            for (int i = 0; i < arr.count; i++) {
                NSObject *message = [arr objectAtIndex:i];
                if ([message isKindOfClass:[DConnectMessage class]]) {
                    [self convertUriOfMessage:(DConnectMessage *) message];
                }
            }
        }
    }
}

#pragma mark - Private Method

- (void) handleHttpRequest:(RouteRequest *)request response:(RouteResponse *)response
{
    if (!self.settings.useExternalIP && ![[[request url] host] isEqualToString:@"localhost"]) {
        [self settingErrorCode:DConnectMessageErrorCodeIllegalServerState
                  errorMessage:@"Not localhost."
                    toResponse:response];
    } else {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * HTTP_REQUEST_TIMEOUT);
        
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf executeWithRequest:request response:response callback:^(DConnectResponseMessage *responseMessage) {
                dispatch_semaphore_signal(semaphore);
            }];
        });
        
        long result = dispatch_semaphore_wait(semaphore, timeout);
        if (result != 0) {
            [self settingErrorCode:DConnectMessageErrorCodeTimeout
                      errorMessage:@"Response timeout."
                        toResponse:response];
        }
    }
    
    [self setHeaderInResponse:response withRequest:request];
}

- (void) executeWithRequest:(RouteRequest *)request response:(RouteResponse *)response callback:(DConnectResponseBlocks)callback
{
    if ([[request method] isEqualToString:@"OPTIONS"]) {
        // CORS処理
        [response setStatusCode:200];
        [response setHeader:@"Content-Type" value:@"text/plain"];
        [response setHeader:@"Access-Control-Allow-Methods" value:@"POST, GET, PUT, DELETE"];
        callback(nil);
    } else {
        __weak typeof(self) weakSelf = self;
        
        NSError *error = nil;
        DConnectRequestMessage *requestMessage = [self requestMessageWithHTTPReqeust:request error:&error];
        if (error) {
            switch (error.code) {
                case HAVE_NO_API_EXCEPTION:
                    [response setStatusCode:404];
                    [response respondWithString:error.domain encoding:NSUTF8StringEncoding];
                    break;
                case HAVE_NO_PROFILE_EXCEPTION: {
                    DConnectResponseMessage *responseMessage = [DConnectResponseMessage new];
                    [responseMessage setResult:DConnectMessageResultTypeError];
                    [responseMessage setVersion:[DConnectManager sharedManager].versionName];
                    [responseMessage setProduct:[DConnectManager sharedManager].productName];
                    [responseMessage setErrorToNotSupportProfile];
                    [self convertDConnectResponse:responseMessage DConnectRequest:nil toResponse:response Request:request];
                }   break;
                case NOT_SUPPORT_ACTION_EXCEPTION: {
                    [response setStatusCode:501];
                    [response respondWithString:error.domain encoding:NSUTF8StringEncoding];
                }   break;
                case INVALID_URL_EXCEPTION: {
                    DConnectResponseMessage *responseMessage = [DConnectResponseMessage new];
                    [responseMessage setResult:DConnectMessageResultTypeError];
                    [responseMessage setVersion:[DConnectManager sharedManager].versionName];
                    [responseMessage setProduct:[DConnectManager sharedManager].productName];
                    [responseMessage setErrorToInvalidURL];
                    [self convertDConnectResponse:responseMessage DConnectRequest:nil toResponse:response Request:request];
                }   break;
                case INVALID_PROFILE_EXCEPTION: {
                    DConnectResponseMessage *responseMessage = [DConnectResponseMessage new];
                    [responseMessage setResult:DConnectMessageResultTypeError];
                    [responseMessage setVersion:[DConnectManager sharedManager].versionName];
                    [responseMessage setProduct:[DConnectManager sharedManager].productName];
                    [responseMessage setErrorToInvalidProfile];
                    [self convertDConnectResponse:responseMessage DConnectRequest:nil toResponse:response Request:request];
                }   break;

                default: {
                    DConnectResponseMessage *responseMessage = [DConnectResponseMessage new];
                    [responseMessage setResult:DConnectMessageResultTypeError];
                    [responseMessage setVersion:[DConnectManager sharedManager].versionName];
                    [responseMessage setProduct:[DConnectManager sharedManager].productName];
                    [responseMessage setErrorToUnknown];
                    [self convertDConnectResponse:responseMessage DConnectRequest:nil toResponse:response Request:request];
                }   break;
            }
            callback(nil);
            return;
        }
        [requestMessage setString:EXTRA_TYPE_HTTP forKey:EXTRA_INNER_TYPE];
        [[DConnectManager sharedManager] sendRequest:requestMessage
                                              isHttp:YES
                                            callback:^(DConnectResponseMessage *responseMessage) {
                                                [weakSelf convertDConnectResponse:responseMessage
                                                                  DConnectRequest:requestMessage
                                                                       toResponse:response
                                                                          Request:request];
                                                callback(nil);
                                            }];
    }
}

- (DConnectRequestMessage *)requestMessageWithHTTPReqeust:(RouteRequest *)request error:(NSError **)error
{
    NSURL *url = request.url;
    
    DConnectRequestMessage *requestMessage = [DConnectRequestMessage message];
    
    // HTTPリクエストのURLのパスセグメントを取得
    NSMutableCharacterSet *whiteAndSlash = [NSMutableCharacterSet whitespaceCharacterSet];
    [whiteAndSlash formUnionWithCharacterSet:[NSMutableCharacterSet characterSetWithCharactersInString:@"/"]];
    NSString *trimmedPath = [url.path stringByTrimmingCharactersInSet:whiteAndSlash];
    NSArray *pathComponentArr = [trimmedPath componentsSeparatedByString:@"/"];
    
    // パラメータ「key=val」をパースし、パラメータ用NSDicitonaryに格納する。
    [self setURLParametersFromString:url.query
                    toRequestMessage:requestMessage
                     percentDecoding:YES];
    
    // URLのパスセグメントの数から、
    // プロファイル・属性・インターフェースが何なのかを判定する。
    NSString *api, *profile, *attr, *interface, *httpMethod;
    BOOL existMethod = NO;
    if ([pathComponentArr count] >= 2) {
        existMethod = [self existHttpMethod:pathComponentArr[1]];
    }
    api = profile = attr = interface = httpMethod = nil;
    
    if ([pathComponentArr count] == 1
        && [pathComponentArr[0] length] != 0)
    {
        api = pathComponentArr[0];
    } else if ([pathComponentArr count] == 2
               && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0)
    {
        api = pathComponentArr[0];
        profile = pathComponentArr[1];
    } else if ([pathComponentArr count] == 3
               && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0 && [pathComponentArr[2] length] != 0
               && !existMethod)
    {
        // パスが3つあり、HTTPメソッドがパスに指定されていない。
        api = pathComponentArr[0];
        profile = pathComponentArr[1];
        attr = pathComponentArr[2];
    } else if ([pathComponentArr count] == 3
               && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0 && [pathComponentArr[2] length] != 0
               && existMethod)
    {
        // パスが3つあり、HTTPメソッドがパスに指定されている。
        api = pathComponentArr[0];
        httpMethod = pathComponentArr[1];
        profile = pathComponentArr[2];
    } else if ([pathComponentArr count] == 4
            && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0 && [pathComponentArr[2] length] != 0
            && [pathComponentArr[3] length] != 0 && !existMethod)
    {
        // パスが4つあり、HTTPメソッドがパスに指定されていない。
        api = pathComponentArr[0];
        profile = pathComponentArr[1];
        interface = pathComponentArr[2];
        attr = pathComponentArr[3];
    } else if ([pathComponentArr count] == 4
               && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0 && [pathComponentArr[2] length] != 0
               && [pathComponentArr[3] length] != 0 && existMethod)
    {
        // パスが4つあり、HTTPメソッドがパスに指定されている。
        api = pathComponentArr[0];
        httpMethod = pathComponentArr[1];
        profile = pathComponentArr[2];
        attr = pathComponentArr[3];
    } else if ([pathComponentArr count] == 5
               && [pathComponentArr[0] length] != 0 && [pathComponentArr[1] length] != 0 && [pathComponentArr[2] length] != 0
               && [pathComponentArr[3] length] != 0 && [pathComponentArr[4] length] != 0 && existMethod)
    {
        // パスが4つあり、HTTPメソッドがパスに指定されている。
        api = pathComponentArr[0];
        httpMethod = pathComponentArr[1];
        profile = pathComponentArr[2];
        interface = pathComponentArr[3];
        attr = pathComponentArr[4];
    }
    
    if (api == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"No valid api was detected in URL."
                                         code:HAVE_NO_API_EXCEPTION
                                     userInfo:nil];
        }
        return nil;
    }
    
    if (profile == nil) {
        if (error) {
            *error = [NSError errorWithDomain:@"No valid profile was detected in URL."
                                         code:HAVE_NO_PROFILE_EXCEPTION
                                     userInfo:nil];
        }
        return nil;
    } else if ([self existHttpMethod:profile]) {
        if (error) {
            *error = [NSError errorWithDomain:@"Profile name is invalid."
                                         code:INVALID_PROFILE_EXCEPTION
                                     userInfo:nil];
        }
        return nil;
    }
    
    // リクエストメッセージにHTTPリクエストのメソッドに対応するアクション名を格納する
    int methodId = [self getDConnectMethod:request.method];
    if (methodId == -1) {
        if (error) {
            *error = [NSError errorWithDomain:@"Unknown method"
                                         code:NOT_SUPPORT_ACTION_EXCEPTION
                                     userInfo:nil];
        }
        return nil;
    }
    
    // URLにmethodが指定されている場合は、そちらのHTTPメソッドを優先する
    if (httpMethod) {
        if (methodId == DConnectMessageActionTypeGet) {
            methodId = [self getDConnectMethod:[httpMethod uppercaseString]];
        } else {
            if (error) {
                *error = [NSError errorWithDomain:@"Request url is invalid"
                                             code:INVALID_URL_EXCEPTION
                                         userInfo:nil];
            }
            return nil;
        }
    }
    
    
    [requestMessage setAction:methodId];
    [requestMessage setApi:api];
    [requestMessage setProfile:profile];
    
    if (interface) {
        [requestMessage setInterface:interface];
    }
    
    if (attr) {
        [requestMessage setAttribute:attr];
    }
    
    // HTTPリクエストヘッダの解析
    [self setHeaderFromRequset:request toRequestMessage:requestMessage];
    
    // パラメータがHTTPボディに記述されているなら、解析しリクエストメッセージに追加する。
    if (request.body && request.body.length > 0) {
        [self setBodyFromRequest:request toRequestMessage:requestMessage];
    }
    
    return requestMessage;
}

- (int) getDConnectMethod:(NSString *)httpMethod
{
    if ([httpMethod isEqualToString:@"GET"]) {
        return DConnectMessageActionTypeGet;
    } else if ([httpMethod isEqualToString:@"POST"]) {
        return DConnectMessageActionTypePost;
    } else if ([httpMethod isEqualToString:@"PUT"]) {
        return DConnectMessageActionTypePut;
    } else if ([httpMethod isEqualToString:@"DELETE"]) {
        return DConnectMessageActionTypeDelete;
    }
    return -1;
}

- (void)setURLParametersFromString:(NSString *)urlParameterStr
                  toRequestMessage:(DConnectRequestMessage *)requestMessage
                   percentDecoding:(BOOL)doDecode
{
    if (!urlParameterStr) {
        return;
    }
    NSArray *paramArr = [urlParameterStr componentsSeparatedByString:@"&"];
    [paramArr enumerateObjectsWithOptions:NSEnumerationConcurrent
                               usingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSArray *keyValArr = [(NSString *)obj componentsSeparatedByString:@"="];
         NSString *key;
         NSString *val;
         
#ifdef DEBUG_LEVEL
#if DEBUG_LEVEL > 3
         // valが無くkeyのみのパラメータ
         if ([keyValArr count] == 1) {
             key = doDecode ?
             [DConnectURLProtocol stringByURLDecodingWithString:(NSString *)keyValArr[0]]
             : keyValArr[0];
             DCLogD(@"Key-only URL query parameter \"%@\" will be ignored.", key);
         }
#endif
#endif
         // key&valのパラメータ
         if ([keyValArr count] == 2) {
             
             if (doDecode) {
                 key = [self stringByURLDecodingWithString:(NSString *)keyValArr[0]];
                 val = [self stringByURLDecodingWithString:(NSString *)keyValArr[1]];
             } else {
                 key = keyValArr[0];
                 val = keyValArr[1];
             }
             
             if (key && val) {
                 @synchronized (requestMessage) {
                     [requestMessage setString:val forKey:key];
                 }
             }
         }
     }];
}

- (NSString *) stringByURLDecodingWithString:(NSString *)string {
    NSString *url = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    url = [url stringByRemovingPercentEncoding];
    return url;
}

- (void) setHeaderFromRequset:(RouteRequest *)request toRequestMessage:(DConnectRequestMessage *)requestMessage
{
    // オリジンの解析
    NSString *webOrigin = [request header:@"origin"];
    NSString *nativeOrigin = [request header:DConnectMessageHeaderGotAPIOrigin];
    if (nativeOrigin) {
        [requestMessage setString:nativeOrigin forKey:DConnectMessageOrigin];
    } else if (webOrigin) {
        [requestMessage setString:webOrigin forKey:DConnectMessageOrigin];
    } else {
        DCLogW(@"origin of request is not specified.");
    }
}

- (void) setBodyFromRequest:(RouteRequest *)request toRequestMessage:(DConnectRequestMessage *)requestMessage
{
    NSString *contentType = [request header:@"content-type"];
    if (contentType && [contentType rangeOfString:@"multipart/form-data"
                                          options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [self setMultipartFromRequest:request toRequestMessage:requestMessage];
    } else if (request.body && request.body.length > 0) {
        NSString *urlParameter = [[NSString alloc] initWithData:request.body encoding:NSUTF8StringEncoding];
        BOOL doDecode = [contentType isEqualToString:@"application/x-www-form-urlencoded"];
        [self setURLParametersFromString:urlParameter
                        toRequestMessage:requestMessage
                         percentDecoding:doDecode];
    }
}

- (void) setMultipartFromRequest:(RouteRequest *)request toRequestMessage:(DConnectRequestMessage *)requestMessage
{
    NSString *boundary = [self boundary:request];
    if (!boundary) {
        return;
    }
    
    UserData *userData = [UserData userDataWithRequest:requestMessage];
    DConnectMultipartParser *multiParser = [DConnectMultipartParser multipartParserWithURL:request.url
                                                                                  boundary:boundary
                                                                                  userData:userData];
    [multiParser parse:request.body];
}

- (NSString *)boundary:(RouteRequest *)request
{
    NSString *contentType = [request header:@"content-type"];
    
    // Multipart Content-Typeのboundaryパラメータをキャプチャする準備
    // 参照： http://www.w3.org/Protocols/rfc1341/7_2_Multipart.html
    NSString *bcharsnospaceRegex = @"[\\d\\w'\\(\\)\\+_,-\\./:=\\?]";
    NSMutableString *bcharsRegex = @"[".mutableCopy;
    [bcharsRegex appendString:bcharsnospaceRegex];
    [bcharsRegex appendString:@"| ]"];
    NSMutableString *boundaryRegex = bcharsRegex.mutableCopy;
    [boundaryRegex appendString:@"{0,69}"];
    [boundaryRegex appendString:bcharsnospaceRegex];
    // パラメータboundaryの値を正規表現でキャプチャ
    NSMutableString *boundaryParamRegex = @"boundary=((?:\"".mutableCopy;
    [boundaryParamRegex appendString:boundaryRegex];
    [boundaryParamRegex appendString:@"\")|(?:"];
    [boundaryParamRegex appendString:boundaryRegex];
    [boundaryParamRegex appendString:@"))"];
    
    NSError *error = nil;
    NSRegularExpression *regex =
    [NSRegularExpression regularExpressionWithPattern:boundaryParamRegex
                                              options:0
                                                error:&error];
    if (error) {
        return nil;
    }

    NSTextCheckingResult *result =
    [regex firstMatchInString:contentType
                      options:NSMatchingReportProgress
                        range:NSMakeRange(0, contentType.length)];
    
    
    if (result.numberOfRanges < 2) {
        return nil;
    }
    
    return [contentType substringWithRange:[result rangeAtIndex:1]];
}

- (void) settingErrorCode:(DConnectMessageErrorCodeType)errorCode
             errorMessage:(NSString *)errorMessage
               toResponse:(RouteResponse *)response
{
    NSString *dataStr = [NSString stringWithFormat:@"{\"%@\":%@,\"%@\":%@,\"%@\":\"%@\"}",
                         DConnectMessageResult, @(DConnectMessageResultTypeError),
                         DConnectMessageErrorCode, @(errorCode),
                         DConnectMessageErrorMessage, errorMessage];
    [response setHeader:@"Content-Type" value:MIME_TYPE_JSON];
    [response respondWithString:dataStr];
    [response setStatusCode:200];
}

- (void) convertDConnectResponse:(DConnectResponseMessage *)responseMessage
                 DConnectRequest:(DConnectRequestMessage *)requestMessage
                      toResponse:(RouteResponse *)response
                         Request:(RouteRequest *)request
{
    if (requestMessage && [requestMessage.profile isEqualToString:DConnectFilesProfileName]) {
        if ([responseMessage result] == DConnectMessageResultTypeOk) {
            [response setStatusCode:200];
            [response setHeader:@"Content-Type" value:[responseMessage stringForKey:DConnectFilesProfileParamMimeType]];
            [response respondWithData:[responseMessage dataForKey:DConnectFilesProfileParamData]];
        } else if ([responseMessage result] == DConnectMessageResultTypeError) {
            [response setStatusCode:404];
            [response setHeader:@"Content-Type" value:@"text/plain"];
            [response respondWithString:@"Not found."];
        } else {
            [response setStatusCode:500];
            [response setHeader:@"Content-Type" value:@"text/plain"];
            [response respondWithString:@"unkknown result type."];
        }
    } else {
        [DConnectServerManager convertUriOfMessage:responseMessage];
        
        NSString *json = [responseMessage convertToJSONString];
        if (!json) {
            [self settingErrorCode:DConnectMessageErrorCodeUnknown
                      errorMessage:@"Failed to generate a JSON body."
                        toResponse:response];
        } else {
            [response respondWithString:json encoding:NSUTF8StringEncoding];
        }
        [response setStatusCode:200];
        [response setHeader:@"Content-Type" value:MIME_TYPE_JSON];
    }
}

- (void) setHeaderInResponse:(RouteResponse *)response withRequest:(RouteRequest *)request
{
    NSString *requestHeaders = [request header:@"Access-Control-Request-Headers"];
    NSMutableString *allowHeaders = @"XMLHttpRequest".mutableCopy;
    if (requestHeaders) {
        [allowHeaders appendString:[NSString stringWithFormat:@", %@", requestHeaders]];
    }
    
    NSString *contentLength;
    if (response.response && response.response.contentLength > 0) {
        contentLength = [NSString stringWithFormat:@"%@", @(response.response.contentLength)];
    } else {
        contentLength = @"0";
    }

    [response setHeader:@"Content-Length" value:contentLength];
    [response setHeader:@"Date" value:[[NSDate date] descriptionWithLocale:nil]];
    [response setHeader:@"Access-Control-Allow-Headers" value:allowHeaders];
    [response setHeader:@"Last-Modified" value:[_dateFormatter stringFromDate:[NSDate date]]];
}

- (BOOL)existHttpMethod:(NSString*)method
{
    return [[method uppercaseString] isEqualToString:@"GET"]
        || [[method uppercaseString] isEqualToString:@"POST"]
        || [[method uppercaseString] isEqualToString:@"PUT"]
        || [[method uppercaseString] isEqualToString:@"DELETE"];
}
@end
