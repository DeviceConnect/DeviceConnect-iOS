//
//  DConnectHttpConnection.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "RoutingConnection.h"
#import "WebSocket.h"

@interface DConnectHttpConnection : RoutingConnection <WebSocketDelegate>


@end
