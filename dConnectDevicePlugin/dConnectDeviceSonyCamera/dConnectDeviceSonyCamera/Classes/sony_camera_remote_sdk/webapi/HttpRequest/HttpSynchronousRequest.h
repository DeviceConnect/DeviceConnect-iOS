/**
 * @file  HttpSynchronousRequest.h
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

@interface HttpSynchronousRequest : NSObject

/**
 * Synchronous HTTP POST call for webAPI
 */
- (NSData *)call:(NSString *)url postParams:(NSString *)params;

@end
