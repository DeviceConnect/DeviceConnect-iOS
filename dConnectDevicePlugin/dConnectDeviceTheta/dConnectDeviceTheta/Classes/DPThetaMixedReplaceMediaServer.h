//
//  DPThetaMixedReplaceMediaServer.h
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/12.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
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
