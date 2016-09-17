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
	NSMutableDictionary *_sockets;
	NSURL *_url;
}
@end

@implementation DPAWSIoTWebSocket

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self setPort:4035];
		_sockets = [NSMutableDictionary dictionary];
	}
	return self;
}

// ポート番号設定
- (void)setPort:(int)port {
	NSString *url = [NSString stringWithFormat:@"ws://localhost:%d", port];
	_url = [NSURL URLWithString:url];
	
}

// WebSocketを追加
- (void)addSocket:(NSString*)key {
	if (_sockets[key]) {
		[self removeSocket:key];
	}
	PSWebSocket *socket = [self createSocket:key];
	[socket open];
	_sockets[key] = socket;
}

// WebSocketを削除
- (void)removeSocket:(NSString*)key {
	PSWebSocket *socket = _sockets[key];
	[socket close];
	[_sockets removeObjectForKey:key];
}

// WebSocketを作成
- (PSWebSocket*)createSocket:(NSString*)key {
	NSURLRequest *request = [NSURLRequest requestWithURL:_url];
	PSWebSocket *socket = [PSWebSocket clientSocketWithRequest:request];
	socket.delegate = self;
	socket.key = key;
	socket.retryCount = 3;
	return socket;
}

#pragma mark - PSWebSocketDelegate

- (void)webSocketDidOpen:(PSWebSocket *)webSocket {
	//NSLog(@"The websocket handshake completed and is now open!");
	webSocket.retryCount = 3;
	[webSocket send:[NSString stringWithFormat:@"{\"sessionKey\":\"%@\"}", webSocket.key]];
}

- (void)webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
	//NSLog(@"The websocket received a message: %@", message);
	if (self.receivedHandler) {
		self.receivedHandler(webSocket.key, message);
	}
}

- (void)webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
	NSLog(@"The websocket handshake/connection failed with an error: %@, %zd", error, webSocket.retryCount);
	if (webSocket.retryCount-- > 0) {
		NSInteger retryCount = webSocket.retryCount;
		[self addSocket:webSocket.key];
		PSWebSocket *socket = _sockets[webSocket.key];
		socket.retryCount = retryCount;
	}
}

- (void)webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
	NSLog(@"The websocket closed with code: %@, reason: %@, wasClean: %@", @(code), reason, (wasClean) ? @"YES" : @"NO");
}

@end
