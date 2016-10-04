//
//  DConnectWebSocket.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "WebSocket.h"

@class DConnectHttpServer;

@interface DConnectWebSocket : WebSocket <WebSocketDelegate>

@property (nonatomic) NSString *receiverId;
@property(nonatomic) long connectTime;

- (HTTPMessage *) getRequest;

@end
