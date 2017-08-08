//
//  DPAWSIoTWebClient.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTWebClient.h"
#import "DPAWSIoTP2PConnection.h"
#import "DPAWSIoTSocketAdapter.h"
#import "DPAWSIoTHttpSocketAdapter.h"
#import "DPAWSIoTFileSocketAdapter.h"


@interface DPAWSIoTWebClient () <DPAWSIoTP2PConnectionDelegate>

@end


@implementation DPAWSIoTWebClient {
    DPAWSIoTP2PConnection *_connection;
    DPAWSIoTSocketAdapter *_socketAdapter;
    
    NSMutableData *_httpHeaderData;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _httpHeaderData = [NSMutableData data];
    }
    return self;
}

- (void) connect:(NSString *)address port:(int)port
{
    _connection = [DPAWSIoTP2PConnection new];
    _connection.delegate = self;
    [_connection connectToAddress:address port:port];
}

- (void) close
{
    if (_connection) {
        [_connection close];
        _connection = nil;
    }
    
    if (_socketAdapter) {
        [_socketAdapter closeSocket];
        _socketAdapter = nil;
    }
}

- (void) didReceivedSignaling:(NSString *)signaling
{

    _connection = [self createP2PConnection:signaling delegate:self];
    if (!_connection) {
        __weak typeof(self) weakSelf = self;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _connection = [DPAWSIoTP2PConnection new];
            _connection.delegate = weakSelf;
            _connection.connectionId = [weakSelf getConnectionId:signaling];
            [_connection open];
        });
    }
}

#pragma mark - Private Method

- (BOOL) openSocket:(const char *)data length:(int)length
{
    NSString *address = nil;
    int port = 0;
    int headerSize = [self findHeaderEnd:data length:length];
    if (headerSize == 0) {
        NSLog(@"DPAWSIoTWebClient::openSocket: Not found the http header.");
        return NO;
    }
    
    NSString *http =  [[NSString alloc] initWithBytes:data length:headerSize encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:http];
    NSCharacterSet *chSet = [NSCharacterSet newlineCharacterSet];
    if (!scanner) {
        NSLog(@"DPAWSIoTWebClient::openSocket: No scanner.");
        return NO;
    }
    
    NSString *requestLine;
    [scanner scanUpToCharactersFromSet:chSet intoString:&requestLine];

    NSArray *array = [requestLine componentsSeparatedByString:@" "];
    if ([array count] <= 2) {
        NSLog(@"DPAWSIoTWebClient::openSocket: No http method.");
        return NO;
    }

    // iOS内のファイルアクセスをするための処理
    NSString *uri = [array objectAtIndex:1];
    if ([uri hasPrefix:@"/contentProvider"]) {
        NSURL *url =  [NSURL URLWithString:uri];
        NSData *data = [self.dataSource getData:[url query]];
        
        _socketAdapter = [[DPAWSIoTFileSocketAdapter alloc] initWithData:data timeout:30];
        _socketAdapter.connection = _connection;
        return [_socketAdapter openSocket];
    }
    
    NSString *line;
    while (![scanner isAtEnd]) {
        [scanner scanUpToCharactersFromSet:chSet intoString:&line];

        if ([[line lowercaseString] hasPrefix:@"host"]) {
            NSArray *array = [line componentsSeparatedByString:@":"];
            if ([array count] == 2) {
                address = [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                port = 80;
            } else if ([array count] == 3) {
                address = [[array objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                port = [[array objectAtIndex:2] intValue];
            }
        }
        
        [scanner scanCharactersFromSet:chSet intoString:NULL];
    }
    
    if (address == nil || port == 0) {
        NSLog(@"DPAWSIoTWebClient::openSocket: Cannot parse http header.");
        return NO;
    }
    
    _socketAdapter = [[DPAWSIoTHttpSocketAdapter alloc] initWithHostname:address port:(UInt32)port timeout:30];
    _socketAdapter.connection = _connection;
    return [_socketAdapter openSocket];
}

- (int) findHeaderEnd:(const char *)buf length:(int)rlen
{
    int splitbyte = 0;
    while (splitbyte + 1 < rlen) {
        // RFC2616
        if (buf[splitbyte] == '\r' && buf[splitbyte + 1] == '\n' &&
            splitbyte + 3 < rlen && buf[splitbyte + 2] == '\r' &&
            buf[splitbyte + 3] == '\n') {
            return splitbyte + 4;
        }
        
        // tolerance
        if (buf[splitbyte] == '\n' && buf[splitbyte + 1] == '\n') {
            return splitbyte + 2;
        }
        splitbyte++;
    }
    return 0;
}

- (void) sendHttpError
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"E, d MMM yyyy HH:mm:ss 'GMT'";
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSMutableData *newData = [NSMutableData data];
    
    [newData appendData:[@"HTTP/1.1 500 OK\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Date: " dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[[df stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Server: AWSIot-Remote-Server(iOS)\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Connection: close\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"ERROR" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [_connection sendData:newData.bytes length:(int) newData.length];
}

#pragma mark - DPAWSIoTP2PConnectionDelegate

- (void) connection:(DPAWSIoTP2PConnection *)conn didRetrievedAddress:(NSString *)address port:(int)port
{
    NSData *data = [DPAWSIoTP2PManager createSignaling:conn.connectionId address:address port:port];
    NSString *signaling = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([_delegate respondsToSelector:@selector(client:didNotifiedSignaling:)]) {
        [_delegate client:self didNotifiedSignaling:signaling];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didConnectedAddress:(NSString *)address port:(int)port
{
    if ([_delegate respondsToSelector:@selector(clientDidConnected:)]) {
        [_delegate clientDidConnected:self];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didReceivedData:(const char *)data length:(int)length
{
    if (!_socketAdapter) {
        [_httpHeaderData appendBytes:data length:length];
        
        if ([self findHeaderEnd:_httpHeaderData.bytes length:(int) _httpHeaderData.length] > 0) {
            if (![self openSocket:_httpHeaderData.bytes length:(int) _httpHeaderData.length]) {
                [self sendHttpError];
                [_connection close];
                return;
            }
            [_socketAdapter writeData:_httpHeaderData.bytes length:_httpHeaderData.length];
            _httpHeaderData = nil;
        }
    } else {
        [_socketAdapter writeData:data length:length];
    }
}

- (void) connection:(DPAWSIoTP2PConnection *)conn didDisconnetedAdderss:(NSString *)address port:(int)port
{
   if ([_delegate respondsToSelector:@selector(clientDidDisconnected:)]) {
        [_delegate clientDidDisconnected:self];
    }
    
    [_socketAdapter closeSocket];
}

- (void) connectionDidNotConnect:(DPAWSIoTP2PConnection *)conn
{
 }

- (void) connectionDidTimeout:(DPAWSIoTP2PConnection *)conn
{
    if ([_delegate respondsToSelector:@selector(clientDidTimeout:)]) {
        [_delegate clientDidTimeout:self];
    }
    
    [_socketAdapter closeSocket];
}

@end
