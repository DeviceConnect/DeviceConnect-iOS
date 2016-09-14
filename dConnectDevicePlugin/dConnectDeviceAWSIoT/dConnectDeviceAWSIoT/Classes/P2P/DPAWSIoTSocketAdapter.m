//
//  DPAWSIoTSocketAdapter.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTSocketAdapter.h"
#import "GCDAsyncSocket.h"

@interface DPAWSIoTSocketAdapter () <GCDAsyncSocketDelegate>

@end


@implementation DPAWSIoTSocketAdapter {
    GCDAsyncSocket *_socket;
}

- (id)initWithHostname:(NSString*)hostname port:(UInt32)port timeout:(int)timeoutSec
{
    self = [super init];
    if (self) {
        _hostname = hostname;
        _port = port;
        _timeoutSec = timeoutSec;
    }
    return self;
}

- (BOOL) openSocket
{
    NSError *error = nil;
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    if (![_socket connectToHost:_hostname onPort:_port error:&error]) {
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
    
    if (_connection) {
        [_connection close];
        _connection = nil;
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
