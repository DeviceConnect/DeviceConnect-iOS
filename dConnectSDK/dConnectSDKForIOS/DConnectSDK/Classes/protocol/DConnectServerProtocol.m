//
//  DConnectServerProtocol.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectServerProtocol.h"

#import "DConnectManager+Private.h"
#import "DConnectMessage+Private.h"
#import "DConnectFilesProfile.h"
#import "DConnectMultipartParser.h"
#import "DConnectFileManager.h"
#import "NSURLRequest+BodyAndBodyStreamInOne.h"
#import "DConnectURIBuilder.h"
#import "GCIPUtil.h"
#import "RoutingHTTPServer.h"
#import "WebSocket.h"
#import "HTTPServer.h"



@implementation DConnectServerProtocol

static NSString *scheme = @"http";

static RoutingHTTPServer *mHttpServer;

+ (BOOL)startServerWithHost:(NSString*)host port:(int)port
{
    mHttpServer = [[RoutingHTTPServer alloc] init];
    [mHttpServer setPort:port];
    [mHttpServer setDefaultHeader:@"Server" value:@"DeviceConnect/1.0"];
    [mHttpServer setDefaultHeader:@"Access-Control-Allow-Origin" value:@"*"];
    // register Http request handler
    [mHttpServer get:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [mHttpServer post:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [mHttpServer put:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [mHttpServer delete:@"/*" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    [mHttpServer handleMethod:@"OPTIONS" withPath:@"/*" block:^(RouteRequest *request, RouteResponse *response) {
        [self handleHttpRequest:request response:response];
    }];
    
    NSError *error;
    if([mHttpServer start:&error]) {
        return YES;
    } else {
        return NO;
    }
}


+ (void)stopServer
{
    if ([mHttpServer isRunning]) {
        [mHttpServer stop];
    }
}


+ (void) sendEvent:(NSString *)event forSessionKey:(NSString *)sessionKey
{
    if (mHttpServer) {
        [mHttpServer sendEvent:event forSessionKey:sessionKey];
    }
}

#pragma mark - Private Method

+ (void)handleHttpRequest:(RouteRequest*)request response:(RouteResponse*)response
{
    if (![[[request url] host] isEqualToString:@"localhost"]) {
        // todo: 外部からリクエストを受け付けるかどうか
        NSString *dataStr =
        [NSString stringWithFormat:
         @"{\"%@\":%lu,\"%@\":%lu,\"%@\":\"Not localhost.\"}",
         DConnectMessageResult, (unsigned long)DConnectMessageResultTypeError,
         DConnectMessageErrorCode, (unsigned long)DConnectMessageErrorCodeIllegalServerState,
         DConnectMessageErrorMessage];
        [response setHeader:@"Content-Type" value:@"application/json"];
        [response respondWithString:dataStr];
        return;
    }
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * HTTP_REQUEST_TIMEOUT);
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[request url]];
    [req setHTTPMethod:[request method]];
    [req setHTTPBody:[request body]];
    for (id key in [[request headers] keyEnumerator]) {
        [req setValue:[[request headers] valueForKey:key] forHTTPHeaderField:key];
    }
    [DConnectURLProtocol responseContextWithHTTPRequest:req callback:^(ResponseContext *responseCtx) {
        if (responseCtx.response) {
            NSString *str = [[NSString alloc] initWithData:responseCtx.data encoding:NSUTF8StringEncoding];
            NSDictionary *headerInfo = ((NSHTTPURLResponse *) responseCtx.response).allHeaderFields;
            for (id key in [headerInfo keyEnumerator]) {
                [response setHeader:key value:headerInfo[key]];
            }
            NSString *contentType = responseCtx.response.MIMEType;
            // レスポンスあり；成功。

            if (contentType && (([contentType rangeOfString:@"multipart/form-data"
                                                  options:NSCaseInsensitiveSearch].location != NSNotFound)
                || ([contentType rangeOfString:@"image/"
                                       options:NSCaseInsensitiveSearch].location != NSNotFound)
                || ([contentType rangeOfString:@"audio/"
                                       options:NSCaseInsensitiveSearch].location != NSNotFound)
                || ([contentType rangeOfString:@"video/"
                                       options:NSCaseInsensitiveSearch].location != NSNotFound)
                ))
            {
                [response respondWithData:responseCtx.data];
            } else {
                [response respondWithString:str];
            }
        } else {
            NSString *dataStr =
            [NSString stringWithFormat:
             @"{\"%@\":%lu,\"%@\":%lu,\"%@\":\"Illegal State.\"}",
             DConnectMessageResult, (unsigned long)DConnectMessageResultTypeError,
             DConnectMessageErrorCode, (unsigned long)DConnectMessageErrorCodeIllegalServerState,
             DConnectMessageErrorMessage];
            [response setHeader:@"Content-Type" value:@"application/json"];
            [response respondWithString:dataStr];
        }
        dispatch_semaphore_signal(semaphore);
    }];
    long result = dispatch_semaphore_wait(semaphore, timeout);
    if (result != 0) {
        NSString *dataStr =
        [NSString stringWithFormat:
         @"{\"%@\":%lu,\"%@\":%lu,\"%@\":\"Response timeout.\"}",
         DConnectMessageResult, (unsigned long)DConnectMessageResultTypeError,
         DConnectMessageErrorCode, (unsigned long)DConnectMessageErrorCodeTimeout,
         DConnectMessageErrorMessage];
        [response setHeader:@"Content-Type" value:@"application/json"];
        [response respondWithString:dataStr];
    }

}

@end
