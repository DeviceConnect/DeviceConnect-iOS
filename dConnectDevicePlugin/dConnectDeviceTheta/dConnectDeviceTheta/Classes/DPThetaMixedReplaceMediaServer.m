//
//  DPThetaMixedReplaceMediaServer.m
//  dConnectDeviceTheta
//
//  Created by 星　貴之 on 2015/08/12.
//  Copyright (c) 2015年 DOCOMO. All rights reserved.
//

#import "DPThetaMixedReplaceMediaServer.h"
#import <UIKit/UIKit.h>
#import "DPThetaGLRenderView.h"


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
@property (nonatomic, strong) DPThetaGLRenderView *glRenderView;
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
        _isRunning = YES;
        _timerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                              0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));

        // タイマーキャンセルハンドラ設定
        dispatch_source_set_cancel_handler(_timerSource, ^{
            if(_timerSource){
                _timerSource = NULL;
            }
        });
        dispatch_source_set_event_handler(_timerSource, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSString *key in _connectedSockets.allKeys) {
//                    NSLog(@"socket:%@", segment);
//                    [_glRenderView draw];
//                    _jpegData = [[NSData alloc] initWithData:UIImageJPEGRepresentation([_glRenderView snapshot], 1.0)];
                    _jpegData = _broadcastROIImages[key];
                    GCDAsyncSocket *sock = _connectedSockets[key];
                    @synchronized (_connectedSockets) {
                        [sock writeData:[self generateResponse] withTimeout:-1 tag:1];
                    }
                }
            });
        });
        // インターバル等を設定
        dispatch_source_set_timer(_timerSource, dispatch_time(DISPATCH_TIME_NOW, 0),
                                  NSEC_PER_SEC * 0.3, NSEC_PER_SEC);
        // タイマー開始
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
        
//        [_glRenderView removeFromSuperview];
//        _glRenderView = NULL;
    }
}


- (NSString*)getUrl
{
    return [NSString stringWithFormat:@"http://localhost:%lu", (unsigned long) _port];
}


- (void)offerMediaWithData:(NSData*)data segment:(NSString *)segment
{
//    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"dConnectDeviceTheta_resources"
//                                                                                ofType:@"bundle"]];
//    NSString * path = [bundle pathForResource:@"r" ofType:@"jpg"];
//    if (_isTume) {
//        path = [bundle pathForResource:@"poi" ofType:@"jpg"];
//        _isTume = NO;
//    } else {
//        _isTume = YES;
//    }
//    UIImage *thumb = [UIImage imageWithContentsOfFile:path];
    
//    [_broadcastROIImages setObject:[[NSData alloc] initWithData:UIImageJPEGRepresentation(thumb, 1.0)] forKey:segment];
    [_broadcastROIImages setObject:data forKey:[NSString stringWithFormat:@"/%@", segment]];
}

#pragma mark - GCDAsyncSocket Delegate

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    [newSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:15.0 tag:0];
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
            [_connectedSockets setObject:sock forKey:segment];
            // タイマーイベントハンドラ
//            dispatch_async(dispatch_get_main_queue(), ^{
//                for (NSData *thumb in _broadcastROIImages.allValues) {
//                    _glRenderView = [[DPThetaGLRenderView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
//                    [_glRenderView setTexture:thumb
//                                          yaw:0.0f
//                                        pitch:0.0f
//                                         roll:0.0f];
//                    UIViewController *rootView = [UIApplication sharedApplication].keyWindow.rootViewController;
//                    while (rootView.presentedViewController) {
//                        rootView = rootView.presentedViewController;
//                    }
//                    [rootView.view addSubview:_glRenderView];
//                    [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
//                    _glRenderView.hidden = YES;
//                }
//            });

        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
//    NSLog(@"didWriteData");
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
@end
