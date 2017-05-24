/**
 * @file  HttpSynchronousRequest.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "HttpSynchronousRequest.h"

@implementation HttpSynchronousRequest

- (NSData *)call:(NSString *)url postParams:(NSString *)params
{
    NSURL *aUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:aUrl
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    NSString *postString = params;
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];

    NSError *error = nil;

    __block NSData *responseData;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [queue addOperationWithBlock:^{

        NSURLSessionConfiguration *ephemeralConfigObject =
            [NSURLSessionConfiguration ephemeralSessionConfiguration];
        [ephemeralConfigObject setHTTPMaximumConnectionsPerHost:10];
        NSURLSession *session =
            [NSURLSession sessionWithConfiguration:ephemeralConfigObject];
        NSURLSessionDataTask *dataTask = [session
            dataTaskWithRequest:request
              completionHandler:^(NSData *data, NSURLResponse *response,
                                  NSError *error) {
                  responseData = data;
                  dispatch_semaphore_signal(semaphore);
                  [session invalidateAndCancel];
              }];
        [dataTask resume];
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (error == nil) {
        return responseData;
    }
    return nil;
}

@end
