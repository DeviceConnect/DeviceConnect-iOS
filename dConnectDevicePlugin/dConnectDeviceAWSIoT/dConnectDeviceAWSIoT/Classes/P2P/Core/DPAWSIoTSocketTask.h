//
//  DPAWSIoTSocketTask.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "udt.h"

@protocol DPAWSIoTSocketTaskDelegate <NSObject>
@optional
- (void) didNotConnected;
- (void) didConnectedAddress:(NSString *)address port:(int)port;
- (void) didReceivedData:(const char *)data length:(int)length;
- (void) didDisconnetedAdderss:(NSString *)address port:(int)port;
@end


@interface DPAWSIoTSocketTask : NSObject

@property (nonatomic, assign) id<DPAWSIoTSocketTaskDelegate> delegate;

- (instancetype) initWithSocket:(UDTSOCKET)socket;

- (void) setAddress:(NSString *)address;
- (void) setPort:(int)port;

- (void) sendData:(const char *)data length:(int)length;
- (void) sendData:(const char *)data offset:(int)offset length:(int)length;
- (void) execute;
- (void) close;

@end
