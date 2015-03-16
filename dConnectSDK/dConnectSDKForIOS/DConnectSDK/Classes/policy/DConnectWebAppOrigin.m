//
//  WebAppOrigin.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectWebAppOrigin.h"

const int DConnectWebAppOriginPortNotSpecified = -1;
NSString *const DConnectWebAppOriginSeparatorHost = @"://";
NSString *const DConnectWebAppOriginSeparatorPort = @":";

NSString *const DConnectWebAppOriginSchemeHttp = @"http";
NSString *const DConnectWebAppOriginSchemeHttps = @"https";
const int DConnectWebAppOriginDefaultPortHttp = 80;
const int DConnectWebAppOriginDefaultPortHttps = 443;

@interface DConnectWebAppOrigin ()
{
    int _port;
}
@end

@interface DConnectHttpOrigin : DConnectWebAppOrigin
- (id) initWithHost:(NSString *)host port:(int)port;
@end

@interface DConnectHttpsOrigin : DConnectWebAppOrigin
- (id) initWithHost:(NSString *)host port:(int)port;
@end

@implementation DConnectWebAppOrigin

+ (id<DConnectOrigin>) parse:(NSString *)originExp
{
    NSRange range = [originExp rangeOfString:DConnectWebAppOriginSeparatorHost];
    if (range.location == NSNotFound) {
        return nil;
    }
    NSString *scheme = [originExp substringToIndex:range.location];
    NSString *authority = [originExp substringFromIndex:range.location + range.length];
    NSString *host;
    int port;
    range = [authority rangeOfString:DConnectWebAppOriginSeparatorPort];
    if (range.location == NSNotFound) {
        host = authority;
        port = DConnectWebAppOriginPortNotSpecified;
    } else {
        host = [authority substringToIndex:range.location];
        port = [[authority substringFromIndex:range.location + range.length] integerValue];
        if (port < 0) {
            return nil;
        }
    }
    if ([scheme isEqualToString:DConnectWebAppOriginSchemeHttp]) {
        return [[DConnectHttpOrigin alloc] initWithHost:host port:port];
    } else if ([scheme isEqualToString:DConnectWebAppOriginSchemeHttps]) {
        return [[DConnectHttpsOrigin alloc] initWithHost:host port:port];
    }
    return nil;
}

- (id) initWithScheme:(NSString *)scheme host:(NSString *)host port:(int)port
{
    self = [super init];
    if (self) {
        _scheme = scheme;
        _host = host;
        _port = port;
    }
    return self;
}

- (int) port
{
    if (_port == DConnectWebAppOriginPortNotSpecified) {
        return [self defaultPort];
    }
    return _port;
}

- (int) defaultPort
{
    return -1;
}

- (BOOL) matches:(id<DConnectOrigin>)origin
{
    if (![origin isKindOfClass:[DConnectWebAppOrigin class]]) {
        return NO;
    }
    DConnectWebAppOrigin *other = (DConnectWebAppOrigin *) origin;
    if (![_scheme isEqualToString:other.scheme]) {
        return NO;
    }
    if (![_host isEqualToString:other.host]) {
        return NO;
    }
    if ([self port] != [other port]) {
        return NO;
    }
    return YES;
}

- (NSString *) stringify
{
    NSMutableString *originExp = [NSMutableString string];
    [originExp appendString:_scheme];
    [originExp appendString:DConnectWebAppOriginSeparatorHost];
    [originExp appendString:_host];
    if (_port != DConnectWebAppOriginPortNotSpecified) {
        [originExp appendString:DConnectWebAppOriginSeparatorPort];
        [originExp appendString:[[NSNumber numberWithInt:_port] stringValue]];
    }
    return originExp;
}

@end

@implementation DConnectHttpOrigin
- (id) initWithHost:(NSString *)host port:(int)port
{
    return [super initWithScheme:DConnectWebAppOriginSchemeHttp
                            host:host
                            port:port];
}

- (int) defaultPort
{
    return DConnectWebAppOriginDefaultPortHttp;
}
@end

@implementation DConnectHttpsOrigin
- (id) initWithHost:(NSString *)host port:(int)port
{
    return [super initWithScheme:DConnectWebAppOriginSchemeHttps
                            host:host
                            port:port];
}

- (int) defaultPort
{
    return DConnectWebAppOriginDefaultPortHttps;
}
@end
