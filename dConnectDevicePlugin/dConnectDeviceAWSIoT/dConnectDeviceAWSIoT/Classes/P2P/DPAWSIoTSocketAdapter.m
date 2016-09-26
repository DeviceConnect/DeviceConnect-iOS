//
//  DPAWSIoTSocketAdapter.m
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import "DPAWSIoTSocketAdapter.h"
#import "GCDAsyncSocket.h"

@implementation DPAWSIoTSocketAdapter

- (BOOL) openSocket
{
    return NO;
}

- (void) closeSocket
{
}

- (BOOL) writeData:(const void *)data length:(NSUInteger)len
{
    return NO;
}

@end
