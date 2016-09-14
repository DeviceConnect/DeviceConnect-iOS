//
//  DPAWSIoTUDPConnection.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTUDPConnection.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/types.h>


@interface DPAWSIoTUDPConnection ()
@property (nonatomic) BOOL isLoopStop;
@end


@implementation DPAWSIoTUDPConnection {
    CFSocketRef _socket;
    int _port;
    
    NSString *_destAddress;
    int _destPort;
    
    CFRunLoopRef _runLoop;
}


- (instancetype) initWithPort:(int)port
{
    self =[super init];
    if (self) {
        self.isLoopStop = YES;
        _port = port;
        _timeout = -1;
    }
    return self;
}

- (void) open
{
    if (!self.isLoopStop) {
        return;
    }
    self.isLoopStop = NO;
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf recv];
    });
}

- (BOOL) sendData:(const char *)data length:(int)length to:(NSString *)address port:(int)port
{
    if (!_socket) {
        return NO;
    }
    
    if (!address || !port) {
        return NO;
    }
    
    if (_isLoopStop) {
        return NO;
    }
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = inet_addr([address UTF8String]);
    
    CFDataRef destData = CFDataCreate(NULL, (unsigned char *)&addr, sizeof(addr));
    CFDataRef msgData = CFDataCreate(NULL, (const UInt8 *)data, length);
    CFSocketError err = CFSocketSendData(_socket, destData, msgData, 4);
    return (err == kCFSocketSuccess);
}

- (BOOL) sendData:(const char *)data length:(int)length
{
    return [self sendData:data length:length to:_destAddress port:_destPort];
}

- (void) close
{
    self.isLoopStop = YES;
    CFRunLoopStop(_runLoop);
}

#pragma mark - Private Method

- (void) receivedData:(NSData *)data address:(NSString *)address port:(int)port
{
    if ([self.delegate respondsToSelector:@selector(didReceivedData:address:port:)]) {
        [self.delegate didReceivedData:data address:address port:port];
    }
}

#pragma mark - static Method

static void myCallbackFunc(CFSocketRef socket, CFSocketCallBackType type, CFDataRef addr, const void *pData, void *pInfo)
{
    if (CFSocketIsValid(socket) == FALSE) {
        CFRunLoopStop(CFRunLoopGetCurrent());
    } else if (type == kCFSocketDataCallBack) {
        DPAWSIoTUDPConnection *_server = (__bridge DPAWSIoTUDPConnection *) pInfo;
        if (!_server.isLoopStop) {
            NSData *data = (__bridge NSData *)pData;
            struct sockaddr_in *from = (struct sockaddr_in *) CFDataGetBytePtr(addr);
            NSString *address = [NSString stringWithCString:inet_ntoa(from->sin_addr) encoding:NSUTF8StringEncoding];
            int port = ntohs(from->sin_port);
            [_server receivedData:data address:address port:port];
        }
    }
}

- (void) recv
{
    CFSocketContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    _socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_DGRAM, IPPROTO_UDP,
                             kCFSocketDataCallBack, (CFSocketCallBack) myCallbackFunc, &context);
    if (_socket == nil) {
        if ([self.delegate respondsToSelector:@selector(didNotConnect)]) {
            [self.delegate didNotConnect];
        }
        return;
    }
    
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    addr.sin_addr.s_addr = INADDR_ANY;
    addr.sin_len = sizeof(addr);

    CFDataRef addrData = CFDataCreateWithBytesNoCopy(NULL, (UInt8 *)&addr, sizeof(addr), kCFAllocatorNull);
    CFSocketError serr = CFSocketSetAddress(_socket, addrData);
    if (serr == kCFSocketSuccess) {
        __weak typeof(self) weakSelf = self;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(didConnect)]) {
                [weakSelf.delegate didConnect];
            }
        });

        _runLoop = CFRunLoopGetCurrent();

        CFRunLoopSourceRef src = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socket, 0);
        CFRunLoopAddSource(_runLoop, src, kCFRunLoopCommonModes);
        CFRunLoopRun();
        CFRelease(src);

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(didDisconnect)]) {
                [weakSelf.delegate didDisconnect];
            }
        });
    } else {
        if ([self.delegate respondsToSelector:@selector(didNotConnect)]) {
            [self.delegate didNotConnect];
        }
    }
    CFSocketInvalidate(_socket);
    
    CFRelease(addrData);
    CFRelease(_socket);
    
    _socket = nil;
}

@end
