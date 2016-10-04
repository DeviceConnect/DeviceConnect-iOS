//
//  DConnectServerProtocol.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRequestMessage.h"
#import "DConnectSettings.h"

@interface DConnectServerProtocol : NSObject

@property (nonatomic) DConnectSettings *settings;

- (BOOL)startServer;
- (void)stopServer;
- (void)sendEvent:(NSString *)event forReceiverId:(NSString *)receiverId;

- (NSArray *) getWebSockets;

@end
