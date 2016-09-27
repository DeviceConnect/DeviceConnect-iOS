//
//  DConnectWebSocketInfo.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "WebSocket.h"

@interface DConnectWebSocketInfo : NSObject

@property(nonatomic, strong) NSString *webSocketId;

@property(nonatomic, strong) NSString *eventKey;

@property(nonatomic, strong) NSString *uri;

@property(nonatomic, strong) NSString *origin;

@property(nonatomic, strong) WebSocket *socket;

@property(nonatomic) long connectTime;

@end
