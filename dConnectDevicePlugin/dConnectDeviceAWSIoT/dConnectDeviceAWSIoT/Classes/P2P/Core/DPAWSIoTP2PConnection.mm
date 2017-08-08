//
//  DPAWSIoTP2PConnection.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTP2PConnection.h"
#import "DPAWSIoTRelayServer.h"
#import "DPAWSIoTRelayClient.h"
#import "DPAWSIoTP2PUtil.h"

@interface DPAWSIoTP2PConnection () <DPAWSIoTRelayServerDelegate, DPAWSIoTRelayClientDelegate>

@end


@implementation DPAWSIoTP2PConnection {
    DPAWSIoTRelayServer *_server;
    DPAWSIoTRelayClient *_client;
    AWSIoTUtilTimerCancelBlock _timeoutCancelBlock;
}

+ (int) generateConnectionId
{
    return arc4random();
}

#pragma mark - Public Method

- (instancetype) init
{
    self = [super init];
    if (self) {
        _connectionId = [DPAWSIoTP2PConnection generateConnectionId];
    }
    return self;
}

- (instancetype) initWithConnectionId:(int)connectionId
{
    self = [super init];
    if (self) {
        _connectionId = connectionId;
    }
    return self;
}

- (void) open
{
    [self startTimeoutTimer];

    _server = [DPAWSIoTRelayServer new];
    _server.delegate = self;
    [_server open];
}

- (BOOL) connectToAddress:(NSString *)address port:(int)port
{
    if (!address || port == 0) {
        return NO;
    }
    _client = [DPAWSIoTRelayClient new];
    _client.delegate = self;
    return [_client connect:address port:port];
}

- (void) sendData:(const char *)data length:(int)length;
{
    if (_client) {
        [_client sendData:data length:length];
    }
    if (_server) {
        [_server sendData:data length:length];
    }
}

- (void) sendData:(const char *)data offset:(int)offset length:(int)length
{
    if (_client) {
        [_client sendData:data offset:offset length:length];
    }
    if (_server) {
        [_server sendData:data offset:offset length:length];
    }
}

- (void) close
{
    [self closeClient];
    [self closeServer];
}


#pragma mark - Private Method

- (void) closeClient
{
    if (_client) {
        [_client close];
    }
    _client = nil;
}

- (void) closeServer
{
    if (_server) {
        [_server close];
    }
    _server = nil;
}

- (void) startTimeoutTimer
{
    if (_timeoutCancelBlock) {
        _timeoutCancelBlock();
    }
    
    __weak typeof(self) weakSelf = self;

    _timeoutCancelBlock = [DPAWSIoTP2PUtil asyncAfterDelay:30 block:^{
        [weakSelf onTimeout];
    }];
}

- (void) onTimeout
{
    if ([_delegate respondsToSelector:@selector(connectionDidTimeout:)]) {
        [_delegate connectionDidTimeout:self];
    }

    [self close];
}

#pragma mark - DPAWSIoTRelayServerDelegate

- (void) didRetrievedAddress:(NSString *)address port:(int)port
{
    if ([_delegate respondsToSelector:@selector(connection:didRetrievedAddress:port:)]) {
        [_delegate connection:self didRetrievedAddress:address port:port];
    }
}

#pragma mark - DPAWSIoTSocketTaskDelegate

- (void) didNotConnected
{
    if (_timeoutCancelBlock) {
        _timeoutCancelBlock();
        _timeoutCancelBlock = nil;
    }
    
    if ([_delegate respondsToSelector:@selector(connectionDidNotConnect:)]) {
        [_delegate connectionDidNotConnect:self];
    }
}

- (void) didConnectedAddress:(NSString *)address port:(int)port
{
    if (_timeoutCancelBlock) {
        _timeoutCancelBlock();
        _timeoutCancelBlock = nil;
    }

    if ([_delegate respondsToSelector:@selector(connection:didConnectedAddress:port:)]) {
        [_delegate connection:self didConnectedAddress:address port:port];
    }
}

- (void) didReceivedData:(const char *)data length:(int)length
{
    if ([_delegate respondsToSelector:@selector(connection:didReceivedData:length:)]) {
        [_delegate connection:self didReceivedData:data length:length];
    }
}

- (void) didDisconnetedAdderss:(NSString *)address port:(int)port
{
    if ([_delegate respondsToSelector:@selector(connection:didDisconnetedAdderss:port:)]) {
        [_delegate connection:self didDisconnetedAdderss:address port:port];
    }
}

@end
