//
//  DPAWSIoTP2PConnection.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@class DPAWSIoTP2PConnection;


@protocol DPAWSIoTP2PConnectionDelegate <NSObject>
@optional
- (void) connection:(DPAWSIoTP2PConnection *)conn didRetrievedAddress:(NSString *)address port:(int)port;
- (void) connection:(DPAWSIoTP2PConnection *)conn didConnectedAddress:(NSString *)address port:(int)port;
- (void) connection:(DPAWSIoTP2PConnection *)conn didReceivedData:(const char *)data length:(int)length;
- (void) connection:(DPAWSIoTP2PConnection *)conn didDisconnetedAdderss:(NSString *)address port:(int)port;
- (void) connectionDidNotConnect:(DPAWSIoTP2PConnection *)conn;
- (void) connectionDidTimeout:(DPAWSIoTP2PConnection *)conn;
@end


@interface DPAWSIoTP2PConnection : NSObject

@property (nonatomic, assign) id<DPAWSIoTP2PConnectionDelegate> delegate;
@property (nonatomic) int connectionId;

- (instancetype) initWithConnectionId:(int)connectionId;

- (void) open;
- (BOOL) connectToAddress:(NSString *)address port:(int)port;
- (void) sendData:(const char *)data length:(int)length;
- (void) sendData:(const char *)data offset:(int)offset length:(int)length;
- (void) close;

+ (int) generateConnectionId;

@end
