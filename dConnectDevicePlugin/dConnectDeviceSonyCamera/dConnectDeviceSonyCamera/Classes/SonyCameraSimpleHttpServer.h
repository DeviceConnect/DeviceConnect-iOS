//
//  SonyCameraSimpleHttpServer.h
//  dConnectDeviceSonyCamera
//
//  Copyright (c) 2017 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket;


@interface SonyCameraConnection : NSObject

@property (nonatomic, strong) GCDAsyncSocket *fromSocket;
@property (nonatomic) BOOL ready;

@end


@interface SonyCameraSimpleHttpServer : NSObject

@property (nonatomic) NSInteger listenPort;

- (void) start;
- (void) stop;

- (NSString *) getUrl;

- (void) offerData:(NSData *)data;

@end
