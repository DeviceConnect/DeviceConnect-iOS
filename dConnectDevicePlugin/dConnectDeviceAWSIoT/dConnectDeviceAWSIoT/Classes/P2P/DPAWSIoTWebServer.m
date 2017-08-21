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
    NSMutableArray *_serverRunnableList;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _serverRunnableList = [NSMutableArray array];
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
    
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableByConnectionId:connectionId];
    if (serverRunnable) {
        [serverRunnable.connection close];

        serverRunnable.connection = [self createP2PConnection:signaling delegate:self];
        if (!serverRunnable.connection) {
            [serverRunnable sendErrorResponse];
            [serverRunnable close];
            [_serverRunnableList removeObject:serverRunnable];
        }
    }
}

- (BOOL) hasConnectionId:(NSString *)signaling
{
    return [self findServerRunnableByConnectionId:[self getConnectionId:signaling]] != nil;
}

#pragma mark - Private Method

- (DPAWSIoTServerRunnable *) findServerRunnableByConnectionId:(int)connectionId
{
    __block DPAWSIoTServerRunnable *result = nil;
    
    [_serverRunnableList enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection.connectionId == connectionId) {
            result = serverRunnable;
            *stop = YES;
        }
    }];
    
    return result;
}

- (DPAWSIoTServerRunnable *) findServerRunnableByConn:(DPAWSIoTP2PConnection *)conn
{
    __block DPAWSIoTServerRunnable *result = nil;
    
    [_serverRunnableList enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.connection == conn) {
            result = serverRunnable;
            *stop = YES;
        }
    }];

    return result;
}

- (DPAWSIoTServerRunnable *) findServerRunnableBySocket:(GCDAsyncSocket *)socket
{
    __block DPAWSIoTServerRunnable *result = nil;
    
    [_serverRunnableList enumerateObjectsUsingBlock:^(DPAWSIoTServerRunnable *serverRunnable, NSUInteger idx, BOOL *stop) {
        if (serverRunnable.fromSocket == socket) {
            result = serverRunnable;
            *stop = YES;
        }
    }];
    
    return result;
}

#pragma mark - DPAWSIoTP2PConnectionDelegate

- (void) connection:(DPAWSIoTP2PConnection *)conn didRetrievedAddress:(NSString *)address port:(int)port
{
    NSData *data = [DPAWSIoTP2PManager createSignaling:conn.connectionId address:address port:port];
    NSString *signaling = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([_delegate respondsToSelector:@selector(server:didNotifiedSignaling:)]) {
        [_delegate server:self didNotifiedSignaling:signaling];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didConnectedAddress:(NSString *)address port:(int)port
{
    if ([_delegate respondsToSelector:@selector(serverDidConnected:)]) {
        [_delegate serverDidConnected:self];
    }
    
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableByConn:conn];
    if (serverRunnable) {
        [serverRunnable.fromSocket readDataWithTimeout:5 tag:0];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didReceivedData:(const char *)data length:(int)length
{
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableByConn:conn];
    if (serverRunnable) {
        [serverRunnable w:[NSData dataWithBytes:data length:length]];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didDisconnetedAdderss:(NSString *)address port:(int)port
{
    if ([_delegate respondsToSelector:@selector(serverDidDisconnected:)]) {
        [_delegate serverDidDisconnected:self];
    }

    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableByConn:conn];
    if (serverRunnable) {
        [_serverRunnableList removeObject:serverRunnable];
    }
}

- (void) connectionDidTimeout:(DPAWSIoTP2PConnection *)conn
{
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableByConn:conn];
    if (serverRunnable) {
        [_serverRunnableList removeObject:serverRunnable];
        [serverRunnable sendErrorResponse];
        [serverRunnable close];
    }

    if ([_serverRunnableList count] == 0) {
        [self stop];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    
    DPAWSIoTServerRunnable *serverRunnable = [DPAWSIoTServerRunnable new];
    serverRunnable.host = self.host;
    serverRunnable.port = self.port;
    serverRunnable.fromSocket = newSocket;
    serverRunnable.connection = [DPAWSIoTP2PConnection new];
    serverRunnable.connection.delegate = self;
    [serverRunnable.connection open];
    [_serverRunnableList addObject:serverRunnable];
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableBySocket:sock];
    if (serverRunnable) {
        [_serverRunnableList removeObject:serverRunnable];
        [serverRunnable close];
    }
    
    if ([_serverRunnableList count] == 0) {
        [self stop];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableBySocket:sock];
    if (serverRunnable) {
        [serverRunnable r:data];
    }
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
   DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableBySocket:sock];
    if (serverRunnable) {
        if (![serverRunnable isRetry]) {
            [serverRunnable close];
        }
    }
    return 3;
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length
{
    DPAWSIoTServerRunnable *serverRunnable = [self findServerRunnableBySocket:sock];
    if (serverRunnable) {
        if (![serverRunnable isRetry]) {
            [serverRunnable close];
        }
    }
    return 3;
}

@end
