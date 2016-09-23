//
//  DPAWSIoTRelayClient.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTSocketTask.h"


@protocol DPAWSIoTRelayClientDelegate <DPAWSIoTSocketTaskDelegate>
@end


@interface DPAWSIoTRelayClient : NSObject

@property (nonatomic, assign) id<DPAWSIoTRelayClientDelegate> delegate;

- (BOOL) connect:(NSString *)address port:(int)port;
- (void) sendData:(NSData *)data;
- (void) sendData:(const char *)data length:(int)length;
- (void) sendData:(const char *)data offset:(int)offset length:(int)length;
- (void) close;

@end
