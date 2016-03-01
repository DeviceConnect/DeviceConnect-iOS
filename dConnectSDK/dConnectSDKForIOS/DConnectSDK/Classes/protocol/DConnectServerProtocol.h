//
//  DConnectServerProtocol.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRequestMessage.h"
#import "DConnectURLProtocol.h"
#import "GCDAsyncSocket.h"

@interface DConnectServerProtocol : DConnectURLProtocol


+ (BOOL)startServerWithHost:(NSString*)host port:(int)port;
+ (void)stopServer;


+ (void)sendEvent:(NSString *)event forSessionKey:(NSString *)sessionKey;
@end
