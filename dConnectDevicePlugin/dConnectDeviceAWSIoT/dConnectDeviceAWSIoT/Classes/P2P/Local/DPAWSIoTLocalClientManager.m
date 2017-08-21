//
//  DPAWSIoTLocalClientManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTLocalClientManager.h"
#import "DPAWSIoTWebClient.h"

@interface DPAWSIoTLocalClientManager () <DPAWSIoTWebClientDelegate>

@end

@implementation DPAWSIoTLocalClientManager {
    NSMutableArray *_clientList;
}

- (instancetype) init
{
    self = [super init];
    if (self) {
        _clientList = [NSMutableArray array];
    }
    return self;
}

- (void) destroy
{
    [_clientList enumerateObjectsUsingBlock:^(DPAWSIoTWebClient *client, NSUInteger idx, BOOL *stop) {
        [client close];
    }];
    [_clientList removeAllObjects];
}

- (void) didReceivedSignaling:(NSString *)signaling dataSource:(id)dataSource
{
    DPAWSIoTWebClient *client = [DPAWSIoTWebClient new];
    client.delegate = self;
    client.dataSource = dataSource;
    [client didReceivedSignaling:signaling];
    [_clientList addObject:client];
}

#pragma mark - DPAWSIoTWebClientDelegate

- (void) client:(DPAWSIoTWebClient *)client didNotifiedSignaling:(NSString *)signaling
{
    [self.delegate localClientManager:self didNotifiedSignaling:signaling];
}

- (void) clientDidConnected:(DPAWSIoTWebClient *)client
{
}

- (void) clientDidTimeout:(DPAWSIoTWebClient *)client
{
    [_clientList removeObject:client];
}

- (void) clientDidDisconnected:(DPAWSIoTWebClient *)client
{
    [_clientList removeObject:client];
}

@end
