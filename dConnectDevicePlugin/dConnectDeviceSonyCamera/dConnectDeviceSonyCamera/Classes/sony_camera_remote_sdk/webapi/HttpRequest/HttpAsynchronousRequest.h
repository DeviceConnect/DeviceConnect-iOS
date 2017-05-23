/**
 * @file  HttpAsynchronousRequest.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

@protocol HttpAsynchronousRequestParserDelegate <NSObject>

/*
 * Response callback for HTTP calls with WebAPI name
 */
- (void)parseMessage:(NSData *)response apiName:(NSString *)apiName;

@end

@interface HttpAsynchronousRequest : NSObject <NSURLSessionDataDelegate>

/**
 * Asynchronous HTTP POST call for webAPI
 */
- (void)call:(NSString *)url
        postParams:(NSString *)params
           apiName:(NSString *)apiName
    parserDelegate:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate;

@end
