//
//  DPAWSIoTServerRunnable.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//
#import "DPAWSIoTServerRunnable.h"
#import "DPAWSIoTP2PConnection.h"
#import "GCDAsyncSocket.h"

@implementation DPAWSIoTServerRunnable {
    NSMutableData *_headerData;
    BOOL _headerEndFlag;
    int _retryCount;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _headerData = [NSMutableData data];
        _retryCount = 0;
    }
    return self;
}

#pragma mark - Public Method

- (BOOL) isRetry
{
    return (_retryCount++) < 10;
}

- (void) w:(NSData *)data
{
    [self.fromSocket writeData:data withTimeout:5 tag:0];
}

- (void) r:(NSData *)data
{
    if (!_headerEndFlag) {
        [_headerData appendData:data];
        
        int headerSize = [self findHeaderEnd:_headerData];
        if (headerSize > 0) {
            NSData *d = [self convHeader:_headerData];
            [self.connection sendData:d.bytes length:(int)d.length];
            [self.connection sendData:data.bytes offset:headerSize length:(int) (data.length - headerSize)];
            _headerEndFlag = YES;
        }
    } else {
        [self.connection sendData:data.bytes length:(int)data.length];
    }
    [self.fromSocket readDataWithTimeout:5 tag:0];
}

- (void) close
{
    if (self.fromSocket) {
        [self.fromSocket disconnect];
    }
    if (self.connection) {
        [self.connection close];
    }
}

- (void) sendErrorResponse
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
    
    [self.fromSocket writeData:newData withTimeout:5 tag:0];
}

#pragma mark - Private Method

- (NSData *) convHeader:(NSData *)data
{
    NSMutableData *newData = [NSMutableData data];
    
    NSString *http = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSScanner *scanner = [NSScanner scannerWithString:http];
    NSCharacterSet *chSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
    NSString *line;
    while (![scanner isAtEnd]) {
        [scanner scanUpToCharactersFromSet:chSet intoString:&line];

        if ([[line lowercaseString] hasPrefix:@"host"]) {
            NSString *newHost = [NSString stringWithFormat:@"Host: %@:%@", self.host, @(self.port)];
            [newData appendData:[newHost dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [newData appendData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];

    return newData;
}

- (int) findHeaderEnd:(NSData *)data
{
    return [self findHeaderEnd:(const char *)data.bytes length:(int)data.length];
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

@end
