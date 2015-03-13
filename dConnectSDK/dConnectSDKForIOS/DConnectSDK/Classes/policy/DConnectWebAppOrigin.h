//
//  WebAppOrigin.h
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectOrigin.h"

extern const int DConnectWebAppOriginPortNotSpecified;

@interface DConnectWebAppOrigin : NSObject <DConnectOrigin>

@property NSString *scheme;
@property NSString *host;

+ (id<DConnectOrigin>) parse:(NSString *)originExp;

- (id) initWithScheme:(NSString*) scheme
                 host:(NSString*) host
                 port:(int) port;

- (int) port;

- (int) defaultPort;

- (BOOL) matches:(id<DConnectOrigin>)origin;

@end
