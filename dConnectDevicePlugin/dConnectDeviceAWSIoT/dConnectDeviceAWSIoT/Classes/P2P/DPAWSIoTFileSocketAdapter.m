//
//  DPAWSIoTFileSocketAdapter.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTFileSocketAdapter.h"

@implementation DPAWSIoTFileSocketAdapter {
    NSData *_data;
}

- (id)initWithData:(NSData *)data timeout:(int)timeoutSec;
{
    self = [super init];
    if (self) {
        _data = data;
        _timeoutSec = timeoutSec;
    }
    return self;
}

- (BOOL) openSocket
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf run];
    });
    return YES;
}

- (void) closeSocket
{
    if (self.connection) {
        [self.connection close];
        self.connection = nil;
    }
}

- (BOOL) writeData:(const void *)data length:(NSUInteger)len
{
    return YES;
}

#pragma mark - Private Method

- (void) run
{
    if (_data) {
        [self sendData];
    } else {
        [self sendHttpError];
    }
}

- (void) sendData
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"E, d MMM yyyy HH:mm:ss 'GMT'";
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSString *contentLength = [NSString stringWithFormat:@"%@", @(_data.length)];
    
    NSMutableData *newData = [NSMutableData data];
    [newData appendData:[@"HTTP/1.1 200 OK\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Date: " dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[[df stringFromDate:[NSDate date]] dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Server: AWSIot-Remote-Server(iOS)\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Content-Length: " dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[contentLength dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"Connection: close\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [newData appendData:_data];
    
    [self.connection sendData:(const char *)newData.bytes length:(int)newData.length];
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
    
    [self.connection sendData:(const char *)newData.bytes length:(int)newData.length];
}

@end
