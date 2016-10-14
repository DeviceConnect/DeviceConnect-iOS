//
//  DPAWSIoTSocketAdapter.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

#import "DPAWSIoTP2PConnection.h"

@interface DPAWSIoTSocketAdapter : NSObject

@property (nonatomic) DPAWSIoTP2PConnection *connection;

- (BOOL)openSocket;
- (void)closeSocket;
- (BOOL)writeData:(const void*)data length:(NSUInteger)len;

@end
