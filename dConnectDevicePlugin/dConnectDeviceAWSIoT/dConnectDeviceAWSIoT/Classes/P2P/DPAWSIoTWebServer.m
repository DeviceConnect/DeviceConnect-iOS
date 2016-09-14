//
//  DPAWSIoTWebServer.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTWebServer.h"
#import "DPAWSIoTServerRunnable.h"
#import "DPAWSIoTP2PConnection.h"
#import "GCDAsyncSocket.h"
#import "DPAWSIoTP2PUtil.h"

@interface DPAWSIoTWebServer () <GCDAsyncSocketDelegate, DPAWSIoTP2PConnectionDelegate>

@end


@implementation DPAWSIoTWebServer {
    GCDAsyncSocket *_listenSocket;
    NSMutableArray *_connections;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _connections = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Public Method

- (NSString *) start
{
    for (int i = 9000; i < 10000; i++) {
        self.listenPort = i;

        NSError *error = nil;
        _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        if ([_listenSocket acceptOnPort:self.listenPort error:&error]) {
            return [NSString stringWithFormat:@"http://localhost:%@%@", @(self.listenPort), self.path];
        } else {
            NSLog(@"DPAWSIoTWebServer::start %@", error);
        }
    }
    return nil;
}

- (void) stop
{
    [_listenSocket setDelegate:nil delegateQueue:NULL];
    [_listenSocket disconnect];
    _listenSocket = nil;
}

- (void) didReceivedSignaling:(NSString *)signaling
{
    int connectionId = [self getConnectionId:signaling];
    
    __weak typeof(self) weakSelf = self;
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection.connectionId == connectionId) {
            [serverRunnable.connection close];
            serverRunnable.connection = [weakSelf createP2PConnection:signaling delegate:weakSelf];
            if (!serverRunnable.connection) {
                [serverRunnable sendErrorResponse];
                [serverRunnable close];
                [_connections removeObject:serverRunnable];
            }
            *stop = YES;
        }
    }];
}

- (BOOL) hasConnectionId:(NSString *)signaling
{
    int connectionId = [self getConnectionId:signaling];

    __block BOOL result = NO;

    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection.connectionId == connectionId) {
            result = YES;
            *stop = YES;
        }
    }];

    return result;
}

#pragma mark - Private Method


#pragma mark - DPAWSIoTP2PConnectionDelegate

- (void) connection:(DPAWSIoTP2PConnection *)conn didRetrievedAddress:(NSString *)address port:(int)port
{
    NSLog(@"DPAWSIoTWebServer::connection:didRetrievedAddress:%@:%d", address, port);
    
    NSData *data = [DPAWSIoTP2PManager createSignaling:conn.connectionId address:address port:port];
    NSString *signaling = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([_delegate respondsToSelector:@selector(server:didNotifiedSignaling:)]) {
        [_delegate server:self didNotifiedSignaling:signaling];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didConnectedAddress:(NSString *)address port:(int)port
{
    NSLog(@"DPAWSIoTWebServer::connection:didConnectedAddress:%@:%d", address, port);
    
    if ([_delegate respondsToSelector:@selector(serverDidConnected:)]) {
        [_delegate serverDidConnected:self];
    }
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection == conn) {
            [serverRunnable.fromSocket readDataWithTimeout:5 tag:0];
            *stop = YES;
        }
    }];
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didReceivedData:(const char *)data length:(int)length
{
    NSLog(@"DPAWSIoTWebServer::connection:didReceivedData: %d", length);

    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection == conn) {
            [serverRunnable w:[NSData dataWithBytes:data length:length]];
            *stop = YES;
        }
    }];
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didDisconnetedAdderss:(NSString *)address port:(int)port
{
    NSLog(@"DPAWSIoTWebServer::connection:didDisconnetedAdderss:%@:%d", address, port);

    if ([_delegate respondsToSelector:@selector(serverDidDisconnected:)]) {
        [_delegate serverDidDisconnected:self];
    }
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection == conn) {
            [_connections removeObject:serverRunnable];
            *stop = YES;
        }
    }];
}

- (void) connectionDidTimeout:(DPAWSIoTP2PConnection *)conn
{
    NSLog(@"DPAWSIoTWebServer::connectionDidTimeout");
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection == conn) {
            [serverRunnable sendErrorResponse];
            [serverRunnable close];
            [_connections removeObject:serverRunnable];
            *stop = YES;
        }
    }];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    NSLog(@"DPAWSIoTWebServer::socket:didAcceptNewSocket: * %@ -> %@", [newSocket connectedHost], [newSocket localHost]);
    
    DPAWSIoTServerRunnable *serverRunnable = [DPAWSIoTServerRunnable new];
    serverRunnable.host = self.host;
    serverRunnable.port = self.port;
    serverRunnable.fromSocket = newSocket;
    serverRunnable.connection = [DPAWSIoTP2PConnection new];
    serverRunnable.connection.delegate = self;
    [serverRunnable.connection open];
    [_connections addObject:serverRunnable];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    NSLog(@"DPAWSIoTWebServer::socketDidCloseReadStream: %p", sock);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"DPAWSIoTWebServer::socketDidDisconnect: %p", sock);
    
    __block DPAWSIoTServerRunnable *runnable = nil;
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.fromSocket == sock) {
            runnable = serverRunnable;
            *stop = YES;
        }
    }];
    
    if (runnable) {
        [_connections removeObject:runnable];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"DPAWSIoTWebServer::socket:didConnectToHost: %@", host);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"DPAWSIoTWebServer::socket:didReadData:%p %@", sock, @([data length]));
    
    [_connections enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.fromSocket == sock) {
            [serverRunnable r:data];
            *stop = YES;
        }
    }];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSLog(@"shouldTimeoutReadWithTag: %@", @(tag));
    return 3;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    NSLog(@"shouldTimeoutWriteWithTag: %@", @(tag));
    return 3;
}


@end
