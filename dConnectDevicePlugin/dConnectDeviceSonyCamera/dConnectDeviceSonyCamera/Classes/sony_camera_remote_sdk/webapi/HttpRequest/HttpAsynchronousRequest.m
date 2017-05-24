/**
 * @file  HttpAsynchronousRequest.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "HttpAsynchronousRequest.h"

@implementation HttpAsynchronousRequest {
    id<HttpAsynchronousRequestParserDelegate> _parserDelegate;
    NSMutableData *_receiveData;
    NSString *_apiName;
}

- (void)call:(NSString *)url
        postParams:(NSString *)params
           apiName:(NSString *)apiName
    parserDelegate:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
{
    _parserDelegate = parserDelegate;
    _apiName = apiName;
    _receiveData = [NSMutableData data];
    NSURL *aUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:aUrl
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = params;
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    NSURLSessionConfiguration *ephemeralConfigObject =
        [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *ephemeralSession =
        [NSURLSession sessionWithConfiguration:ephemeralConfigObject
                                      delegate:self
                                 delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask =
        [ephemeralSession dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
    [_receiveData setLength:0];
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [_receiveData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
                    task:(NSURLSessionTask *)task
    didCompleteWithError:(NSError *)error
{
    if (error != nil) {
//        NSLog(@"HttpAsynchronousRequest didFailWithError = %@", error);
        NSString *errorResponse =
            @"{\"id\":0, \"error\":[16,\"Transport Error\"]}";
        [_parserDelegate
            parseMessage:[errorResponse dataUsingEncoding:NSUTF8StringEncoding]
                 apiName:_apiName];
    } else {
        [_parserDelegate parseMessage:_receiveData apiName:_apiName];
    }
    [session invalidateAndCancel];
}
@end
