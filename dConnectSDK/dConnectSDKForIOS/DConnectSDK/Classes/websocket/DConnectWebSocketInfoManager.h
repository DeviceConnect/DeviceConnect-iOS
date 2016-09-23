//
//  DConnectWebSocketInfoManager.h
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DConnectWebSocketInfo.h"

@interface DConnectWebSocketInfoManager : NSObject

- (void) addWebSocketInfo: (NSString *) eventKey uri:(NSString *) uri webSocketId: (NSString *) webSocketId socket:(WebSocket *) socket;

- (void) removeWebSocketInfo: (NSString *) eventKey;

- (void) removeWebSocketInfoForSocket: (WebSocket *) socket;

- (void) removeAllWebSocketInfos;

- (DConnectWebSocketInfo *) webSocketInfoForEventKey: (NSString *) eventKey;

@end
