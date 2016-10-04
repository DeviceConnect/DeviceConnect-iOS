//
//  DConnectHttpConnection.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectHttpConnection.h"
#import "DConnectWebSocket.h"

@implementation DConnectHttpConnection

#pragma mark - Override Method

- (WebSocket *)webSocketForURI:(NSString *)path
{
    DConnectWebSocket *websocket = [[DConnectWebSocket alloc] initWithRequest:request socket:asyncSocket];
    websocket.delegate = config.server;
    websocket.connectTime = [NSDate date].timeIntervalSince1970;
    return websocket;
}

@end
