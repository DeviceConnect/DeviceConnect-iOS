//
//  DPAWSIoTWebServer.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>
#import "DPAWSIoTP2PManager.h"


@class DPAWSIoTWebServer;


@protocol DPAWSIoTWebServerDelegate <NSObject>
@optional
- (void) serverDidConnected:(DPAWSIoTWebServer *)server;
- (void) serverDidDisconnected:(DPAWSIoTWebServer *)server;
- (void) server:(DPAWSIoTWebServer *)server didNotifiedSignaling:(NSString *)signaling;
@end


@interface DPAWSIoTWebServer : DPAWSIoTP2PManager

@property (nonatomic, assign) id<DPAWSIoTWebServerDelegate> delegate;

@property (nonatomic) NSInteger listenPort;
@property (nonatomic) NSInteger port;
@property (nonatomic) NSString *host;
@property (nonatomic) NSString *path;
@property (nonatomic) NSObject *target;

- (NSString *) start;
- (void) stop;

- (void) didReceivedSignaling:(NSString *)signaling;
- (BOOL) hasConnectionId:(NSString *)signaling;

@end
