/**
 * @file  SampleAvContentApi.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "HttpAsynchronousRequest.h"
#import "HttpSynchronousRequest.h"
#import "SampleAvContentDefinitions.h"

@interface SampleAvContentApi : NSObject

+ (void)getMethodTypes:
    (id<HttpAsynchronousRequestParserDelegate>)parserDelegate;

+ (void)getSchemeList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate;

+ (void)getSourceList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
               scheme:(NSString *)scheme;

+ (void)getContentList:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                   uri:(NSString *)uri
                  view:(NSString *)view
                  type:(NSArray *)type;

+ (void)setStreamingContent:
            (id<HttpAsynchronousRequestParserDelegate>)parserDelegate
                        uri:(NSString *)uri;

+ (void)startStreaming:
    (id<HttpAsynchronousRequestParserDelegate>)parserDelegate;

+ (void)stopStreaming:(id<HttpAsynchronousRequestParserDelegate>)parserDelegate;

@end
