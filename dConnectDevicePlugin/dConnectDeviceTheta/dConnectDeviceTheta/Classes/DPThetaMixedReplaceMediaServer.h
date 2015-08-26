//
//  DPThetaMixedReplaceMediaServer.h
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//


#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@protocol DPThetaMixedReplaceMediaServerDelegate<NSObject>
- (void)didConnectForUri:(NSString*)uri;
- (void)didDisconnectForUri:(NSString*)uri;
- (void)didCloseServer;
@end



@class GCDAsyncSocket;

@interface DPThetaMixedReplaceMediaServer : NSObject
{
    dispatch_queue_t socketQueue;
    dispatch_source_t _timerSource;
    GCDAsyncSocket *listenSocket;
}
@property (nonatomic, assign) id<DPThetaMixedReplaceMediaServerDelegate> delegate;
@property (nonatomic) BOOL isRunning;
- (void)startStopServer;

- (NSString*)getUrl;

- (void)offerMediaWithData:(NSData*)data segment:(NSString *)segment;
@end
