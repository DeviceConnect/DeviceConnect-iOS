//
//  DPThetaOmnidirectionalImage.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import "DPThetaOmnidirectionalImage.h"

@interface DPThetaOmnidirectionalImage() <NSURLSessionDataDelegate, NSURLSessionTaskDelegate> {
    NSMutableData *apData;
    NSURLSession *session;
    DPOmniBlock omniCallback;
}
@end
@implementation DPThetaOmnidirectionalImage

- (instancetype)initWithURL:(NSURL*)url origin:(NSString*)origin callback:(DPOmniBlock)callback
{
    self = [super init];
    if (self) {
        omniCallback = callback;
        _image = [NSMutableData new];
        apData = [NSMutableData new];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

        [request addValue:origin forHTTPHeaderField:@"X-GotAPI-Origin"];
        [request setTimeoutInterval:1];
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest  =  10;
        sessionConfig.timeoutIntervalForResource =  20;
        session = [NSURLSession sessionWithConfiguration: sessionConfig
                                      delegate: self
                                 delegateQueue: nil];
        [[session dataTaskWithRequest:request] resume];
    }
    return self;
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    [apData appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    _image = apData;
    [self abort];
}

-(void)abort{
    if(session != nil){
        [session invalidateAndCancel];
        session = nil;
    }

    if (omniCallback) {
        omniCallback();
    }
}
@end
