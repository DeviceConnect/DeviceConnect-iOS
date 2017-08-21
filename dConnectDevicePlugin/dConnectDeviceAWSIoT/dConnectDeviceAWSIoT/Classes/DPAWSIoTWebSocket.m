//
//  DPAWSIoTWebSocket.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <objc/runtime.h>
#import "DPAWSIoTWebSocket.h"

@interface PSWebSocket (custom)
@property (nonatomic) NSString *key;
@property (nonatomic) NSInteger retryCount;
@end

@implementation PSWebSocket (custom)
@dynamic key;
@dynamic retryCount;
- (void)setKey:(NSString*)value {
	objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString*)key {
	return objc_getAssociatedObject(self, @selector(setKey:));
}
- (void)setRetryCount:(NSInteger)retryCount {
	objc_setAssociatedObject(self, _cmd, @(retryCount), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSInteger)retryCount {
	return [objc_getAssociatedObject(self, @selector(setRetryCount:)) integerValue];
}
@end


@interface DPAWSIoTWebSocket() <PSWebSocketDelegate> {
    PSWebSocket *_socket;
	NSURL *_url;
    NSString *_accessToken;
    int _retryCount;
}
@end

@implementation DPAWSIoTWebSocket

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self setPort:4035];
        _retryCount = 3;
	}
	return self;
}

- (void)setPort:(int)port {
	NSString *url = [NSString stringWithFormat:@"ws://localhost:%d/gotapi/websocket", port];
	_url = [NSURL URLWithString:url];
}

- (void)openWebSocketWithAccessToken:(NSString*)key {
    [self closeWebSocket];
    _socket = [self createSocket:key];
    [_socket open];
}

- (void)closeWebSocket {
    [_socket close];
    _socket = nil;
}

- (BOOL)isOpened {
    return _socket && _socket.readyState == PSWebSocketReadyStateOpen;
}

#pragma mark - Private method

// WebSocketを作成
- (PSWebSocket*)createSocket:(NSString*)key {
	NSURLRequest *request = [NSURLRequest requestWithURL:_url];
	PSWebSocket *socket = [PSWebSocket clientSocketWithRequest:request];
	socket.delegate = self;
	socket.key = key;
	return socket;
}

#pragma mark - PSWebSocketDelegate

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
	[webSocket send:[NSString stringWithFormat:@"{\"accessToken\":\"%@\"}", webSocket.key]];
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    if ([message isEqualToString:@"{\"result\":0}"]) {
        return;
    }

	if (self.receivedHandler) {
		self.receivedHandler(webSocket.key, message);
	}
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    if (_retryCount-- > 0) {
        [self openWebSocketWithAccessToken:webSocket.key];
    } else {
        NSLog(@"Failed to open the WebSocket.");
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
}

@end
