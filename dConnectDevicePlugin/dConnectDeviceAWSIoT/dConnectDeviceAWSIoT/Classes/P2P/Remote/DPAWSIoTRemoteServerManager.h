//
//  DPAWSIoTRemoteServerManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@protocol DPAWSIoTRemoteServerManagerDelegate <NSObject>

-(void)didReceivedAddress:(NSString *)address port:(int)port;

@end


@interface DPAWSIoTRemoteServerManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTRemoteServerManagerDelegate> delegate;


- (NSString*) createWebServer:(NSString *)address port:(int)port path:(NSString *)path;
- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
