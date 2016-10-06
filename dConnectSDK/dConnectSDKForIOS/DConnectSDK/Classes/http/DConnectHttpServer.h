//
//  DConnectHttpServer.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RoutingHTTPServer.h"
#import "WebSocket.h"

@class DConnectWebSocket;

@interface DConnectHttpServer : RoutingHTTPServer <WebSocketDelegate>

- (void) sendEvent:(NSString *)event forReceiverId:(NSString *)eventKey;

- (void) stopWebSocket;

- (DConnectWebSocket *) findWebSocketById:(NSString *)receiverId;

- (NSArray *) getWebSockets;

@end
