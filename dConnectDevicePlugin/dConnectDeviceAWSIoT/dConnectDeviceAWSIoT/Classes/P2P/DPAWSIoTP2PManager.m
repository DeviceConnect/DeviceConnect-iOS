//
//  DPAWSIoTP2PManager.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTP2PManager.h"
#import "DPAWSIoTNetworkInfo.h"

NSString *const kConnectionId = @"connectionId";
NSString *const kGlobal = @"global";
NSString *const kLocal = @"local";
NSString *const kAddress = @"address";
NSString *const kPort = @"port";

@implementation DPAWSIoTP2PManager

- (int) getConnectionId:(NSString *)signaling
{
    NSData *jsonData = [signaling dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                        error:&error];
    if (error) {
        return -1;
    }
    
    NSNumber *num = [dic objectForKey:kConnectionId];
    if (num) {
        return [num intValue];
    } else {
        return -1;
    }
}

- (DPAWSIoTP2PConnection *) createP2PConnection:(NSString *)signaling delegate:(id<DPAWSIoTP2PConnectionDelegate>)delegate
{
    NSData *jsonData = [signaling dataUsingEncoding:NSUnicodeStringEncoding];
    
    NSError *error;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                        error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return nil;
    }
    DPAWSIoTP2PConnection *connection = [DPAWSIoTP2PConnection new];
    connection.delegate = delegate;

    NSDictionary *global = [dic objectForKey:kGlobal];
    NSDictionary *local = [dic objectForKey:kLocal];
    
    for (int i = 0; i < 3; i++) {
        if ([self connect:connection global:global local:local]) {
            return connection;
        }
    }
    [connection close];
    return nil;
}

- (BOOL) connect:(DPAWSIoTP2PConnection *)connection global:(NSDictionary *)global local:(NSDictionary *)local
{
    NSString *address = [global objectForKey:kAddress];
    int port = [[global objectForKey:kPort] intValue];
    if (![connection connectToAddress:address port:port]) {
        address = [local objectForKey:kAddress];
        port = [[local objectForKey:kPort] intValue];
        if (![connection connectToAddress:address port:port]) {
            return NO;
        }
    }
    return YES;
}

+ (NSData *)createSignaling:(int)connectionId address:(NSString *)address port:(int)port
{
    NSMutableDictionary *global = [NSMutableDictionary dictionary];
    [global setObject:address forKey:kAddress];
    [global setObject:@(port) forKey:kPort];
    
    NSMutableDictionary *obj = [NSMutableDictionary dictionary];
    [obj setObject:@(connectionId) forKey:kConnectionId];
    [obj setObject:global forKey:kGlobal];
 
    NSString *localAddress = [DPAWSIoTNetworkInfo getLocalIp];
    if (localAddress) {
        NSMutableDictionary *local = [NSMutableDictionary dictionary];
        [local setObject:localAddress forKey:kAddress];
        [local setObject:@(port) forKey:kPort];
        [obj setObject:local forKey:kLocal];
    }
    
    return [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
}

@end
