//
//  DPAWSIoTFileSocketAdapter.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTSocketAdapter.h"

@interface DPAWSIoTFileSocketAdapter : DPAWSIoTSocketAdapter

@property (nonatomic) NSInteger timeoutSec;

- (id)initWithData:(NSData *)data timeout:(int)timeoutSec;

- (BOOL) openSocket;
- (void) closeSocket;
- (BOOL) writeData:(const void *)data length:(NSUInteger)len;

@end
