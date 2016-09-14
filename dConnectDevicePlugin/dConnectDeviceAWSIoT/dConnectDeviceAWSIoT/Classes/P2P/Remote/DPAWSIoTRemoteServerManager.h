//
//  DPAWSIoTRemoteServerManager.h
//  dConnectDeviceAWSIoT
//
//  Copyright (c) 2016 NTT DOCOMO, INC.
//  Released under the MIT license
//  http://opensource.org/licenses/mit-license.php
//

#import <Foundation/Foundation.h>


@class DPAWSIoTRemoteServerManager;

@protocol DPAWSIoTRemoteServerManagerDelegate <NSObject>

-(void) remoteServerManager:(DPAWSIoTRemoteServerManager *)manager didNotifiedSignaling:(NSString *)signaling to:(NSString *)uuid;

@end


@interface DPAWSIoTRemoteServerManager : NSObject

@property (nonatomic, assign) id<DPAWSIoTRemoteServerManagerDelegate> delegate;

- (NSString*) createWebServer:(NSString *)address port:(int)port path:(NSString *)path to:(NSString *)uuid;
- (void) destroy;
- (void) didReceivedSignaling:(NSString *)signaling;

@end
