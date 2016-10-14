//
//  DPAWSIoTWebSocket.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "PocketSocket/PSWebSocket.h"

@interface DPAWSIoTWebSocket : NSObject

@property (nonatomic) void(^receivedHandler)(NSString *key, NSString *message);

// ポート番号設定
- (void)setPort:(int)port;

// WebSocketを追加
- (void)openWebSocketWithAccessToken:(NSString*)key;

// WebSocketを削除
- (void)closeWebSocket;

@end
