//
//  DPAWSIoTRelayServer.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTSocketTask.h"

@protocol DPAWSIoTRelayServerDelegate <DPAWSIoTSocketTaskDelegate>
@optional
- (void) didRetrievedAddress:(NSString *)address port:(int)port;
@end


@interface DPAWSIoTRelayServer : NSObject

@property (nonatomic, assign) id<DPAWSIoTRelayServerDelegate> delegate;

- (void) open;
- (void) sendData:(NSData *)data;
- (void) sendData:(const char *)data length:(int)length;
- (void) sendData:(const char *)data offset:(int)offset length:(int)length;
- (void) close;

@end
