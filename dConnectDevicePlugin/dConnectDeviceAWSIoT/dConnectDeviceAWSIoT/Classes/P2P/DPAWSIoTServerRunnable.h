//
//  DPAWSIoTServerRunnable.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;
@class DPAWSIoTP2PConnection;

@interface DPAWSIoTServerRunnable : NSObject

@property (nonatomic) NSInteger port;
@property (nonatomic) NSString *host;

@property GCDAsyncSocket *fromSocket;
@property DPAWSIoTP2PConnection *connection;

- (void) w:(NSData *)data;
- (void) r:(NSData *)data;
- (void) close;
- (void) sendErrorResponse;

- (BOOL) isRetry;

@end
