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

@property (nonatomic) void(^receivedHandler)(NSString *message);

// WebSocketを追加
- (void)addSocket:(NSString*)key;
// WebSocketを削除
- (void)removeSocket:(NSString*)key;

@end
