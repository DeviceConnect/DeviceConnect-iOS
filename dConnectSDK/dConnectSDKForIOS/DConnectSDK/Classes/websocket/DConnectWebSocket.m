//
//  DConnectWebSocket.m
//  websocket
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectWebSocket.h"
#import "HTTPMessage.h"
#import "DConnectMessage.h"
#import "DConnectService.h"
#import "DConnectWebSocketInfoManager.h"
#import "LocalOAuth2Main.h"

#define TIMEOUT_READ_FIRST_HEADER_LINE       30
#define TIMEOUT_READ_SUBSEQUENT_HEADER_LINE  30
#define MAX_HEADER_LINE_LENGTH             8190
#define HTTP_REQUEST_HEADER                  10

@interface DConnectWebSocket ()

/*! @brief Websocketの処理を行うキュー.
 */
@property (nonatomic) dispatch_queue_t serverQueue;

/*! @brief ソケット.
 */
@property (nonatomic) GCDAsyncSocket *asyncSocket;

/*! @brief HTTPリクエスト.
 */
@property (nonatomic) HTTPMessage *request;

/*! @brief websocketの一覧.
 */
@property (nonatomic) NSMutableArray *websocketList;

/*! @brief WebSocket管理情報の配列.
 */
@property(nonatomic, strong) DConnectWebSocketInfoManager *webSocketInfoManager;

@end



@implementation DConnectWebSocket

- (instancetype) initWithObject: (NSObject *) object {
    self = [super init];
    if (self) {
        self.object = object;
        self.websocketList = [NSMutableArray array];
        self.webSocketInfoManager = [DConnectWebSocketInfoManager new];
        self.host = @"localhost";
        self.port = 4035;
    }
    return self;
}

- (instancetype) initWithHost:(NSString *)host port:(int)port object:(NSObject *) object {
    self = [super init];
    if (self) {
        self.object = object;
        self.websocketList = [NSMutableArray array];
        self.webSocketInfoManager = [DConnectWebSocketInfoManager new];
        self.host = host;
        self.port = port;
    }
    return self;
}

- (BOOL) start {
    self.serverQueue = dispatch_queue_create("WebSocketServer", NULL);
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.serverQueue];
    
    if ([self isUseSSL]) {
        NSDictionary *settings = [self createSSLConfiguration];
        if (settings) {
            [self.asyncSocket startTLS:settings];
        }
    }
    
    NSError *error = nil;
    BOOL success = [self.asyncSocket acceptOnInterface:self.host port:self.port error:&error];
#ifdef DEBUG
    if (!success) {
        DCLogE(@"Failed to initialize the websocket. %@", error);
    }
#endif
    return success;
}

- (void) stop {
    for (int i = 0; i < self.websocketList.count; i++) {
        WebSocket *socket = self.websocketList[i];
        [socket stop];
    }
    [self.websocketList removeAllObjects];
    [self.webSocketInfoManager removeAllWebSocketInfos];
}

- (void) sendEvent:(NSString *)event forOrigin:(NSString *)origin {
    NSString *eventKey = origin;
    DConnectWebSocketInfo *webSocketInfo = [self.webSocketInfoManager webSocketInfoForEventKey: eventKey];
    WebSocket *socket = webSocketInfo.socket;
    if (socket) {
        [socket sendMessage:event];
    }
}

- (BOOL) isUseSSL {
    return NO;
}

- (NSDictionary *) createSSLConfiguration {
    // TODO: SSLの実装
    return nil;
}

#pragma mark - WebSocketDelegate Methods -

- (void)webSocketDidOpen:(WebSocket *)webSocket origin: (NSString *)origin {
    [self.websocketList addObject:webSocket];
}

