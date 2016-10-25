//
//  DConnectWebSocket.m
//  DConnectSDK
//
//  Copyright (c) 2016 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectWebSocket.h"
#import "HTTPMessage.h"

@implementation DConnectWebSocket

- (HTTPMessage *) getRequest
{
    return request;
}

@end
