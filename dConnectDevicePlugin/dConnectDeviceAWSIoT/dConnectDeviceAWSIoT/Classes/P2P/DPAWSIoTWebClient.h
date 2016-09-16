//
//  DPAWSIoTWebClient.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTP2PManager.h"


@class DPAWSIoTWebClient;


@protocol DPAWSIoTWebClientDelegate <NSObject>
@optional
- (void) clientDidConnected:(DPAWSIoTWebClient *)client;
- (void) clientDidDisconnected:(DPAWSIoTWebClient *)client;
- (void) clientDidTimeout:(DPAWSIoTWebClient *)client;
- (void) client:(DPAWSIoTWebClient *)client didNotifiedSignaling:(NSString *)signaling;
@end

@protocol DPAWSIoTWebClientDataSource <NSObject>

- (NSString *) addData:(NSData *)data;
- (NSData *) getData:(NSString *)uuid;
- (void) removeData:(NSString *)uuid;

@end


@interface DPAWSIoTWebClient : DPAWSIoTP2PManager

@property (nonatomic, assign) id<DPAWSIoTWebClientDelegate> delegate;
@property (nonatomic, assign) id<DPAWSIoTWebClientDataSource> dataSource;

@property (nonatomic) NSObject *target;

- (void) connect:(NSString *)address port:(int)port;
- (void) close;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