- (void)webSocket:(WebSocket *)webSocket didReceiveMessage:(NSString *)msg {
    NSData *jsonData = [msg dataUsingEncoding:NSUnicodeStringEncoding];
    if (jsonData) {
        // JSONをNSDictionaryに変換する
        NSError *error = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingAllowFragments
                                                              error:&error];
        if (!error) {
            
            NSString *webSocketId = [[NSUUID UUID] UUIDString];
            HTTPMessage *httpRequest = [webSocket getRequest];
            NSString *uri = httpRequest.url.absoluteString;
            NSString *origin = httpRequest.allHeaderFields[@"origin"];
            NSString *eventKey;
            
            if (uri && [uri localizedCaseInsensitiveCompare: @"/gotapi/websocket"]) {
                NSString *accessToken = dic[DConnectMessageAccessToken];
                if (!accessToken) {
                    DCLogW(@"onWebSocketMessage: accessToken is not specified");
                    [self sendError: webSocket errorCode:1 errorMessage:@"accessToken is not specified."];
                    return;
                }
                if ([self requiresOrigin]) {
                    if (!origin) {
                        DCLogW(@"onWebSocketMessage: origin is not specified.");
                        [self sendError: webSocket errorCode:2 errorMessage: @"origin is not specified."];
                        return;
                    }
                    if ([self usesLocalOAuth] && ![self isValidAccessToken: accessToken origin: origin]) {
                        DCLogW(@"onWebSocketMessage: accessToken is invalid.");
                        [self sendError: webSocket errorCode:3 errorMessage:@"accessToken is invalid."];
                        return;
                    }
                } else {
                    if (!origin) {
                        origin = DConnectServiceAnonymousOrigin;
                    }
                }
                eventKey = origin;
                // NOTE: 既存のイベントセッションを保持する.
                
                if ([self.webSocketInfoManager webSocketInfoForEventKey: eventKey]) {
                    DCLogW(@"onWebSocketMessage: already established.");
                    [self sendError: webSocket errorCode:4 errorMessage:@"already established."];
                    [webSocket stop];   // webSocket.disconnectWebSocket();
                    return;
                }
                [self sendSuccess: webSocket];
            } else {
                if (!origin) {
                    origin = DConnectServiceAnonymousOrigin;
                }
                
                eventKey = dic[DConnectMessageSessionKey];
                
                // NOTE: 既存のイベントセッションを破棄する.
                DConnectWebSocketInfo *webSocketInfo = [self.webSocketInfoManager webSocketInfoForEventKey: eventKey];
                if (webSocketInfo) {
                    [webSocketInfo.socket stop];
                }
            }
            if (!eventKey) {
                DCLogW(@"onWebSocketMessage: Failed to generate eventKey: uri = %@, origin = %@", uri, origin);
                return;
            }
            
            [self.webSocketInfoManager addWebSocketInfo: eventKey uri: [NSString stringWithFormat: @"%@%@", origin, uri] webSocketId: webSocketId socket: webSocket];
        }
    }
}

- (void)webSocketDidClose:(WebSocket *)webSocket {
    [self.websocketList removeObject:webSocket];
    [self.webSocketInfoManager removeWebSocketInfoForSocket:webSocket];
}

#pragma mark - GCDAsyncSocketDelegate Methods -

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    dispatch_async(self.serverQueue, ^{
        if ([self isUseSSL]) {
            NSDictionary *settings = [self createSSLConfiguration];
            if (settings) {
                [newSocket startTLS:settings];
            }
        }
        
        [newSocket readDataToData:[GCDAsyncSocket CRLFData]
                      withTimeout:TIMEOUT_READ_FIRST_HEADER_LINE
                        maxLength:MAX_HEADER_LINE_LENGTH
                              tag:HTTP_REQUEST_HEADER];
	});

    // 新しい通信がきたので、リクエストを新規に作成
    self.request = [[HTTPMessage alloc] initEmptyRequest];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)err {
    DCLogD(@"socketDidDisconnect:withError: %@", err);
}

- (void)socket:(GCDAsyncSocket *)socket didReadData:(NSData *)data withTag:(long)tag {
    if (tag == HTTP_REQUEST_HEADER) {
		BOOL result = [self.request appendData:data];
        if (result && ![self.request isHeaderComplete]) {
            [socket readDataToData:[GCDAsyncSocket CRLFData]
                       withTimeout:TIMEOUT_READ_SUBSEQUENT_HEADER_LINE
                         maxLength:MAX_HEADER_LINE_LENGTH
                               tag:HTTP_REQUEST_HEADER];
		} else {
            if ([WebSocket isWebSocketRequest:self.request]) {
                WebSocket *websocket = [[WebSocket alloc] initWithRequest:self.request socket:socket];
                websocket.delegate = self;
                NSString *origin = [self.request headerField:@"origin"];
                [websocket start: origin];
            }
        }
    }
#ifdef DEBUG
    else {
        DCLogW(@"NO Websocket request.");
	}
#endif
}

- (BOOL) requiresOrigin {
    return self.settings.useOriginEnable;
}

- (BOOL) usesLocalOAuth {
    return self.settings.useLocalOAuth;
}

- (BOOL) isValidAccessToken: (NSString *) accessToken origin: (NSString *) origin {
    
    LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass: [self.object class]];
    LocalOAuthClientPackageInfo *client = [oauth findClientPackageInfoByAccessToken: accessToken];
    if (!client) {
        return NO;
    }
    LocalOAuthPackageInfo *packageInfo = [client packageInfo];
    if (!packageInfo) {
        return NO;
    }
    
    return [packageInfo.packageName isEqualToString: origin];
}

- (void) sendSuccess: (WebSocket *) webSocket {
    
    NSDictionary *message = @{@"result" : [NSNumber numberWithInt:0]};
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    [webSocket sendMessage:messageJson];
}

- (void) sendError: (WebSocket *) webSocket
         errorCode: (int) errorCode
      errorMessage: (NSString *) errorMessage {
    
    NSDictionary *message = @{
                              @"result" : [NSNumber numberWithInt:1],
                              @"errorCode" : [NSNumber numberWithInt:errorCode],
                              @"errorMessage" : errorMessage,
                              };
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    [webSocket sendMessage:messageJson];
}

@end
