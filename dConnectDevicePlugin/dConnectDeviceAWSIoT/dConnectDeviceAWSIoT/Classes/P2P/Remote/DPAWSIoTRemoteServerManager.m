//
//  DPAWSIoTRemoteServerManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTRemoteServerManager.h"
#import "DPAWSIoTWebServer.h"
#import "DPAWSIoTP2PManager.h"

@interface DPAWSIoTRemoteServerManager () <DPAWSIoTWebServerDelegate>

@end


@implementation DPAWSIoTRemoteServerManager {
    NSMutableArray *_serverList;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _serverList = [NSMutableArray array];
    }
    return self;
}

- (NSString*) createWebServer:(NSString *)address port:(int)port path:(NSString *)path to:(NSString *)uuid
{
    DPAWSIoTWebServer *server = [DPAWSIoTWebServer new];
    server.delegate = self;
    server.host = address;
    server.port = port;
    server.path = path;
    server.target = uuid;
    NSString *url = [server start];
    if (url) {
        [_serverList addObject:server];
    }
    return url;
}

- (void) destroy
{
    [_serverList enumerateObjectsUsingBlock:^(DPAWSIoTWebServer *server, NSUInteger idx, BOOL *stop) {
        [server stop];
    }];
    [_serverList removeAllObjects];
}

- (void) didReceivedSignaling:(NSString *)signaling
{
    [_serverList enumerateObjectsUsingBlock:^(DPAWSIoTWebServer *server, NSUInteger idx, BOOL *stop) {
        if ([server hasConnectionId:signaling]) {
            [server didReceivedSignaling:signaling];
            *stop = YES;
        }
    }];
}

#pragma mark - DPAWSIoTWebServerDelegate

- (void) server:(DPAWSIoTWebServer *)server didNotifiedSignaling:(NSString *)signaling
{
    [self.delegate remoteServerManager:self didNotifiedSignaling:signaling to:(NSString *)server.target];
}

- (void) serverDidConnected:(DPAWSIoTWebServer *)server
{
}

- (void) serverDidDisconnected:(DPAWSIoTWebServer *)server
{
    [_serverList removeObject:server];
}

@end
