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

// ポート番号設定
- (void)setPort:(int)port {
	NSString *url = [NSString stringWithFormat:@"ws://localhost:%d/gotapi/websocket", port];
	_url = [NSURL URLWithString:url];
}

// WebSocketを追加
- (void)openWebSocketWithAccessToken:(NSString*)key {
    [self closeWebSocket];
    _socket = [self createSocket:key];
    [_socket open];
}

// WebSocketを削除
- (void)closeWebSocket {
    [_socket close];
    _socket = nil;
}

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
	NSLog(@"The websocket handshake/connection failed with an error: %@, %zd", error, webSocket.retryCount);
    
    if (_retryCount-- > 0) {
        [self openWebSocketWithAccessToken:webSocket.key];
    } else {
        NSLog(@"Failed to open the WebSocket.");
    }
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}

@end
