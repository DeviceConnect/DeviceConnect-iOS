//
//  WebAppOrigin.h
//  DConnectSDK
//
//  Created by Masaru Takano on 2015/03/10.
//  Copyright (c) 2015年 NTT DOCOMO, INC. All rights reserved.
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