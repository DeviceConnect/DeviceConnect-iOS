//
//  DPHostSimpleHttpServer.m
//  dConnectDeviceDPHost
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPHostSimpleHttpServer.h"
#import "GCDAsyncSocket.h"
#import <mach/mach_time.h>


// HTTP通信のタイムアウトを定義
#define HTTP_TIMEOUT 3.0


/*!
 @brief 現在時刻をミリ秒で取得します.
 @retval 現在時刻
 */
static uint64_t getUptimeInMilliseconds()
{
    const int64_t kOneMillion = 1000 * 1000;
    static mach_timebase_info_data_t s_timebase_info;
    
    if (s_timebase_info.denom == 0) {
        (void) mach_timebase_info(&s_timebase_info);
    }
    
    // mach_absolute_time() returns billionth of seconds,
    // so divide by one million to get milliseconds
    return ((mach_absolute_time() * s_timebase_info.numer) / (kOneMillion * s_timebase_info.denom));
}


#pragma mark - DPHostConnection


@interface DPHostConnection : NSObject

@property (nonatomic, strong) GCDAsyncSocket *fromSocket;
@property (nonatomic) BOOL ready;
@property (nonatomic) uint64_t startTime;

@end


@implementation DPHostConnection

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.fromSocket = nil;
        self.ready = NO;
        self.startTime = 0;
    }
    return self;
}

@end


#pragma mark - DPHostSimpleHttpServer


@interface DPHostSimpleHttpServer () <GCDAsyncSocketDelegate>

@end


@implementation DPHostSimpleHttpServer {
    GCDAsyncSocket *_listenSocket;
    NSMutableArray *_connections;
    NSString *_boundary;
    NSString *_path;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.listenPort = 8080;
        self.timeSlice = 100;

        _listenSocket = nil;
        _connections = [NSMutableArray array];
        _boundary = @"0123456789ABCDEF";
        _path = [[NSUUID UUID] UUIDString];
    }
    return self;
}


#pragma mark - GCDAsyncSocketDelegate Methods

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    DPHostConnection *connection = [DPHostConnection new];
    connection.fromSocket = newSocket;
    connection.ready = NO;
    
    @synchronized(self) {
        [_connections addObject:connection];
    }

    [newSocket readDataWithTimeout:HTTP_TIMEOUT tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    @synchronized(self) {
        DPHostConnection *connection = [self foundConnection:sock];
        if (connection) {
            [_connections removeObject:connection];
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *headerData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([self parseHttpHeader:headerData]) {
        [self writeHeadersToSocket:sock];
    } else {
        [sock disconnect];
    }
}

#pragma mark - Private Methods

- (BOOL) parseHttpHeader:(NSString *)header
{
    NSString *method;
    NSString *path;
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    NSArray* lines = [header componentsSeparatedByString:@"\r\n"];
    int lineIndex = 0;
    
    if (lines.count == 0) {
        return NO;
    }
    
    NSArray *keyValue = [lines[0] componentsSeparatedByString:@" "];
    if (keyValue && keyValue.count >= 2) {
        method = [keyValue[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        path = [keyValue[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    if (!method || !path) {
        return NO;
    }

    if (![[method lowercaseString] isEqualToString:@"get"]) {
        return NO;
    }
    
    if (![[path substringFromIndex:1] isEqualToString:_path]) {
        return NO;
    }
    
    // 各ヘッダーを格納
    for (; lineIndex < lines.count; lineIndex++) {
        NSString *line = lines[lineIndex];
        NSArray *keyValue = [line componentsSeparatedByString:@":"];
        if (keyValue && keyValue.count == 2) {
            NSString *key =[keyValue[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *value = [keyValue[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            headers[key] = value;
        }
    }
    
    return YES;
}

- (void) writeHeadersToSocket:(GCDAsyncSocket *)socket
{
    NSString *str = @"HTTP/1.0 200 OK\r\n"
                    "Server: DPHostSimpleHttpServer\r\n"
                    "Connection: close\r\n"
                    "Max-Age: 0\r\n"
                    "Expires: 0\r\n"
                    "Cache-Control: no-store, no-cache, must-revalidate, pre-check=0, post-check=0, max-age=0\r\n"
                    "Pragma: no-cache\r\n"
                    "Content-Type: multipart/x-mixed-replace; boundary=%@\r\n"
                    "\r\n"
                    "--%@\r\n";
    
    NSString *string = [NSString stringWithFormat:str, _boundary, _boundary];
    NSData *headerData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:headerData withTimeout:HTTP_TIMEOUT tag:0];
    
    DPHostConnection *conn = [self foundConnection:socket];
    if (conn) {
        conn.ready = YES;
    }
}

- (void) sendImageData:(NSData *)imageData toSocket:(GCDAsyncSocket *)socket
{
    NSString *str = @"--%@\r\n"
                    "Content-Type: %@\r\n"
                    "Content-Length: %d\r\n"
                    "\r\n";
    NSString *string = [NSString stringWithFormat:str, _boundary, @"image/jpg", imageData.length];
    NSData *headerData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *endData = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:headerData withTimeout:HTTP_TIMEOUT tag:0];
    [socket writeData:imageData withTimeout:HTTP_TIMEOUT tag:0];
    [socket writeData:endData withTimeout:HTTP_TIMEOUT tag:0];
    
}

- (DPHostConnection *) foundConnection:(GCDAsyncSocket *)socket
{
    __block DPHostConnection *result = nil;
    
    [_connections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DPHostConnection *connection, NSUInteger idx, BOOL *stop) {
        if ([connection.fromSocket.description isEqualToString:socket.description]) {
            result = connection;
            *stop = YES;
        }
    }];
    
    return result;
}


#pragma mark - Public Methods

- (BOOL) start
{
    NSError *error = nil;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
    [_listenSocket acceptOnPort:self.listenPort error:&error];
    if (error) {
        NSLog(@"Failed to start a server. error=%@", error);
        [self stop];
        return NO;
    }
    return YES;
}

- (void) stop
{
    [_listenSocket setDelegate:nil delegateQueue:NULL];
    [_listenSocket disconnect];
    _listenSocket = nil;
}

- (NSString *) getUrl
{
    NSString *str = @"http://localhost:%d/%@";
    return  [NSString stringWithFormat:str, self.listenPort, _path];
}

- (void) offerData:(NSData *)data
{
    __block typeof(self) weakSelf = self;

    [_connections enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DPHostConnection *connection, NSUInteger idx, BOOL *stop) {
        uint64_t elapsed = getUptimeInMilliseconds() - connection.startTime;
        if (connection.ready && elapsed > weakSelf.timeSlice) {
            [weakSelf sendImageData:data toSocket:connection.fromSocket];
            connection.startTime = getUptimeInMilliseconds();
        }
    }];
}

@end
