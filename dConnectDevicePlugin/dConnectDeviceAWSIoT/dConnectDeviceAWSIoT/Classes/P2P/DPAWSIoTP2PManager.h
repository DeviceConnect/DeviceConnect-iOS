//
//  DPAWSIoTP2PManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTP2PConnection.h"

@interface DPAWSIoTP2PManager : NSObject

- (int) getConnectionId:(NSString *)signaling;

- (DPAWSIoTP2PConnection *) createP2PConnection:(NSString *)signaling delegate:(id<DPAWSIoTP2PConnectionDelegate>)delegate;

+ (NSData *)createSignaling:(int)connectionId address:(NSString *)address port:(int)port;


@end
