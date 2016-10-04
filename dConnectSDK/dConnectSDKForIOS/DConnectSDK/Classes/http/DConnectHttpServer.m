//
//  DConnectHttpServer.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectHttpServer.h"
#import "DConnectWebSocket.h"

@implementation DConnectHttpServer

- (void) sendEvent:(NSString *)event forReceiverId:(NSString *)eventKey
{
    DConnectWebSocket *websocket = [self findWebSocketById:eventKey];
    if (websocket) {
        [websocket sendMessage:event];
    }
}

- (void) stopWebSocket
{
    [webSocketsLock lock];
    
    for (WebSocket *websocket in webSockets) {
        [websocket stop];
    }
    
    [webSocketsLock unlock];
}

- (DConnectWebSocket *) findWebSocketById:(NSString *)receiverId
{
    [webSocketsLock lock];
    
    DConnectWebSocket *w = nil;
    for (DConnectWebSocket *websocket in webSockets) {
        if ([receiverId isEqualToString:websocket.receiverId]) {
            w = websocket;
            break;
        }
    }
    
    [webSocketsLock unlock];
    return w;
}

- (NSArray *) getWebSockets
{
    return webSockets.copy;
}

@end
