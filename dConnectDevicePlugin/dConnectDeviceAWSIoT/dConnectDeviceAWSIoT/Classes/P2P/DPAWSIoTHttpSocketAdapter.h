//
//  DPAWSIoTHttpSocketAdapter.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTSocketAdapter.h"

@interface DPAWSIoTHttpSocketAdapter : DPAWSIoTSocketAdapter

@property (readonly, nonatomic) NSString* hostname;
@property (readonly, nonatomic) UInt32 port;
@property (nonatomic) NSInteger timeoutSec;

- (id)initWithHostname:(NSString *)hostname port:(UInt32)port timeout:(int)timeoutSec;

- (BOOL) openSocket;
- (void) closeSocket;
- (BOOL) writeData:(const void *)data length:(NSUInteger)len;

@end
