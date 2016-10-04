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
#import "DConnectHttpServer.h"
#import "DConnectManager+Private.h"
#import "DConnectMessage+Private.h"
#import "LocalOAuth2Main.h"
#import "HTTPMessage.h"

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

#pragma mark - Private Method

- (BOOL) isValidAccessToken: (NSString *) accessToken origin: (NSString *) origin
{
    LocalOAuth2Main *oauth = [LocalOAuth2Main sharedOAuthForClass: [DConnectManager class]];
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

- (void) sendSuccess: (WebSocket *) webSocket
{
    NSDictionary *message = @{@"result" : [NSNumber numberWithInt:0]};
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    [webSocket sendMessage:messageJson];
}

- (void) sendError: (WebSocket *) webSocket
         errorCode: (int) errorCode
      errorMessage: (NSString *) errorMessage
{
    NSDictionary *message = @{
                              @"result" : [NSNumber numberWithInt:1],
                              @"errorCode" : [NSNumber numberWithInt:errorCode],
                              @"errorMessage" : errorMessage,
                              };
    NSData *messageData = [NSJSONSerialization dataWithJSONObject:message options:0 error:nil];
    NSString *messageJson = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    [webSocket sendMessage:messageJson];
}

#pragma mark - WebSocketDelegate Methods -

- (void)webSocketDidOpen:(WebSocket *)webSocket
{
}

- (void)webSocket:(WebSocket *)webSocket didReceiveMessage:(NSString *)msg
{
    NSData *jsonData = [msg dataUsingEncoding:NSUnicodeStringEncoding];
    if (jsonData) {
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                             options:NSJSONReadingAllowFragments
                                                               error:&error];
        if (!error) {
            DConnectWebSocket *websocket = (DConnectWebSocket *)webSocket;
            HTTPMessage *httpRequest = [websocket getRequest];
            NSString *receiverId;
            NSString *path = httpRequest.url.path;
            NSString *origin = httpRequest.allHeaderFields[@"origin"];
            if (origin && [origin isEqualToString:@"null"]) {
                origin = @"file://";
            }
            
            if (path && [path localizedCaseInsensitiveCompare: @"/gotapi/websocket"] == NSOrderedSame) {
                NSString *accessToken = json[DConnectMessageAccessToken];
                if (!accessToken) {
                    DCLogW(@"onWebSocketMessage: accessToken is not specified");
                    [self sendError: webSocket errorCode:1 errorMessage:@"accessToken is not specified."];
                    return;
                }
                if ([DConnectManager sharedManager].settings.useOriginEnable) {
                    if (!origin) {
                        DCLogW(@"onWebSocketMessage: origin is not specified.");
                        [self sendError: webSocket errorCode:2 errorMessage: @"origin is not specified."];
                        return;
                    }
                    if (![self isValidAccessToken: accessToken origin: origin]) {
                        DCLogW(@"onWebSocketMessage: accessToken is invalid.");
                        [self sendError: webSocket errorCode:3 errorMessage:@"accessToken is invalid."];
                        return;
                    }
                } else {
                    if (!origin) {
                        origin = @"<anonymous>";
                    }
                }
                receiverId = origin;
                
                // NOTE: 既存のイベントセッションを保持する.
                WebSocket *existWebSocket = [self findWebSocketById:receiverId];
                if (existWebSocket) {
                    DCLogW(@"onWebSocketMessage: already established.");
                    [self sendError: webSocket errorCode:4 errorMessage:@"already established."];
                    [webSocket stop];
                    return;
                }
                [self sendSuccess: webSocket];
            } else {
                if (!origin) {
                    origin = @"<anonymous>";
                }
                
                receiverId = json[DConnectMessageSessionKey];
                
                // NOTE: 既存のイベントセッションを破棄する.
                WebSocket *otherSocket = [self findWebSocketById:receiverId];
                if (otherSocket) {
                    [otherSocket stop];
                }
            }
            
            if (!receiverId) {
                DCLogW(@"onWebSocketMessage: Failed to generate receiverId: path = %@, origin = %@", path, origin);
                return;
            }
            
            // イベント送信経路を確立
            websocket.receiverId = receiverId;
        } else {
            DCLogE(@"onWebSocketMessage:  JSON format is invalid.");
            [self sendError: webSocket errorCode:5 errorMessage:@"JSON format is invalid."];
        }
    }
}

- (void) webSocketDidClose:(WebSocket *)webSocket
{
}

@end
