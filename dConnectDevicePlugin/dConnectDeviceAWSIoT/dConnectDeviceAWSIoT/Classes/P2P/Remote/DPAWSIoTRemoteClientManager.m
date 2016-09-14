//
//  DPAWSIoTRemoteClientManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTRemoteClientManager.h"
#import "DPAWSIoTWebClient.h"

@interface DPAWSIoTRemoteClientManager () <DPAWSIoTWebClientDelegate>

@end

@implementation DPAWSIoTRemoteClientManager {
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

- (void) didReceivedSignaling:(NSString *)signaling
{
    DPAWSIoTWebClient *client = [DPAWSIoTWebClient new];
    client.delegate = self;
    [client didReceivedSignaling:signaling];
    [_clientList addObject:client];
}

#pragma mark - DPAWSIoTWebClientDelegate

- (void) client:(DPAWSIoTWebClient *)client didRetrievedAddress:(NSString *)address port:(int)port
{
    // TODO 通知
}

- (void) clientDidConnected:(DPAWSIoTWebClient *)client
{
    
}

- (void) clientDidDisconnected:(DPAWSIoTWebClient *)client
{
    [_clientList removeObject:client];
}

@end
