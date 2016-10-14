//
//  DConnectMessageEventSession.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectEventSession.h"
#import <DConnectSDK/DConnectSDK.h>
#import "DConnectWebSocket.h"

@interface DConnectMessageEventSession : DConnectEventSession

- (instancetype) initWithDelegate: (id<DConnectManagerDelegate>) delegate webSocket: (DConnectWebSocket *) webSocket origin: (NSString *) origin;

@end
