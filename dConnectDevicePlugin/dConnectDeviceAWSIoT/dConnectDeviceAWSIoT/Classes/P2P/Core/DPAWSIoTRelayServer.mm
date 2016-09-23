//
//  DPAWSIoTRelayServer.mm
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTRelayServer.h"
#import "DPAWSIoTStunClient.h"

#import <unistd.h>
#import <cstdlib>
#import <cstring>
#import <netdb.h>
#import <iostream>


using namespace std;


@interface DPAWSIoTRelayServer ()
@property (nonatomic) NSMutableArray *sockets;
@end


@implementation DPAWSIoTRelayServer {
    BOOL _closeFlag;
    DPAWSIoTStunClient *_stun;
    UDTSOCKET _serverSocket;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _closeFlag = NO;
        _sockets = [NSMutableArray array];
        _stun = nil;
    }
    return self;
}

- (void) open
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _stun = [DPAWSIoTStunClient new];
        [_stun bindingRequest:^(NSString *address, int port) {
            if (address) {
                [weakSelf executeAddress:address port:port];
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(didNotConnected)]) {
                    [weakSelf.delegate didNotConnected];
                }
            }
        }];
    });
}

- (void) sendData:(NSData *)data
{
    __weak NSData *weakData = data;
    
    [_sockets enumerateObjectsUsingBlock:^(DPAWSIoTSocketTask *task, NSUInteger idx, BOOL *stop) {
        [task sendData:(const char *)weakData.bytes length:(int)weakData.length];
    }];
}

- (void) sendData:(const char *)data length:(int)length
{
    [_sockets enumerateObjectsUsingBlock:^(DPAWSIoTSocketTask *task, NSUInteger idx, BOOL *stop) {
        [task sendData:(const char *)data length:(int)length];
    }];
}

- (void) sendData:(const char *)data offset:(int)offset length:(int)length {
    [_sockets enumerateObjectsUsingBlock:^(DPAWSIoTSocketTask *task, NSUInteger idx, BOOL *stop) {
        [task sendData:(const char *)data offset:offset length:(int)length];
    }];
}

- (void) close
{
    if (_closeFlag) {
        return;
    }
    _closeFlag = YES;
    
    [_sockets enumerateObjectsUsingBlock:^(DPAWSIoTSocketTask *task, NSUInteger idx, BOOL *stop) {
        [task close];
    }];
    [_sockets removeAllObjects];
    
    UDT::close(_serverSocket);
}

#pragma mark - Private Method

- (void) executeAddress:(NSString *)address port:(int)port
{
    if ([self.delegate respondsToSelector:@selector(didRetrievedAddress:port:)]) {
        [self.delegate didRetrievedAddress:address port:port];
    }

    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UDT::startup();
        if (![weakSelf execute:port]) {
            if ([weakSelf.delegate respondsToSelector:@selector(didNotConnected)]) {
                [weakSelf.delegate didNotConnected];
            }
        }
        UDT::cleanup();
    });
}

- (int) execute:(int)port
{
    addrinfo hints;
    addrinfo* res;
    
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_flags = AI_PASSIVE;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    
    NSString *service = [NSString stringWithFormat:@"%d", port];

    if (0 != getaddrinfo(NULL, [service UTF8String], &hints, &res)) {
        return 0;
    }
    
    _serverSocket = UDT::socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    
    if (UDT::ERROR == UDT::bind(_serverSocket, res->ai_addr, res->ai_addrlen)) {
        NSLog(@"DPAWSIoTRelayServer: bind: %s", UDT::getlasterror().getErrorMessage());
        return 0;
    }
    
    freeaddrinfo(res);
    
    if (UDT::ERROR == UDT::listen(_serverSocket, 10)) {
        NSLog(@"DPAWSIoTRelayServer: listen: %s", UDT::getlasterror().getErrorMessage());
        return 0;
    }
    
    sockaddr_storage clientaddr;
    int addrlen = sizeof(clientaddr);
    
    while (!_closeFlag) {
        UDTSOCKET socket = UDT::accept(_serverSocket, (sockaddr *)&clientaddr, &addrlen);
        if (UDT::INVALID_SOCK == socket) {
            NSLog(@"DPAWSIoTRelayServer: accept: %s", UDT::getlasterror().getErrorMessage());
            return 0;
        }
        if (_closeFlag) {
            return 1;
        }
        
        char clienthost[NI_MAXHOST];
        char clientservice[NI_MAXSERV];
        getnameinfo((sockaddr *)&clientaddr, addrlen, clienthost, sizeof(clienthost), clientservice, sizeof(clientservice), NI_NUMERICHOST|NI_NUMERICSERV);
        
        DPAWSIoTSocketTask *task = [[DPAWSIoTSocketTask alloc] initWithSocket:socket];
        task.delegate = _delegate;
        [task setAddress:[NSString stringWithCString:clienthost encoding:NSUTF8StringEncoding]];
        [task setPort:atoi(clientservice)];
        [_sockets addObject:task];
        
        __weak DPAWSIoTSocketTask *weakTask = task;
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakTask execute];
            [weakSelf.sockets removeObject:weakTask];
        });
    }
    
    return 1;
}

@end
