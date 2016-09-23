//
//  DConnectWebSocketInfoManager.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectWebSocketInfoManager.h"
#import "DConnectWebSocketInfo.h"

@interface DConnectWebSocketInfoManager()

@property(nonatomic, strong) NSMutableDictionary *webSocketInfos;

@end

@implementation DConnectWebSocketInfoManager

- (instancetype) init {
    
    self = [super init];
    if (self) {
        self.webSocketInfos = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void) addWebSocketInfo: (NSString *) eventKey uri:(NSString *) uri webSocketId: (NSString *) webSocketId socket:(WebSocket *) socket {
    DConnectWebSocketInfo *info = [DConnectWebSocketInfo new];
    info.webSocketId = webSocketId;
    info.uri = uri;
    info.eventKey = eventKey;
    info.socket = socket;
    info.connectTime = [[NSDate date] timeIntervalSince1970] * 1000;
    self.webSocketInfos[eventKey] = info;
}

- (void) removeWebSocketInfo: (NSString *) eventKey {
    
    [self.webSocketInfos removeObjectForKey: eventKey];
}

- (void) removeWebSocketInfoForSocket: (WebSocket *) socket {

    for (NSString *key in [self.webSocketInfos keyEnumerator]) {
        DConnectWebSocketInfo *info = [self.webSocketInfos objectForKey: key];
        if (info.socket == socket) {
            [self.webSocketInfos removeObjectForKey: key];
            return;
        }
    }
}

- (void) removeAllWebSocketInfos {
    [self.webSocketInfos removeAllObjects];
}

- (DConnectWebSocketInfo *) webSocketInfoForEventKey: (NSString *) eventKey {
    return self.webSocketInfos[eventKey];
}

@end
