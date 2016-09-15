//
//  DPAWSIoTHttpSocketAdapter.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTHttpSocketAdapter.h"
#import "GCDAsyncSocket.h"

@interface DPAWSIoTHttpSocketAdapter () <GCDAsyncSocketDelegate>

@end

@implementation DPAWSIoTHttpSocketAdapter {
    GCDAsyncSocket *_socket;
    int _retryCount;
}

- (id) initWithHostname:(NSString *)hostname port:(UInt32)port timeout:(int)timeoutSec
{
    self = [super init];
    if (self) {
        _hostname = hostname;
        _port = port;
        _timeoutSec = timeoutSec;
        _retryCount = 0;
    }
    return self;
}

- (BOOL) openSocket
{
    NSError *error = nil;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    if (![_socket connectToHost:self.hostname onPort:self.port error:&error]) {
        NSLog(@"DPAWSIoTSocketAdapter::openSocket: %@", error);
        return NO;
    }
    return YES;
}

- (void) closeSocket
{
    if (_socket) {
        [_socket disconnect];
        _socket = nil;
    }
    
    if (self.connection) {
        [self.connection close];
        self.connection = nil;
    }
}

- (BOOL) writeData:(const void *)data length:(NSUInteger)len
{
    if (!data || len == 0) {
        return NO;
    } else {
        [_socket writeData:[NSData dataWithBytes:data length:len] withTimeout:-1 tag:0];
        return YES;
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"DPAWSIoTSocketAdapter::socket:didConnectToHost: %@", host);
    [_socket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"DPAWSIoTSocketAdapter::socket:didReadData:%p %d", sock, (int)[data length]);
    
    if (self.connection) {
        [self.connection sendData:[data bytes] length:(int)[data length]];
        [_socket readDataWithTimeout:-1 tag:0];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"DPAWSIoTSocketAdapter::socketDidDisconnect");
    
    // TODO UDPが送り終わっていないのにcloseしてしまうと問題があるので、一旦保留
    //    if (self.connection) {
    //        [self.connection close];
    //    }
}

@end
