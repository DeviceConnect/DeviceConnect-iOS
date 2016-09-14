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

- (NSString*) createWebServer:(NSString *)address port:(int)port path:(NSString *)path
{
    DPAWSIoTWebServer *server = [DPAWSIoTWebServer new];
    server.delegate = self;
    server.host = address;
    server.port = port;
    server.path = path;
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
    // TODO 通知
}

#pragma mark - DPAWSIoTWebServerDelegate

- (void) server:(DPAWSIoTWebServer *)server didRetrievedAddress:(NSString *)address port:(int)port
{
    // TODO 通知
    
    [self.delegate didReceivedAddress:address port:port];
}

- (void) serverDidConnected:(DPAWSIoTWebServer *)server
{
    
}

- (void) serverDidDisconnected:(DPAWSIoTWebServer *)server
{
    [_serverList removeObject:server];
}

@end
