/**
 * @file  UdpRequest.m
 * @brief CameraRemoteSampleApp
 *
 * Copyright 2014 Sony Corporation
 */

#import "UdpRequest.h"

static id<UdpRequestDelegate> _udpReqDelegate;
static NSMutableArray *_deviceUuidList;

@implementation UdpRequest {
    CFSocketRef _cfSocketSend;
    CFSocketRef _cfSocketListen;
    NSTimer *_timer;
    BOOL _didReceiveSsdp;
}

int _SSDP_RECEIVE_TIMEOUT = 10; // seconds
int _SSDP_PORT = 1900;
int _SSDP_MX = 1;
NSString *_SSDP_ADDR = @"239.255.255.250";
NSString *_SSDP_ST = @"urn:schemas-sony-com:service:ScalarWebAPI:1";

- (void)search:(id<UdpRequestDelegate>)delegate
{
    @synchronized(self)
    {
        if (_timer && [_timer isValid]) {
            NSLog(@"UdpRequest invalidate timer.");
            [self releaseSocket];
            [_timer invalidate];
        }
        _deviceUuidList = [[NSMutableArray alloc] init];
        _udpReqDelegate = delegate;
        _didReceiveSsdp = NO;
        _timer = [NSTimer scheduledTimerWithTimeInterval:_SSDP_RECEIVE_TIMEOUT
                                                  target:self
                                                selector:@selector(cancelSearch)
                                                userInfo:nil
                                                 repeats:NO];
    }
    [self listen];
}

- (void)cancelSearch
{
    @synchronized(self)
    {
        [self releaseSocket];
        if (!_didReceiveSsdp) {
            [_udpReqDelegate didReceiveDdUrl:nil];
        }
        [_timer invalidate];
    }
}

- (void)releaseSocket
{
    @synchronized(self)
    {
        if (_cfSocketSend && CFSocketIsValid(_cfSocketSend)) {
            CFSocketInvalidate(_cfSocketSend);
            CFRelease(_cfSocketSend);
        }
        _cfSocketSend = NULL;
        if (_cfSocketListen && CFSocketIsValid(_cfSocketListen)) {
            CFSocketInvalidate(_cfSocketListen);
            CFRelease(_cfSocketListen);
        }
        _cfSocketListen = NULL;
    }
}

- (void)listen
{
    @synchronized(self)
    {
        _cfSocketSend = [self initSocket:_cfSocketSend];
        if (!_cfSocketSend) {
            return;
        }

        // Send from socket
        NSString *message = [NSString
            stringWithFormat:@"M-SEARCH * HTTP/1.1\r\n" @"HOST:%@:%d\r\n"
                             @"MAN:\"ssdp:discover\"\r\n" @"MX:%d\r\n"
                             @"ST:%@\r\n\r\n",
                             _SSDP_ADDR, _SSDP_PORT, _SSDP_MX, _SSDP_ST];
        CFDataRef data = CFDataCreate(
            NULL, (const UInt8 *)[message UTF8String],
            [message lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);

        /* Set the port and address we want to send to */
        struct sockaddr_in addr;
        memset(&addr, 0, sizeof(addr));
        addr.sin_len = sizeof(addr);
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = inet_addr([_SSDP_ADDR UTF8String]);
        addr.sin_port = htons(_SSDP_PORT);

        NSData *address = [NSData dataWithBytes:&addr length:sizeof(addr)];

//        NSLog(@"UdpRequest Initialising socket for listening");
        _cfSocketListen = [self initSocket:_cfSocketListen];
        if (!_cfSocketListen) {
            CFRelease(data);
            return;
        }
        _cfSocketListen = [self setReusePortOption:_cfSocketListen];
        if (!_cfSocketListen) {
            CFRelease(data);
            return;
        }

        if (CFSocketSendData(_cfSocketSend, (__bridge CFDataRef)address, data,
                             0.0) == kCFSocketSuccess) {
            NSLog(@"UdpRequest callCFSocket Sending data");
        }

        /* Set the port and address we want to listen on */
        if (CFSocketSetAddress(_cfSocketListen,
                               (__bridge CFDataRef)(address)) !=
            kCFSocketSuccess) {
            NSLog(@"UdpRequest callCFSocket CFSocketSetAddress() failed. "
                  @"[errno %d]",
                  errno);
        }

        // Listen from socket
        CFRunLoopSourceRef cfSourceSend =
            CFSocketCreateRunLoopSource(kCFAllocatorDefault, _cfSocketSend, 0);
        CFRunLoopSourceRef cfSourceListen = CFSocketCreateRunLoopSource(
            kCFAllocatorDefault, _cfSocketListen, 0);

        if (cfSourceSend == NULL && cfSourceListen == NULL) {
//            NSLog(@"UdpRequest callCFSocket CFRunLoopSourceRef is null");
            CFRelease(_cfSocketSend);
            CFRelease(_cfSocketListen);
            CFRelease(data);
            return;
        }

        if (cfSourceSend != NULL) {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSourceSend,
                               kCFRunLoopDefaultMode);
            CFRelease(cfSourceSend);
        }
        if (cfSourceListen != NULL) {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), cfSourceListen,
                               kCFRunLoopDefaultMode);
//            NSLog(@"UdpRequest callCFSocket Socket listening");
            CFRelease(cfSourceListen);
        }

        CFRelease(data);
    }
    CFRunLoopRun();
