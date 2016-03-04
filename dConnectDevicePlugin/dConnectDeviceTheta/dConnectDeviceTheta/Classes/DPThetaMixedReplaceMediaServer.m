//
//  DPThetaMixedReplaceMediaServer.m
//  dConnectDeviceTheta
//
//  Copyright (c) 2015 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPThetaMixedReplaceMediaServer.h"
#import <UIKit/UIKit.h>
#import "DPThetaManager.h"


#define PutPresentedViewController(top) \
top = [UIApplication sharedApplication].keyWindow.rootViewController; \
while (top.presentedViewController) { \
top = top.presentedViewController; \
}

// Max Media Cache
static int const DPThetaMaxMediaCache = 2;

// Max Client Size
static int const DPThetaMaxClientSize = 8;

// Header
static int const DPThetaTagHeader = 0;

@interface DPThetaMixedReplaceMediaServer()
@property (nonatomic) NSUInteger port;
@property (nonatomic) NSString *boundary;
@property (nonatomic) NSString *contentType;
@property (nonatomic) NSString *serverName;
@property (nonatomic) NSData *jpegData;
@property (nonatomic) NSString *segment;
@property (nonatomic) NSMutableDictionary *connectedSockets;
@property (nonatomic) NSMutableDictionary *broadcastROIImages;
@end

@implementation DPThetaMixedReplaceMediaServer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _port = 9000;
        _boundary = [[NSUUID UUID] UUIDString];
        _contentType = @"image/jpeg";
        _serverName = @"Theta DevicePlugin Server";
        _connectedSockets = [NSMutableDictionary dictionary];
        _broadcastROIImages = [NSMutableDictionary dictionary];
        socketQueue = dispatch_queue_create("org.deviceconnect.ios.mixedreplacemediaserver.THETA", NULL);
        listenSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
        _isRunning = NO;

        
    }
    return self;
}

- (void)startStopServer
{
    if (!_isRunning) {
        _isRunning = YES;
        NSError *error = nil;
        for (int i = 9000; i <= 10000; i++) {
            _port = i;
            if (![listenSocket acceptOnPort:_port error:&error]) {
                if (_port >= 10000) {
                    NSLog(@"error:%@", error);
                    return;
                }
                continue;
            } else {
                break;
            }
        }
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));

        dispatch_source_set_cancel_handler(_timerSource, ^{
            if(_timerSource){
                _timerSource = NULL;
            }
        });
        dispatch_source_set_event_handler(_timerSource, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSString *key in _connectedSockets.allKeys) {
                    @synchronized (_connectedSockets) {
                        NSString *segment = key;
                        NSRange range = [[segment stringByRemovingPercentEncoding] rangeOfString:@"?snapshot"];
                        if (range.location != NSNotFound) {
                            segment = [DPThetaManager omitParametersToUri:segment];
                        }
                        _jpegData = _broadcastROIImages[segment];
                        GCDAsyncSocket *sock = _connectedSockets[key];
                        if (range.location != NSNotFound) {
                            [sock writeData:[self generateOneShotResponse] withTimeout:-1 tag:1];
                            if (_delegate) {
                                [_delegate didConnectForSegment:key isGet:YES];
                            }
                            [sock disconnect];
                            [_connectedSockets removeObjectForKey:key];
//                            [_broadcastROIImages removeObjectForKey:segment];
                        } else {
                            
                            [sock writeData:[self generateResponse] withTimeout:-1 tag:1];
                            if (_delegate) {
                                [_delegate didConnectForSegment:key isGet:NO];
                            }
                        }
                    }
                }
            });
        });
        dispatch_source_set_timer(_timerSource, dispatch_time(DISPATCH_TIME_NOW, 0),
                                  NSEC_PER_SEC * 0.1, NSEC_PER_SEC);
        dispatch_resume(_timerSource);
    } else {
        if(_timerSource){
            dispatch_source_cancel(_timerSource);
        }
        [listenSocket disconnect];
        @synchronized (_connectedSockets) {
            for (GCDAsyncSocket *sock in _connectedSockets.allValues) {
                [sock disconnect];
            }
        }
        _isRunning = NO;
    }
}


- (NSString*)getUrl
{
    return [NSString stringWithFormat:@"http://localhost:%lu", (unsigned long) _port];
}


- (void)offerMediaWithData:(NSData*)data segment:(NSString *)segment
{
    [_broadcastROIImages setObject:data forKey:[NSString stringWithFormat:@"/%@", segment]];
    if (_broadcastROIImages.count == DPThetaMaxMediaCache) {
        [_broadcastROIImages removeObjectForKey:segment];
    }
}


- (void)stopMediaForSegment:(NSString*)segment
{
    @synchronized(_connectedSockets)
    {
        NSString *seg = [NSString stringWithFormat:@"/%@", segment];
        GCDAsyncSocket *sock = _connectedSockets[seg];
        if (sock) {
            [sock disconnect];
            
            [_connectedSockets removeObjectForKey:seg];
            [_broadcastROIImages removeObjectForKey:seg];
        }
        if (_connectedSockets.count <= 0 && _isRunning) {
            [self startStopServer];
            [_broadcastROIImages removeAllObjects];
        }

    }
}

#pragma mark - GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:15.0 tag:DPThetaTagHeader];
}


- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
    NSString *msg = [[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding];
    if (tag == DPThetaTagHeader) {
        NSArray *segments = [msg componentsSeparatedByString:@" "];
        NSString *segment = segments[1];
        @synchronized(_connectedSockets)
        {

            if (_connectedSockets.count <= DPThetaMaxClientSize) {
                [_connectedSockets setObject:sock forKey:segment];
            } else {
                [sock writeData:[self generateErrorResponseWithCode:500] withTimeout:-1 tag:1];
                if (_delegate) {
                    [_delegate didDisconnectForSegment:segment];
                }
            }
        }
    }
}


#pragma mark - private method

- (NSMutableData *)generateResponse
{
    NSMutableData* data = [NSMutableData data];

    [data appendData:[[NSString stringWithFormat:@"HTTP/1.0 200 OK\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Server: %@\r\n", _serverName] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Connection: close\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Max-Age: 0\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Expires: 0\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Cache-Control: no-store,no-cache,must-revalidate,pre-check=0,post-check=0,max-age=0\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Pragma: no-cache\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-Type: multipart/x-mixed-replace;boundary=%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"--%@\r\n", _boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-type: %@\r\n", _contentType] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-Length: %lu\r\n", (unsigned long) _jpegData.length] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:_jpegData];
    [data appendData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}


- (NSMutableData *)generateOneShotResponse
{
    NSMutableData* data = [NSMutableData data];
    
    [data appendData:[[NSString stringWithFormat:@"HTTP/1.0 200 OK\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Server: %@\r\n", _serverName] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Connection: close\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-Type: image/jpeg\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Content-Length: %lu\r\n", (unsigned long) _jpegData.length] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:_jpegData];
    return data;
}


- (NSMutableData *)generateErrorResponseWithCode:(int)code
{
    NSMutableData* data = [NSMutableData data];
    
    [data appendData:[[NSString stringWithFormat:@"HTTP/1.0 %d OK\r\n", code] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Server: %@\r\n", _serverName] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"Connection: close\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    return data;
}
@end
