//
//  DPAWSIoTRelayClient.mm
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTRelayClient.h"
#import <unistd.h>
#import <cstdlib>
#import <cstring>
#import <netdb.h>
#import <iostream>

using namespace std;

@implementation DPAWSIoTRelayClient {
    DPAWSIoTSocketTask *_socket;
    BOOL _closeFlag;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _closeFlag = NO;
        _socket = nil;
    }
    return self;
}

- (BOOL) connect:(NSString *)address port:(int)port
{
    UDT::startup();
    return [self execute:address port:port];
}

- (void) sendData:(NSData *)data
{
    if (_socket) {
        [_socket sendData:(const char *)data.bytes length:(int)data.length];
    }
}

- (void) sendData:(const char *)data length:(int)length
{
    if (_socket) {
        [_socket sendData:data length:length];
    }
}

- (void) sendData:(const char *)data offset:(int)offset length:(int)length
{
    if (_socket) {
        [_socket sendData:data offset:offset length:length];
    }
}

- (void) close
{
    if (_closeFlag) {
        return;
    }
    _closeFlag = YES;
    
    [_socket close];
    _socket = nil;
}

#pragma mark - Private Method

- (int) execute:(NSString *)address port:(int)port
{
    struct addrinfo hints, *local, *peer;
    
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_flags = AI_PASSIVE;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    
    NSString *service = [NSString stringWithFormat:@"%d", port];
    
    if (0 != getaddrinfo(NULL, [service UTF8String], &hints, &local)) {
        NSLog(@"DPAWSIoTRelayClient: incorrect network address.");
        return 0;
    }
    
    UDTSOCKET socket = UDT::socket(local->ai_family, local->ai_socktype, local->ai_protocol);
    
    freeaddrinfo(local);
    
    if (0 != getaddrinfo([address UTF8String], [service UTF8String], &hints, &peer)) {
        NSLog(@"DPAWSIoTRelayClient: incorrect network address.");
        return 0;
    }
    
    if (UDT::ERROR == UDT::connect(socket, peer->ai_addr, peer->ai_addrlen)) {
        NSLog(@"DPAWSIoTRelayClient: connect: %s", UDT::getlasterror().getErrorMessage());
        return 0;
    }
    freeaddrinfo(peer);
    
    _socket = [[DPAWSIoTSocketTask alloc] initWithSocket:socket];
    _socket.delegate = _delegate;
    [_socket setAddress:address];
    [_socket setPort:port];
    
    __weak DPAWSIoTSocketTask *weakTask = _socket;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakTask execute];
        UDT::cleanup();
    });
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf monitor:socket];
    });
    
    return 1;
}

- (void) monitor:(UDTSOCKET) socket
{
    UDT::TRACEINFO perf;
    
    while (!_closeFlag) {
        [NSThread sleepForTimeInterval:1];
        
        if (UDT::ERROR == UDT::perfmon(socket, &perf)) {
            NSLog(@"DPAWSIoTRelayClient: perfmon: %s", UDT::getlasterror().getErrorMessage());
            break;
        }
    }
}


@end