//    NSLog(@"UdpRequest callCFSocket CFRunLoopRun finish");
}

/*
 * Function for initializing socket for SSDP
 */
- (CFSocketRef)initSocket:(CFSocketRef)socket
{
    CFSocketContext socketContext = {0, (__bridge void *)(self), NULL, NULL,
                                     NULL};
    socket = CFSocketCreate(NULL, PF_INET, SOCK_DGRAM, IPPROTO_UDP,
                            kCFSocketAcceptCallBack | kCFSocketDataCallBack,
                            (CFSocketCallBack)receiveData, &socketContext);
    if (socket == NULL) {
//        NSLog(@"UdpRequest UDP socket could not be created\n");
        return socket;
    }

    CFSocketSetSocketFlags(socket, kCFSocketCloseOnInvalidate);

    struct ip_mreq mreq;
    mreq.imr_multiaddr.s_addr = inet_addr([_SSDP_ADDR UTF8String]);
    mreq.imr_interface.s_addr = inet_addr([[self getIPAddress] UTF8String]);

    if (setsockopt(CFSocketGetNative(socket), IPPROTO_IP, IP_ADD_MEMBERSHIP,
                   (const void *)&mreq, sizeof(struct ip_mreq))) {
//        NSLog(@"UdpRequest setsockopt IP_ADD_MEMBERSHIP failed. [errno %d]",
//              errno);
        return NULL;
    }
    return socket;
}

- (CFSocketRef)setReusePortOption:(CFSocketRef)socket
{
    int on = 1;
    if (setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEPORT, &on,
                   sizeof(on))) {
//        NSLog(@"UdpRequest setsockopt SO_REUSEPORT failed. [errno %d]", errno);
        return NULL;
    }
    if (setsockopt(CFSocketGetNative(socket), SOL_SOCKET, SO_REUSEADDR, &on,
                   sizeof(on))) {
//        NSLog(@"UdpRequest setsockopt SO_REUSEADDR failed. [errno %d]", errno);
        return NULL;
    }
    return socket;
}

void receiveData(CFSocketRef socket, CFSocketCallBackType type,
                 CFDataRef address, const void *data, void *info)
{
    [(__bridge UdpRequest *)info receiveData:socket
                                        type:type
                                     address:address
                                        data:(__bridge NSData *)data];
}

- (void)receiveData:(CFSocketRef)socket
               type:(CFSocketCallBackType)type
            address:(CFDataRef)address
               data:(NSData *)data
{
    if (data) {
        NSString *response =
            [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        NSLog(@"UdpRequest CFSocket receiveData response = %@", response);

        NSString *ddUrl = [self parseDdUrl:response];
        ddUrl = [ddUrl stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        NSString *uuid = [self parseUuid:response];
        uuid = [uuid stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (!ddUrl || !uuid) {
//            NSLog(@"UdpRequest CFSocket receiveData ddUrl or uuid is nil.");
            return;
        }
//        NSLog(@"UdpRequest CFSocket receiveData didReceiveDdUrl = %@", ddUrl);

        @synchronized(self)
        {
            if (![_deviceUuidList containsObject:uuid]) {
                [_deviceUuidList addObject:uuid];
//                NSLog(@"UdpRequest CFSocket receiveData uuid = %@", uuid);
                if ([_timer isValid]) {
                    [_udpReqDelegate didReceiveDdUrl:ddUrl];
                    _didReceiveSsdp = YES;
                }
            }
        }

        @synchronized(self)
        {
            if (CFSocketIsValid(socket)) {
                CFSocketInvalidate(socket);
            }
        }
    }
}

- (NSString *)parseDdUrl:(NSString *)response
{
    NSString *ret;
    if (!response) {
        return nil;
    }
    NSArray *first = [response componentsSeparatedByString:@"LOCATION:"];
    if (first != nil && first.count == 2) {
        NSArray *second = [first[1] componentsSeparatedByString:@"\r\n"];
        if (second != nil && second.count >= 2) {
            if (![second[0] isEqualToString:@""]) {
                ret = second[0];
            }
        }
    }
    return ret;
}

- (NSString *)parseUuid:(NSString *)response
{
    NSString *ret;
    if (!response) {
        return nil;
    }
    NSArray *first = [response componentsSeparatedByString:@"USN:"];
    if (first != nil && first.count == 2) {
        NSArray *second = [first[1] componentsSeparatedByString:@":"];
        if (second != nil && second.count >= 2) {
            if (![second[1] isEqualToString:@""]) {
                ret = second[1];
            }
        }
    }
    return ret;
}

- (NSString *)getIPAddress
{
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                NSLog(@"UdpRequest getIPAddress NIF = %@",
                      @(temp_addr->ifa_name));
                // Check if interface is en0 which is the wifi connection on the
                // iPhone
                if ([@(temp_addr->ifa_name) isEqualToString:@"en0"]) {
                    address = @(inet_ntoa(
                        ((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr));
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
//    NSLog(@"UdpRequest getIPAddress = %@", address);
    return address;
}

@end
