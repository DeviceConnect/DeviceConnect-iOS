//
//  DConnectRequestMessage.m
//  DConnectSDK
//
//  Copyright (c) 2014 NTT DOCOMO,INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DConnectRequestMessage.h"

@implementation DConnectRequestMessage

- (id) init {
    
    self = [super init];
    
    if (self) {
        [self setString:DConnectMessageDefaultAPI forKey:DConnectMessageAPI];
    }
    
    return self;
}

#pragma mark - Common Parameters
#pragma mark Setter

- (void) setAction:(DConnectMessageActionType)action {
    [self setInteger:action forKey:DConnectMessageAction];
}

- (void) setApi:(NSString *)api {
    [self setString:api forKey:DConnectMessageAPI];
}

- (void) setProfile:(NSString *)profile {
    [self setString:profile forKey:DConnectMessageProfile];
}

- (void) setAttribute:(NSString *)attribute {
    [self setString:attribute forKey:DConnectMessageAttribute];
}

- (void) setInterface:(NSString *)interface {
    [self setString:interface forKey:DConnectMessageInterface];
}

- (void) setOrigin:(NSString *)origin {
    [self setString:origin forKey:DConnectMessageOrigin];
}

- (void) setServiceId:(NSString *)serviceId {
    [self setString:serviceId forKey:DConnectMessageServiceId];
}

- (void) setPluginId:(NSString *)pluginId {
    [self setString:pluginId forKey:DConnectMessagePluginId];
}

- (void) setAccessToken:(NSString *)accessToken {
    [self setString:accessToken forKey:DConnectMessageAccessToken];
}

#pragma mark Getter

- (NSString *) api {
    return [self stringForKey:DConnectMessageAPI];
}

- (NSString *) profile {
    return [self stringForKey:DConnectMessageProfile];
}

- (NSString *) attribute {
    return [self stringForKey:DConnectMessageAttribute];
}

- (NSString *) interface {
    return [self stringForKey:DConnectMessageInterface];
}

- (NSString *) sessionKey {
    return [self stringForKey:DConnectMessageSessionKey];
}

- (NSString *) serviceId {
    return [self stringForKey:DConnectMessageServiceId];
}

- (NSString *) pluginId {
    return [self stringForKey:DConnectMessagePluginId];
}

- (DConnectMessageActionType) action {
    return [self integerForKey:DConnectMessageAction];
}

- (NSString *) accessToken {
    return [self stringForKey:DConnectMessageAccessToken];
}

- (NSString *) origin {
    return [self stringForKey:DConnectMessageOrigin];
}

@end
