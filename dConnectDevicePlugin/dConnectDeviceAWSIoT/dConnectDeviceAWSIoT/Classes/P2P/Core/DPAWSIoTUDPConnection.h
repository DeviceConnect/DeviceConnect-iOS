//
//  DPAWSIoTUDPConnection.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@protocol DPAWSIoTUDPConnectionDelegate <NSObject>
@optional
- (void) didConnect;
- (void) didNotConnect;
- (void) didDisconnect;
- (void) didReceivedData:(NSData *)data address:(NSString *)address port:(int)port;
@end


@interface DPAWSIoTUDPConnection : NSObject

@property (nonatomic, assign) id<DPAWSIoTUDPConnectionDelegate> delegate;

@property (nonatomic) NSTimeInterval timeout;

- (instancetype) initWithPort:(int)port;

- (void) open;
- (BOOL) sendData:(const char *)data length:(int)length;
- (BOOL) sendData:(const char *)data length:(int)length to:(NSString *)address port:(int)port;
- (void) close;

@end
